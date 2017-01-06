//
//  GRStoryMediaDownloadManager.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryMediaDownloadManager.h"
#import "GRStoryVideoDownloadOpration.h"
#import "GRStoryImageDownloadOpration.h"
#import "GRVideoCache.h"

static const NSInteger __GRMaxConcurrentOprationCount = 4;
static NSString * const __GRDownloadQueueName = @"com.stories.media";

@interface GRStoryMediaDownloadManager () <NSURLSessionDelegate, GRStoryMediaDownloadOprationDelegate>

@property (strong, nonatomic) NSOperationQueue *downloadQueue;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) GRVideoCache *videoCache;

@end

@implementation GRStoryMediaDownloadManager

- (instancetype)initWithCache:(GRVideoCache *)cache {
    if (self = [super init]) {
        _videoCache = cache;
        [self __config];
    }
    return self; 
}

- (instancetype)init {
    if (self = [super init]) {
        [self __config]; 
    }
    return self;
}

- (void)__config {
    _downloadQueue = [NSOperationQueue new];
    _downloadQueue.maxConcurrentOperationCount = __GRMaxConcurrentOprationCount;
    _downloadQueue.name = __GRDownloadQueueName;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    //        sessionConfig.timeoutIntervalForRequest = _downloadTimeout;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
}

- (void)addDownload:(NSURL *)mediaURL type:(GRStoryMediaType)mediaType isCurrent:(BOOL)isCurrent {
    if (mediaType == GRStoryMediaTypeImage) {
        [self __adjustDownloadPriorityWithURL:mediaURL isCurrent:isCurrent];
        
        GRStoryImageDownloadOpration *opration = [[GRStoryImageDownloadOpration alloc] initWithRequest:mediaURL inSession:self.session delegate:self videoCache:self.videoCache mediaType:mediaType];
        
        if (isCurrent) {
            opration.queuePriority = NSOperationQueuePriorityVeryHigh; 
        }
        
        [self.downloadQueue addOperation:opration];
    } else if (mediaType == GRStoryMediaTypeVideo) {
        [self __adjustDownloadPriorityWithURL:mediaURL isCurrent:isCurrent];
        
        GRStoryImageDownloadOpration *imageDownloadOpration = [[GRStoryImageDownloadOpration alloc] initWithRequest:mediaURL inSession:self.session delegate:self videoCache:self.videoCache mediaType:mediaType];
        [self.downloadQueue addOperation:imageDownloadOpration];
    }
}

- (void)__adjustDownloadPriorityWithURL:(NSURL *)mediaURL isCurrent:(BOOL)isCurrent {
    
} 

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.downloadQueue cancelAllOperations];
}

- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didReceiveResponse:(NSURLResponse *)response {
}

- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opratio didReceiveData:(NSData *)data {
}

- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opratio didCompleteWithError:(NSError *)error {
}

@end
