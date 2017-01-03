//
//  GRCacheVideoPlayer.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, GRCacheVideoPlayerState) {
    GRCacheVideoPlayerStateWaiting,
    GRCacheVideoPlayerStatePlaying,
    GRCacheVideoPlayerStatePaused,
    GRCacheVideoPlayerStateStopped,
    GRCacheVideoPlayerStateBuffering,
    GRCacheVideoPlayerStateError
};

@class GRCacheVideoPlayer;

@protocol GRCacheVideoPlayerDelegate <NSObject>

- (void)cacheVideoPlayer:(GRCacheVideoPlayer *)player playProcess:(CGFloat)process;
- (void)cacheVideoPlayer:(GRCacheVideoPlayer *)player playFail:(BOOL)isFail; 

@end


@interface GRCacheVideoPlayer : UIView

@property (weak, nonatomic) id<GRCacheVideoPlayerDelegate> delegate;
@property (assign, nonatomic) GRCacheVideoPlayerState state;

- (void)playWithURL:(NSURL *)videoURL;
- (void)play;
- (void)pause;
- (void)stop;

@end
