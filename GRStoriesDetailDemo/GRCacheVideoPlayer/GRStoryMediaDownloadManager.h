//
//  GRStoryMediaDownloadManager.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRStoryMediaType.h"

@class GRVideoCache; 
@interface GRStoryMediaDownloadManager : NSObject

- (instancetype)initWithCache:(GRVideoCache *)cache; 

- (void)addDownload:(NSURL *)mediaURL type:(GRStoryMediaType)mediaType isCurrent:(BOOL)isCurrent;

@end
