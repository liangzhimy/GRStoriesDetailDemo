//
//  GRVideoDownloadManager.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/30.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRVideoDownloadManager.h"
#import "GRVideoCache.h"
#import "GRRequestTask.h"
#import "GRCacheVideoFileUtility.h"

static const NSInteger __GRMAXCacheVideoPlayerCount = 3;

@interface GRVideoDownloadManager () <GRRequestTaskDelegate>

@property (strong, nonatomic) NSMutableDictionary <NSString *, GRRequestTask *> *taskDictionary;
@property (strong, nonatomic) NSMutableArray<GRRequestTask *> *tasks;
@property (strong, nonatomic) NSURL *currentURL;

@end

@implementation GRVideoDownloadManager

+ (instancetype)shareInstance {
    static GRVideoDownloadManager *_manager = nil;;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[GRVideoDownloadManager alloc] init];
    });
    return _manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _tasks = [[NSMutableArray alloc] init];
        _taskDictionary = [[NSMutableDictionary alloc] init]; 
    }
    return self; 
}

- (void)__addDownload:(NSURL *)videoURL {
    if ([self.taskDictionary objectForKey:[videoURL absoluteString]]) {
        return;
    }
    
    if ([self.tasks count] >= __GRMAXCacheVideoPlayerCount) {
        for (GRRequestTask *task in self.tasks) {
            if (!self.currentURL) {
                [self __cancelDownloadWithTask:task];
                break; 
            }
            
            if (![task.requestURL.absoluteString isEqualToString:self.currentURL.absoluteString]) {
                [self __cancelDownloadWithTask:task];
                break;
            }
        }
    }
    
    NSURL *tmpFileURL = [[GRVideoCache shareInstance] tmpVideoPathWithURL:videoURL];
    [GRCacheVideoFileUtility createFilePathIfNotExist:[tmpFileURL path]];
    
    NSUInteger fullFileLength = [[GRVideoCache shareInstance] fileLengthForURL:videoURL];
    NSUInteger nowFileLength = [GRCacheVideoFileUtility byteSizeWithFileURL:videoURL];
    if (fullFileLength > 0 && fullFileLength - nowFileLength == 0) {
        return;
    }
   
    GRRequestTask *requestTask = [[GRRequestTask alloc] init];
    requestTask.requestURL = videoURL;
    requestTask.requestOffset = nowFileLength;
    requestTask.cache = YES;
    requestTask.delegate = self;
    [requestTask start];
    
    [self.tasks addObject:requestTask];
    [self.taskDictionary setObject:requestTask forKey:[videoURL absoluteString]];
}

- (void)addCurrentPlayingDownload:(NSURL *)videoURL {
    self.currentURL = videoURL;
    [self __addDownload:videoURL];
}

- (void)appendDownloadURL:(NSURL *)videoURL {
    [self __addDownload:videoURL];
}

- (void)cancelDownload:(NSURL *)videoURL {
    if (!videoURL) {
        return; 
    }
    
    for (GRRequestTask *requestTask in self.tasks) {
        if ([requestTask.requestURL.absoluteString isEqualToString:videoURL.absoluteString]) {
            [self __cancelDownloadWithTask:requestTask];
            break;
        } 
    }
}

- (void)__cancelDownloadWithTask:(GRRequestTask *)requestTask {
    [requestTask cancel];
    [self.tasks removeObject:requestTask];
    [self.taskDictionary removeObjectForKey:[requestTask.requestURL absoluteString]];
}

#pragma mark - Request task delegate
- (void)requestTask:(GRRequestTask *)task didReceiveResponse:(NSURLResponse *)response {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDownloadManager:task:didReceiveResponse:)]) {
        [self.delegate videoDownloadManager:self task:task didReceiveResponse:response]; 
    } 
}

- (void)requestTask:(GRRequestTask *)task didReceiveData:(NSData *)data {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDownloadManager:task:didReceiveData:)]) {
        [self.delegate videoDownloadManager:self task:task didReceiveData:data]; 
    } 
}

- (void)requestTask:(GRRequestTask *)task didFailWithError:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDownloadManager:task:didFailWithError:)]) {
        [self.delegate videoDownloadManager:self task:task didFailWithError:error]; 
    } 
} 

- (void)requestTask:(GRRequestTask *)task didFinishWithSuccess:(BOOL)success {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoDownloadManager:task:didFinishWithSuccess:)]) {
        [self.delegate videoDownloadManager:self task:task didFinishWithSuccess:success];
    } 
}

@end
