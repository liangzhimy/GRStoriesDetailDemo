//
//  GRStoryImageDownloadOpration.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryImageDownloadOpration.h"
#import <SDWebImage/SDWebImageManager.h>

@interface GRStoryImageDownloadOpration () <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>
@property (assign, nonatomic) GRStoryMediaType mediaType;
@property (weak, nonatomic) id<GRStoryMediaDownloadOprationDelegate> delegate;
@property (strong, nonatomic) NSURL *requestURL;
@property (strong, nonatomic) GRVideoCache *cache;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@end

@implementation GRStoryImageDownloadOpration
@synthesize mediaType = _mediaType;
@synthesize executing = _executing;
@synthesize finished = _finished;

- (instancetype)initWithRequest:(NSURL *)requestURL
                      inSession:(NSURLSession *)session
                       delegate:(id<GRStoryMediaDownloadOprationDelegate>)delegate
                     videoCache:(GRVideoCache *)cache
                      mediaType:(GRStoryMediaType)mediaType {
    
    if (self = [super init]) {
        _requestURL = requestURL;
        _delegate = delegate;
        _mediaType = mediaType;
        _cache = cache;
    }
    return self;
}


- (void)start {
    @weakify(self);
    [[SDWebImageManager sharedManager] downloadImageWithURL:self.requestURL options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        @strongify(self);
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(storyMediaDownloadOpration:didCompleteWithError:)]) {
            [self.delegate storyMediaDownloadOpration:self didCompleteWithError:error];
        }
        
        [self done];
    }];
}

- (void)cancel {
    @synchronized (self) {
        [self __cancelInternal];
    }
}

- (void)__cancelInternalAndStop {
    if (self.isFinished) return;
    [self __cancelInternal];
}

- (void)__cancelInternal {
    if (self.isFinished) {
        return;
    }
    
    [super cancel];
}

- (void)reset {
}

- (void)done {
    self.finished = TRUE;
    self.executing = NO;
    [self reset];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

@end
