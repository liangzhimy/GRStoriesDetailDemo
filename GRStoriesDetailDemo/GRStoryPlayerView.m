//
//  GRStoryPlayerView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/27.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRStoryPlayerView.h"
#import <AVFoundation/AVFoundation.h>

static NSString * const __GRPlayerItemKeyPathStatus = @"status";
static NSString * const __GRPlayerItemKeyPathTimeRanges = @"loadedTimeRanges";

@interface GRStoryPlayerView ()

@property (strong, nonatomic) AVPlayerItem *playerItem;

@end

@implementation GRStoryPlayerView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)dealloc {
}

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

- (void)playerWithURL:(NSURL *)videoURL {
    self.playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    [self __addObserver:self.playerItem];
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
            NSLog(@"AVPlayerStatusReadyToPlay");
//            self.stateButton.enabled = YES;
//            CMTime duration = self.playerItem.duration;// 获取视频总长度
//            CGFloat totalSecond = playerItem.duration.value / playerItem.duration.timescale;// 转换成秒
//            _totalTime = [self convertTime:totalSecond];// 转换成播放时间
//            [self customVideoSlider:duration];// 自定义UISlider外观
//            NSLog(@"movie total duration:%f",CMTimeGetSeconds(duration));
//            [self monitoringPlayback:self.playerItem];// 监听播放状态
        } else if ([playerItem status] == AVPlayerStatusFailed) {
            NSLog(@"AVPlayerStatusFailed");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
//        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
//        NSLog(@"Time Interval:%f",timeInterval);
//        CMTime duration = _playerItem.duration;
//        CGFloat totalDuration = CMTimeGetSeconds(duration);
//        [self.videoProgress setProgress:timeInterval / totalDuration animated:YES];
    }
}

@end
