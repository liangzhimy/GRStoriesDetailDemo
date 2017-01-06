//
//  GRStoryImageDownloadOpration.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryMediaDownloadOpration.h"

#import <SDWebImage/SDWebImageDownloaderOperation.h>

@class GRVideoCache;

@interface GRStoryImageDownloadOpration : GRStoryMediaDownloadOpration

- (instancetype)initWithRequest:(NSURL *)requestURL
            inSession:(NSURLSession *)session
             delegate:(id<GRStoryMediaDownloadOprationDelegate>)delegate
           videoCache:(GRVideoCache *)cache
            mediaType:(GRStoryMediaType)mediaType;

@end
