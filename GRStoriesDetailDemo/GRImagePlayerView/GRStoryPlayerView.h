//
//  GRStoryPlayerView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRStoryPlayerView;

@protocol GRStoryPlayerViewDelegate <NSObject>

- (void)storyPlayerView:(GRStoryPlayerView *)player playProcess:(CGFloat)process;
- (void)storyPlayerView:(GRStoryPlayerView *)player completionWithError:(NSError *)error; 

@end

@interface GRStoryPlayerView : UIView

@property (weak, nonatomic) id<GRStoryPlayerViewDelegate> delegate; 

- (void)playWithURL:(NSURL *)videoURL;

- (void)pause; 

@end
