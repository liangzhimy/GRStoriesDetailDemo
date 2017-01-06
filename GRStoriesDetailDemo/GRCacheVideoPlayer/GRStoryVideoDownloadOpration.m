//
//  GRStoryVideoDownloadOpration.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/6.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryVideoDownloadOpration.h"
#import "GRVideoCache.h"
#import "GRCacheVideoFileUtility.h"

static NSString * const __GRHeaderField = @"Range";
static const NSTimeInterval __GRRequestTimeout = 10.0;

@interface GRStoryVideoDownloadOpration ()  <NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic, readwrite) NSURLRequest *request;
@property (strong, nonatomic) NSURLSessionDataTask *dataTask;
@property (weak, nonatomic) NSURLSession *unownedSession;
@property (weak, nonatomic) id<GRStoryMediaDownloadOprationDelegate> delegate;
@property (strong, atomic) NSThread *thread;
@property (assign, nonatomic, readwrite) GRStoryMediaType mediaType;
@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (assign, nonatomic) BOOL isSaveLength;
@property (assign, nonatomic) NSUInteger fileLength;
@property (strong, nonatomic) NSURL *requestURL;
@property (strong, nonatomic) GRVideoCache *cache;
@property (assign, nonatomic) NSUInteger cacheLength;

@end

@implementation GRStoryVideoDownloadOpration
@synthesize executing = _executing;
@synthesize finished = _finished;
@synthesize request = _request;
@synthesize mediaType = _mediaType;

- (id)initWithRequest:(NSURL *)requestURL
            inSession:(NSURLSession *)session
             delegate:(id<GRStoryMediaDownloadOprationDelegate>)delegate
           videoCache:(GRVideoCache *)cache
            mediaType:(GRStoryMediaType)mediaType {
    if (self = [super init]) {
        if (!session) {
            return nil;
        }
        
        _requestURL = requestURL;
        _unownedSession = session;
        _delegate = delegate;
        _mediaType = mediaType;
        _cache = cache;
    }
    return self;
}

- (void)start {
    @synchronized (self) {
        NSURL *tmpFileURL = [self.cache tmpVideoPathWithURL:self.requestURL];
        [GRCacheVideoFileUtility createFilePathIfNotExist:[tmpFileURL path]];
        
        NSUInteger fullFileLength = [self.cache fileLengthForURL:self.requestURL];
        NSUInteger nowFileLength = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpFileURL];
        
        if ((fullFileLength > 0) && fullFileLength <= nowFileLength) {
            [self done];
            return;
        }
        
        NSURLSession *session = self.unownedSession;
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:__GRRequestTimeout];
        [request addValue:[NSString stringWithFormat:@"bytes=%ld-", nowFileLength] forHTTPHeaderField:__GRHeaderField];
        self.request = request; 
        
        self.dataTask = [session dataTaskWithRequest:self.request];
        self.executing = YES;
        self.thread = [NSThread currentThread];
    }
    
    [self.dataTask resume];
}

- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(__cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:NO];
        }
        else {
            [self __cancelInternal];
        }
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
    
    if (self.dataTask) {
        [self.dataTask cancel];
        
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    
    [self reset];
}

- (void)reset {
    self.dataTask = nil;
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

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    if (self.isCancelled) {
        return;
    }
    
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        
        NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
        NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
        self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
        
        if (self.fileLength > 0 && !self.isSaveLength) {
            self.isSaveLength = TRUE;
            [self.cache setFileLength:self.fileLength forURL:self.requestURL];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(storyMediaDownloadOpration:didReceiveResponse:)]) {
            [self.delegate storyMediaDownloadOpration:self didReceiveResponse:response];
        }
    } else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        if (code == 304) {
            [self __cancelInternal];
        } else {
            [self.dataTask cancel];
        }
        
        if (self.delegate) {
            [self.delegate storyMediaDownloadOpration:self
                                 didCompleteWithError:[NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil]];
        }
       
        [self done];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.isCancelled) {
        return;
    }
    
    NSURL *tmpFilePath = [self.cache tmpVideoPathWithURL:self.requestURL];
    [GRCacheVideoFileUtility writeFileData:data filePath:tmpFilePath];
    self.cacheLength += data.length;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(storyMediaDownloadOpration:didReceiveData:)]) {
        [self.delegate storyMediaDownloadOpration:self didReceiveData:data];
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    @synchronized(self) {
        self.thread = nil;
        self.dataTask = nil;
    }
    
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(storyMediaDownloadOpration:didCompleteWithError:)]) {
            [self.delegate storyMediaDownloadOpration:self didCompleteWithError:error];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(storyMediaDownloadOpration:didCompleteWithError:)]) {
            [self.delegate storyMediaDownloadOpration:self didCompleteWithError:error];
        }
    }
    
    [self done];
}


@end
