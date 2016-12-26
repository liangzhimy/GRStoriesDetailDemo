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

@end

@interface GRMyStoryDetailViewController : UIViewController

@property (strong, nonatomic) GRStory *story;

- (void)load:(GRStory *)story;

@end
