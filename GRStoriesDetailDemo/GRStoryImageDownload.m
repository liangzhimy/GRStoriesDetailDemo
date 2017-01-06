//
//  GRStoryImageDownload.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryImageDownload.h"
#import <SDWebImage/SDWebImageManager.h>

@implementation GRStoryImageDownload

- (void)download:(NSURL *)imageURL completed:(void(^)(UIImage *image, NSError *error, BOOL finished, NSURL *imageURL))block {
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:(SDWebImageHighPriority) progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        if (block) { 
            block(image, error, finished, imageURL);
        } 
    }];
}

- (void)download:(NSURL *)imageURL {
    [self download:imageURL completed:nil]; 
} 

@end
