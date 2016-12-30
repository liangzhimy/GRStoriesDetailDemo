//
//  GRRequestTask.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRRequestTask.h"
#import "GRVideoCache.h"
#import "GRCacheVideoFileUtility.h"

static const NSTimeInterval __GRRequestTimeout = 10.0;

@interface GRRequestTask ()<NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession * session;
@property (nonatomic, strong) NSURLSessionDataTask * task;
@property (assign, nonatomic) BOOL isCancel;

@end

@implementation GRRequestTask

- (instancetype)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)start {
    NSURL *tmpFileURL = [[GRVideoCache shareInstance] tmpVideoPathWithURL:self.requestURL];
    [GRCacheVideoFileUtility createFilePathIfNotExist:[tmpFileURL path]];
    
    NSUInteger fullFileLength = [[GRVideoCache shareInstance] fileLengthForURL:self.requestURL];
    NSUInteger nowFileLength = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpFileURL];
    
    if ((fullFileLength > 0) && fullFileLength <= nowFileLength) {
        return;
    }
    
    self.requestOffset = nowFileLength;
    
    NSLog(@"requestURL %@", self.requestURL);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:__GRRequestTimeout];
    
    [request addValue:[NSString stringWithFormat:@"bytes=%ld-", self.requestOffset] forHTTPHeaderField:@"Range"];
    self.session = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                    delegate:self
                    delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)cancel {
    self.isCancel = TRUE; 
}

- (void)setCancel:(BOOL)isCancel {
    _isCancel = isCancel;
    
    if (_isCancel) { 
        [self.task cancel];
        [self.session invalidateAndCancel];
    } 
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.isCancel) {
        return;
    }
    
    NSLog(@"=== response: %@",response);
    
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    
    if (self.fileLength > 0) { 
        [[GRVideoCache shareInstance] setFileLength:self.fileLength forURL:self.requestURL];
    } 
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
    
    if (self.delegate) {
        [self.delegate requestTask:self didReceiveResponse:response];
    } 
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.isCancel) {
        return;
    }
    
    NSURL *tmpFilePath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:self.requestURL];
    [GRCacheVideoFileUtility writeFileData:data filePath:tmpFilePath];
    self.cacheLength += data.length;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
    
    if (self.delegate) {
        [self.delegate requestTask:self didReceiveData:data]; 
    } 
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.isCancel) {
        NSLog(@"isCancel");
    } else {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        } else {
            if (self.cache) {
                NSURL *tmpFilePath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:self.requestURL];
                [[GRVideoCache shareInstance] setVideoPath:tmpFilePath forURL:self.requestURL];
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishLoadingWithCache:)]) {
                [self.delegate requestTaskDidFinishLoadingWithCache:self.cache];
            }
        }
    }
}

@end
