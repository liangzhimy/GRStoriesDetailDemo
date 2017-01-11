//
//  GRStoryMediaDownloadOpration.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRStoryMediaType.h"

@class GRStoryMediaDownloadOpration; 

@protocol GRStoryMediaDownloadOprationDelegate <NSObject>
@required
- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didReceiveResponse:(NSURLResponse *)response;
- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didReceiveData:(NSData *)data;
- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didCompleteWithError:(NSError *)error;
@end

@interface GRStoryMediaDownloadOpration : NSOperation

@property (strong, nonatomic, readonly) NSURL *mediaURL;
@property (assign, nonatomic, readonly) GRStoryMediaType mediaType;

- (void)cancel; 

@end
