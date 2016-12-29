//
//  GRResourceLoader.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRResourceLoader.h"
#import "GRRequestTask.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "GRCacheVideoFileUtility.h"
#import "GRVideoCache.h"
#import "NSURL+CacheVideoPlayer.h"

static NSString * __GRMimeType = @"video/mp4";

@interface GRResourceLoader () <GRRequestTaskDelegate>

@property (nonatomic, strong) NSMutableArray *requestList;
@property (nonatomic, strong) GRRequestTask *requestTask;

@end

@implementation GRResourceLoader

- (instancetype)init {
    if (self = [super init]) {
        self.requestList = [NSMutableArray array];
    }
    return self; 
} 

- (void)stopLoading {
    [self.requestTask cancel];
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"WaitingLoadingRequest < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"CancelLoadingRequest  < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark - SURequestTaskDelegate
- (void)requestTaskDidUpdateCache {
    [self processRequestList];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength - self.requestTask.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}

- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache {
    self.cacheFinished = cache;
}

- (void)requestTaskDidFailWithError:(NSError *)error {
}

#pragma mark - 处理LoadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList addObject:loadingRequest];
    @synchronized(self) {
        if (self.requestTask) {
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset &&
                loadingRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                [self processRequestList];
            } else {
                
//                NSURL *tmpVideoURL = [loadingRequest.request.URL originalSchemeURL];
//                NSURL *tmpVideoPath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:tmpVideoURL];
//                NSUInteger tmpVideoSize = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpVideoPath];
//                if (loadingRequest.dataRequest.requestedOffset < tmpVideoSize) {
//                    [self __finishLoadinWithLoadingRequest:loadingRequest localCacheLength:tmpVideoSize];
//                }
                
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
//                if (self.seekRequired) {
//                    NSLog(@"Seek操作，则重新请求");
//                    [self __newTaskWithLoadingRequest:loadingRequest cache:NO];
//                }
            }
        } else {
//            [self __newTaskWithLoadingRequest:loadingRequest cache:YES];
            
//            if (isFirstRequest) {
//                [self __newTaskWithLoadingRequest:loadingRequest cache:YES];
//                isFirstRequest = FALSE;
//            } else {
//                NSURL *tmpVideoURL = [loadingRequest.request.URL originalSchemeURL];
//                NSURL *tmpVideoPath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:tmpVideoURL];
//                NSUInteger tmpVideoSize = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpVideoPath];
//                
//                if (loadingRequest.dataRequest.requestedOffset < tmpVideoSize) {
//                    [self __finishLoadinWithLoadingRequest:loadingRequest localCacheLength:tmpVideoSize];
//                }
//            }
            
            NSURL *tmpVideoURL = [loadingRequest.request.URL originalSchemeURL];
            NSURL *tmpVideoPath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:tmpVideoURL];
            NSUInteger tmpVideoSize = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpVideoPath];
            
            if (loadingRequest.dataRequest.currentOffset + loadingRequest.dataRequest.requestedOffset < tmpVideoSize) {
                [self __finishLoadinWithLoadingRequest:loadingRequest localCacheLength:tmpVideoSize];
            } else {
                [self __newTaskWithLoadingRequest:loadingRequest cache:YES];
            }
        }
    }
}

- (void)__newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest
                              cacheSize:(NSUInteger)cacheLength {
    NSUInteger fileLength = 0;
    if (self.requestTask) {
        fileLength = self.requestTask.fileLength;
        [self.requestTask cancel];
    }
    
    self.requestTask = [[GRRequestTask alloc] init];
    self.requestTask.requestURL = [loadingRequest.request.URL originalSchemeURL];
    self.requestTask.requestOffset = cacheLength;
    self.requestTask.cache = YES;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    
    self.requestTask.delegate = self;
    [self.requestTask start];
} 

- (void)__newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cache:(BOOL)cache {
    NSUInteger fileLength = 0;
    
    if (self.requestTask) {
        fileLength = self.requestTask.fileLength;
        [self.requestTask cancel];
    }
    
    self.requestTask = [[GRRequestTask alloc] init];
    self.requestTask.requestURL = [loadingRequest.request.URL originalSchemeURL];
    self.requestTask.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.requestTask.cache = cache;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    
    self.requestTask.delegate = self;
    [self.requestTask start];
//    self.seekRequired = NO;
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

- (void)processRequestList {
    NSMutableArray * finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.requestList) {
        if ([self __finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)__finishLoadinWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest localCacheLength:(NSUInteger)localCacheLength {
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(__GRMimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
//    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    NSUInteger contentLength = [[GRVideoCache shareInstance] fileLengthForURL:[loadingRequest.request.URL originalSchemeURL]];
    loadingRequest.contentInformationRequest.contentLength = contentLength;
    
    NSUInteger cacheLength = localCacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    
    NSUInteger canReadLength = cacheLength - (requestedOffset - 0);
//    NSUInteger canReadLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    NSURL *filePath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:[loadingRequest.request.URL originalSchemeURL]];
    NSUInteger offset = requestedOffset - 0;
    
    NSData *data = [GRCacheVideoFileUtility readTempFileDataWithOffset:offset
                                                                length:respondLength
                                                              filePath:filePath];
    [loadingRequest.dataRequest respondWithData:data];
    
    NSUInteger nowendOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    
    if (nowendOffset >= reqEndOffset) {
        [loadingRequest finishLoading];
        return YES;
    }
    
    return NO;
} 

- (BOOL)__finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(__GRMimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    
    NSUInteger cacheLength = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    
    NSUInteger canReadLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    NSURL *filePath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:self.requestTask.requestURL];
    NSUInteger offset = requestedOffset - self.requestTask.requestOffset;
    
    NSData *data = [GRCacheVideoFileUtility readTempFileDataWithOffset:offset
                                                                length:respondLength
                                                              filePath:filePath];
    [loadingRequest.dataRequest respondWithData:data];
    
    NSUInteger nowEndOffset = requestedOffset + canReadLength;
    NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
    
    if (nowEndOffset >= reqEndOffset) {
        [loadingRequest finishLoading];
        return YES;
    }
    
    return NO;
}

@end
