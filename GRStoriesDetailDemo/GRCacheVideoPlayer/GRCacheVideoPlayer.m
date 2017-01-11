//
//  GRCacheVideoPlayer.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRCacheVideoPlayer.h"
#import "NSURL+CacheVideoPlayer.h"
#import "GRVideoCache.h"
#import "GRResourceLoader.h"
#import "GRVideoDownloadManager.h"

static NSString * const __GRPlayerItemKeyPathStatus = @"status";

@interface GRCacheVideoPlayer () <GRResourceLoaderDelegate>

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) GRResourceLoader *resourceLoader;
@property (strong, nonatomic) NSMutableArray *playerItemsObservers;
@property (strong, nonatomic) NSMutableArray *playerObservers;
@property (strong, nonatomic) id timeObserver;

@end

@implementation GRCacheVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __config];
    }
    return self; 
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __config];
    }
    return self; 
}

- (void)__config {
    [self __addObserver];
} 

- (void)dealloc {
    if (self.player) { 
        [self __removeObserverWithPlayerItem:self.player.currentItem];
        [self __removePlayerObserver];
        [self __removeObserver];
    } 
} 

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [self __removeObserverWithPlayerItem:_playerItem];
    }
    _playerItem = playerItem;
}

- (NSMutableArray *)playerItemsObservers {
    if (!_playerItemsObservers) {
        _playerItemsObservers = [[NSMutableArray alloc] init];
    }
    return _playerItemsObservers;
}

- (NSMutableArray *)playerObservers {
    if (!_playerObservers) {
        _playerObservers = [[NSMutableArray alloc] init];
    }
    return _playerObservers;
} 

- (void)playWithURL:(NSURL *)videoURL {
    self.videoURL = videoURL;
    
    if ([self.videoURL.absoluteString hasPrefix:@"http"]) {
        [[GRVideoDownloadManager shareInstance] addCurrentPlayingDownload:videoURL];
        
        self.resourceLoader = [[GRResourceLoader alloc] init];
        self.resourceLoader.videoDownloadManager = [GRVideoDownloadManager shareInstance];
        self.resourceLoader.delegate = self;
        
        AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[videoURL customSchemeURL] options:nil];
        [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    } else {
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    }
    
    if (self.player) {
        [self __removePlayerObserver]; 
    }
    
    [self __addObserver:self.playerItem];
    
    if (self.player) {
        [self __removeObserverWithPlayerItem:self.player.currentItem];
    }
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    [self __addPlayerObserver];
}

- (void)play {
    if([[NSThread currentThread] isMainThread]) {
        [self.player play];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.player play];
        });
    }
}

- (void)pause {
    if (self.player) {
        if([[NSThread currentThread] isMainThread]) {
            [self.player pause];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.player pause];
            });
        }
    }
}

- (void)stop {
    if (!self.player) {
        return;
    }
    
    [self.player pause];
    [self __removeObserverWithPlayerItem:self.player.currentItem];
    [self __removeObserverWithPlayerItem:self.playerItem];
}

- (void)__playerDidEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
    }];
}

#pragma mark - observer

- (void)__removePlayerObserver {
    @try {
        if (self.timeObserver) {
            [self.player removeTimeObserver:self.timeObserver]; 
        } 
    } @catch (NSException *exception) {
    }
}

- (void)__addPlayerObserver {
    CMTime interval = CMTimeMake(1, 10);
    [self.playerObservers addObject:self.player];
    @weakify(self);
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:interval queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        @strongify(self);
        NSTimeInterval durationTime = CMTimeGetSeconds(self.playerItem.duration);
        NSTimeInterval currentTime = CMTimeGetSeconds(self.playerItem.currentTime);
        CGFloat process = currentTime / durationTime;
        if (self.delegate && [self.delegate respondsToSelector:@selector(cacheVideoPlayer:playProcess:)]) {
            [self.delegate cacheVideoPlayer:self playProcess:process];
        } 
    }];
}

- (void)__removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)__addObserver:(AVPlayerItem *)playerItem {
    [self.playerItemsObservers addObject:playerItem];
    [self.playerItem addObserver:self forKeyPath:__GRPlayerItemKeyPathStatus options:NSKeyValueObservingOptionNew context:nil];
    
    [self __removeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__playerDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)__removeObserverWithPlayerItem:(AVPlayerItem *)playerItem {
    if (!playerItem) {
        return; 
    }
    
    @try {
        if ([self.playerItemsObservers containsObject:playerItem]) {
            [self.playerItem removeObserver:self forKeyPath:__GRPlayerItemKeyPathStatus];
            [self.playerItemsObservers removeObject:playerItem];
        }
    } @catch (NSException *exception) {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:__GRPlayerItemKeyPathStatus]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self.player play];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cacheVideoPlayer:playFail:)]) {
                [self.delegate cacheVideoPlayer:self playFail:YES];
            } 
        }
    }
}

#pragma mark - GRResourceLoadDelegate

- (void)loader:(GRResourceLoader *)loader cacheProgress:(CGFloat)progress {
}

- (void)loader:(GRResourceLoader *)loader failLoadingWithError:(NSError *)error {
}

#pragma mark - enter back ground 

- (void)__addObserver {
    [self __addWillResignActiveNotification];
    [self __addDidResumeFromBackgroundNotification];
} 

- (void)__addWillResignActiveNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)__addDidResumeFromBackgroundNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResumeFromBackground:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)willEnterBackground:(NSNotification *)note {
//    [self pause];
}

- (void)didResumeFromBackground:(NSNotification *)note {
//    [self play];
}

@end
