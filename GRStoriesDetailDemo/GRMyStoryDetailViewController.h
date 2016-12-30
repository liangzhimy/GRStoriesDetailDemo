//
//  GRMyStoryDetailViewController.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GRStory : NSObject

@property (assign, nonatomic) NSInteger index;
@property (strong, nonatomic) NSURL *videoURL;

@end

@interface GRMyStoryDetailViewController : UIViewController

@property (strong, nonatomic, readonly) GRStory *story;

- (void)load:(GRStory *)story;

- (void)removeStory;

- (void)play;

- (void)pause; 

@end
