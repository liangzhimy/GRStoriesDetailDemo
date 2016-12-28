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

static NSString * const __GRPlayerItemKeyPathStatus = @"status";
static NSString * const __GRPlayerItemKeyPathTimeRanges = @"loadedTimeRanges";

@interface GRCacheVideoPlayer ()

@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;

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
    [self __removeObserver];
    
    self.videoURL = videoURL;
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    
    if ([self.videoURL.absoluteString hasPrefix:@"http"]) {
        NSURL *cacheFilePath = [GRVideoCache videoPathWithURL:videoURL];
        if (cacheFilePath) {
            self.playerItem = [AVPlayerItem playerItemWithURL:cacheFilePath];
        } else {
            self.resourceLoader = [[SUResourceLoader alloc] init];
            self.resourceLoader.delegate = self;
            
            AVURLAsset * asset = [AVURLAsset URLAssetWithURL:[videoURL customSchemeURL] options:nil];
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
        }
    } else {
        self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    }
    
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
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
    [self.playerItem removeObserver:self forKeyPath:__GRPlayerItemKeyPathStatus];
    [self.playerItem removeObserver:self forKeyPath:__GRPlayerItemKeyPathTimeRanges];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]) {
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self.player play];
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
    }
}

@end
