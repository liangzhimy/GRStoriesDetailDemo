//
//  GRStoryImageDownload.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GRStoryImageDownload : NSObject

- (void)download:(NSURL *)imageURL completed:(void(^)(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL))block;

- (void)download:(NSURL *)imageURL; 

@end
