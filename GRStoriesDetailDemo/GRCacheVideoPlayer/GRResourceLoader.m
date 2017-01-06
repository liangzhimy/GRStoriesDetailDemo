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
#import "GRVideoDownloadManager.h"

static NSString * const __GRMimeType = @"video/mp4";
static NSString * const __GRContentLenghtKey = @"__GRContentLength";

@interface GRResourceLoader () <GRVideoDownloadManagerDelegate>

@property (strong, nonatomic) NSMutableArray *requestList;
@property (strong, nonatomic) NSURL *requestURL;
@property (strong, nonatomic) NSMutableDictionary *contentLegthCache;

@end

@implementation GRResourceLoader

- (instancetype)init {
    if (self = [super init]) {
        self.requestList = [NSMutableArray array];
    }
    return self; 
}

- (NSMutableDictionary *)contentLegthCache {
    if (!_contentLegthCache) {
        _contentLegthCache = [[NSMutableDictionary alloc] init];
    }
    return _contentLegthCache;
}

- (NSUInteger)contentLengthWithURL:(NSURL *)videoURL {
    NSString *key = videoURL.absoluteString;
    if (self.contentLegthCache[key]) {
        return [self.contentLegthCache[key] integerValue];
    }
    return 0;
}

- (void)setContentLength:(NSUInteger)contentLength forURL:(NSURL *)videoURL {
    NSString *key = videoURL.absoluteString;
    self.contentLegthCache[key] = @(contentLength);
}

- (void)stopLoading {
    if (self.requestURL) {
        [_videoDownloadManager cancelDownload:self.requestURL];
    } 
}

- (void)setVideoDownloadManager:(GRVideoDownloadManager *)videoDownloadManager {
    _videoDownloadManager = videoDownloadManager;
    _videoDownloadManager.delegate = self;
}

#pragma mark - AVAssetResourceLoaderDelegate
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"@@@ WaitingLoadingRequest < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    self.requestURL = [loadingRequest.request.URL originalSchemeURL];
    [self __addLoadingRequest:loadingRequest];
    return YES;
}

- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"CancelLoadingRequest  < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self removeLoadingRequest:loadingRequest];
}

#pragma mark - LoadingRequest
- (void)__addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList addObject:loadingRequest];
    @synchronized (self) {
        [self __processRequestList];
    }
}

- (void)__processRequestList {
    NSMutableArray * finishRequestList = [NSMutableArray array];
    
    for (AVAssetResourceLoadingRequest * loadingRequest in self.requestList) {
        NSURL *tmpVideoURL = [loadingRequest.request.URL originalSchemeURL];
        NSURL *tmpVideoPath = [[GRVideoCache shareInstance] tmpVideoPathWithURL:tmpVideoURL];
        NSUInteger tmpVideoSize = [GRCacheVideoFileUtility byteSizeWithFileURL:tmpVideoPath];
        
        if (loadingRequest.dataRequest.currentOffset + loadingRequest.dataRequest.requestedOffset < tmpVideoSize) {
            if ([self __finishLoadinWithLoadingRequest:loadingRequest localCacheLength:tmpVideoSize]) {
                [finishRequestList addObject:loadingRequest];
            }
        }
    }
    
    [self.requestList removeObjectsInArray:finishRequestList];
}

- (BOOL)__finishLoadinWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest localCacheLength:(NSUInteger)localCacheLength {
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(__GRMimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    NSURL *requestURL = [loadingRequest.request.URL originalSchemeURL];
    NSUInteger contentLength = [self contentLengthWithURL:requestURL];
    if (contentLength <= 0) {
        contentLength = [[GRVideoCache shareInstance] fileLengthForURL:[loadingRequest.request.URL originalSchemeURL]];
        [self setContentLength:contentLength forURL:requestURL];
    }
    
    loadingRequest.contentInformationRequest.contentLength = contentLength;
    
    NSUInteger cacheLength = localCacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    
    NSUInteger canReadLength = cacheLength - (requestedOffset - 0);
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

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList removeObject:loadingRequest];
}

#pragma mark - GRVideoDownloadManager
- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didReceiveResponse:(NSURLResponse *)response {
}

- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didReceiveData:(NSData *)data {
    if ([task.requestURL.absoluteString isEqualToString:self.requestURL.absoluteString]) {
        [self __processRequestList];
    } 
}

- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didFinishWithSuccess:(BOOL)success {
    if ([task.requestURL.absoluteString isEqualToString:self.requestURL.absoluteString]) {
        [self __processRequestList];
    }
}

- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didFailWithError:(NSError *)error {
    if ([task.requestURL.absoluteString isEqualToString:self.requestURL.absoluteString]) {
    
    }
}

@end
