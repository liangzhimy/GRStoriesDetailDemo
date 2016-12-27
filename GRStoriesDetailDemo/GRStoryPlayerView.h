//
//  GRStoryPlayerView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/27.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface GRStoryPlayerView : UIView

@property (strong, nonatomic) AVPlayer *player;

- (void)playerWithURL:(NSURL *)videoURL; 

@end
