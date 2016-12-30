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

@interface GRVideoDownloadManager () <GRRequestTaskDelegate>

@property (strong, nonatomic) NSMutableDictionary <NSString *, GRRequestTask *> *taskDictionary;
@property (strong, nonatomic) NSMutableArray<GRRequestTask *> *tasks;

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


- (void)addDownload:(NSURL *)videoURL {
    if ([self.taskDictionary objectForKey:[videoURL absoluteString]]) {
        return;
    }
    
    static const NSInteger __GRMAXCacheVideoPlayerCount = 4;
    
    if ([self.tasks count] >= __GRMAXCacheVideoPlayerCount) {
        GRRequestTask *requestTask = self.tasks.firstObject;
        [self.tasks removeObject:requestTask];
        [self.taskDictionary removeObjectForKey:[requestTask.requestURL absoluteString]];
        [requestTask cancel];
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
    requestTask.requestOffset = 0;
    requestTask.cache = YES;
    requestTask.delegate = self;
    [requestTask start];
    
    [self.tasks addObject:requestTask];
    [self.taskDictionary setObject:requestTask forKey:[videoURL absoluteString]];
}

- (void)appendDownloadURL:(NSURL *)videoURL {
    [self addDownload:videoURL]; 
}

#pragma mark - Request task delegate
- (void)requestTask:(GRRequestTask *)task didReceiveResponse:(NSURLResponse *)response {
    if (self.delegate) {
        [self.delegate videoDownloadManager:self task:task didReceiveResponse:response]; 
    } 
}

- (void)requestTask:(GRRequestTask *)task didReceiveData:(NSData *)data {
    if (self.delegate) {
        [self.delegate videoDownloadManager:self task:task didReceiveData:data]; 
    } 
}

- (void)requestTaskDidUpdateCache {
}

@end
