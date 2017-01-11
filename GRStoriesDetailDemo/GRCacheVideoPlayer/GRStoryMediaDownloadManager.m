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
@property (strong, nonatomic) NSMutableDictionary<NSString *, GRStoryMediaDownloadOpration *> *oprationDicts;

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

- (void)dealloc {
    [self.session invalidateAndCancel];
    self.session = nil;
    [self.downloadQueue cancelAllOperations];
}

- (void)__config {
    _downloadQueue = [NSOperationQueue new];
    _downloadQueue.maxConcurrentOperationCount = __GRMaxConcurrentOprationCount;
    _downloadQueue.name = __GRDownloadQueueName;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
//     sessionConfig.timeoutIntervalForRequest = _downloadTimeout;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                 delegate:self
                                            delegateQueue:[NSOperationQueue mainQueue]];
}

- (void)addDownload:(NSURL *)mediaURL type:(GRStoryMediaType)mediaType isCurrent:(BOOL)isCurrent {
    if (mediaType == GRStoryMediaTypeImage) {
        GRStoryImageDownloadOpration *opration = [[GRStoryImageDownloadOpration alloc] initWithRequest:mediaURL inSession:self.session delegate:self videoCache:self.videoCache mediaType:mediaType];
        
        if (isCurrent) {
            opration.queuePriority = NSOperationQueuePriorityVeryHigh; 
        }
        
        if (![self oprationForURL:mediaURL]) {
            [self.downloadQueue addOperation:opration];
        } else {
            
        }
        
        [self __adjustDownloadPriorityWithURL:mediaURL isCurrent:isCurrent];
        
    } else if (mediaType == GRStoryMediaTypeVideo) {
        GRStoryImageDownloadOpration *imageDownloadOpration = [[GRStoryImageDownloadOpration alloc] initWithRequest:mediaURL inSession:self.session delegate:self videoCache:self.videoCache mediaType:mediaType];
        imageDownloadOpration.queuePriority = NSOperationQueuePriorityVeryHigh; 
        [self.downloadQueue addOperation:imageDownloadOpration];
        
        [self __adjustDownloadPriorityWithURL:mediaURL isCurrent:isCurrent];
    }
}

- (void)__adjustDownloadPriorityWithURL:(NSURL *)mediaURL isCurrent:(BOOL)isCurrent {
    
}

#pragma mark - oprationDicts
- (NSString *)__keyForDownloadURL:(NSURL *)downloadURL {
    return [downloadURL lastPathComponent];
} 

- (void)__setOpration:(GRStoryMediaDownloadOpration *)opration forURL:(NSURL *)downLoadURL {
    NSString *key = [self __keyForDownloadURL:downLoadURL];
    [self.oprationDicts setObject:opration forKey:key];
}

- (void)__removeOprationForURL:(NSURL *)downloadURL {
    [self.oprationDicts removeObjectForKey:[self __keyForDownloadURL:downloadURL]]; 
} 

- (GRStoryMediaDownloadOpration *)oprationForURL:(NSURL *)downloadURL {
    NSString *key = [self __keyForDownloadURL:downloadURL];
    return self.oprationDicts[key];
}


#pragma mark - property
- (NSMutableDictionary *)oprationDicts {
    if (!_oprationDicts) {
        _oprationDicts = [[NSMutableDictionary alloc] init];
    }
    return _oprationDicts;
} 

#pragma mark - StoryMediaDelegate
- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didReceiveResponse:(NSURLResponse *)response {
}

- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didReceiveData:(NSData *)data {
}

- (void)storyMediaDownloadOpration:(GRStoryMediaDownloadOpration *)opration didCompleteWithError:(NSError *)error {
    [self __removeOprationForURL:opration.mediaURL];
}

@end
