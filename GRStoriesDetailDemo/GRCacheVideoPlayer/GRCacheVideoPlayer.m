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
static NSString * const __GRPlayerItemKeyPathTimeRanges = @"loadedTimeRanges";

@interface GRCacheVideoPlayer () <GRResourceLoaderDelegate>

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) GRResourceLoader *resourceLoader;

@end

@implementation GRCacheVideoPlayer

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem) {
        [self __removeObserver:_playerItem];
    }
    _playerItem = playerItem;
}

- (void)playWithURL:(NSURL *)videoURL {
    self.videoURL = videoURL;
    
    if ([self.videoURL.absoluteString hasPrefix:@"http"]) {
        NSURL *cacheFilePath = [[GRVideoCache shareInstance] videoPathWithURL:videoURL];
        if (cacheFilePath) {
            NSURL *localURL = [NSURL URLWithString:[@"file://" stringByAppendingString:cacheFilePath.path]];
            self.playerItem = [AVPlayerItem playerItemWithURL:localURL];
        } else {
            
            self.resourceLoader = [[GRResourceLoader alloc] init];
            self.resourceLoader.videoDownloadManager = [GRVideoDownloadManager shareInstance]; 
            self.resourceLoader.delegate = self;
            
            AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[videoURL customSchemeURL] options:nil];
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        }
    } else {
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    }
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self __addObserver:self.playerItem];
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player pause];
    [self __removeObserver:self.playerItem];
    self.playerItem = nil; 
    self.player = nil;
}

- (void)__playerDidEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
    }];
}

#pragma mark - observer

- (void)__removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)__addObserver:(AVPlayerItem *)playerItem {
    [self.playerItem addObserver:self forKeyPath:__GRPlayerItemKeyPathStatus options:NSKeyValueObservingOptionNew context:nil];
    [self.playerItem addObserver:self forKeyPath:__GRPlayerItemKeyPathTimeRanges options:NSKeyValueObservingOptionNew context:nil];
    
    [self __removeObserver];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__playerDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
}

- (void)__removeObserver:(AVPlayerItem *)playerItem {
    @try {
        [self.playerItem removeObserver:self forKeyPath:__GRPlayerItemKeyPathStatus];
        [self.playerItem removeObserver:self forKeyPath:__GRPlayerItemKeyPathTimeRanges];    
    } @catch (NSException *exception) {
        
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:__GRPlayerItemKeyPathStatus]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self.player play];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
    }
}

#pragma mark - GRResourceLoadDelegate

- (void)loader:(GRResourceLoader *)loader cacheProgress:(CGFloat)progress {
}

- (void)loader:(GRResourceLoader *)loader failLoadingWithError:(NSError *)error {
}

@end
