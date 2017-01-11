//
//  GRImagePlayerView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GRStoryPlayerView.h"

@interface GRImagePlayerView : GRStoryPlayerView

@property (strong, nonatomic, readonly) UIImage *image;
@property (strong, nonatomic) UIImage *placeHoldImage;
@property (assign, nonatomic) NSTimeInterval maxTimeInterval;

- (void)playWithURL:(NSURL *)videoURL;

- (void)pause;

@end
