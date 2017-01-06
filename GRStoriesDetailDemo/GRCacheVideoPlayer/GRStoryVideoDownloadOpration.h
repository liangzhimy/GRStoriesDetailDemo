//
//  GRStoryVideoDownloadOpration.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRStoryMediaDownloadOpration.h"

@class GRVideoCache; 
@interface GRStoryVideoDownloadOpration : GRStoryMediaDownloadOpration

- (id)initWithRequest:(NSURL *)requestURL
            inSession:(NSURLSession *)session
             delegate:(id<GRStoryMediaDownloadOprationDelegate>)delegate
           videoCache:(GRVideoCache *)cache
            mediaType:(GRStoryMediaType)mediaType;

@end
