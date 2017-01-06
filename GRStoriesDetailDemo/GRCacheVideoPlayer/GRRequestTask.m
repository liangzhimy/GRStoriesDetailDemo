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

static NSString * const __GRHeaderField = @"Range";
static const NSTimeInterval __GRRequestTimeout = 10.0;

@interface GRRequestTask ()<NSURLConnectionDataDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSessionDataTask *task;
@property (assign, nonatomic) BOOL isCancel;
@property (assign, nonatomic) BOOL isSaveLength;

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
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.requestURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:__GRRequestTimeout];
    
    [request addValue:[NSString stringWithFormat:@"bytes=%ld-", self.requestOffset] forHTTPHeaderField:__GRHeaderField];
    self.session = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                    delegate:self
                    delegateQueue:[NSOperationQueue mainQueue]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

- (void)cancel {
    self.isCancel = TRUE;
    [self.task cancel];
    [self.session invalidateAndCancel];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    if (self.isCancel) {
        return;
    }
    
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
    NSString *contentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[contentRange componentsSeparatedByString:@"/"] lastObject];
    self.fileLength = fileLength.integerValue > 0 ? fileLength.integerValue : response.expectedContentLength;
    
    if (self.fileLength > 0 && !self.isSaveLength) {
        self.isSaveLength = TRUE;
        [[GRVideoCache shareInstance] setFileLength:self.fileLength forURL:self.requestURL];
    } 
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didReceiveResponse:)]) {
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
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didReceiveData:)]) {
        [self.delegate requestTask:self didReceiveData:data]; 
    } 
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (!self.isCancel) {
        if (error) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didFailWithError:)]) {
                [self.delegate requestTask:self didFailWithError:error]; 
            } 
        } else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTask:didFinishWithSuccess:)]) {
                [self.delegate requestTask:self didFinishWithSuccess:TRUE];
            }
        }
    }
}

@end
