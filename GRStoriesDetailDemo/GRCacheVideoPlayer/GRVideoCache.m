//
//  GRVideoCache.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRVideoCache.h"
static NSString * const __GRVideoCacheDirName = @"videoCache";
static NSString * const __GRTmpVideoCacheDirName = @"tmpVideoCache";
static NSString * const __GRFileLengthKey = @"fileLength";

@implementation GRVideoCache

+ (GRVideoCache *)shareInstance {
    static GRVideoCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GRVideoCache alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self __createDirectory]; 
    }
    return self;
}

- (void)__createDirectory {
    NSString *videoDir = [NSTemporaryDirectory() stringByAppendingPathComponent:__GRVideoCacheDirName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:videoDir]) {
        [fileManager createDirectoryAtPath:videoDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:__GRTmpVideoCacheDirName];
    
    if (![fileManager fileExistsAtPath:tmpDir]) {
        [fileManager createDirectoryAtPath:tmpDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *videoPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:__GRTmpVideoCacheDirName] stringByAppendingPathComponent:fileName];
    return [NSURL URLWithString:videoPath];
}


- (NSString *)__describeFilePathForVideoURL:(NSURL *)videoURL {
    NSURL  *tmpVideoURL = [self tmpVideoPathWithURL:videoURL];
    NSString *plistFilePath = [tmpVideoURL.absoluteString stringByReplacingOccurrencesOfString:@".mp4" withString:@".plist"];
    return plistFilePath;
} 

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL {
    NSString *plistFilePath = [self __describeFilePathForVideoURL:videoURL];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isPath = FALSE;
    if (![fileManager fileExistsAtPath:plistFilePath isDirectory:&isPath]) {
        NSDictionary *fileDescribeDict = @{__GRFileLengthKey:@(fileLength)};
        [fileDescribeDict writeToFile:plistFilePath atomically:YES];
        return;
    } else {
        NSMutableDictionary *fileDescribeDict = [NSMutableDictionary dictionaryWithContentsOfFile:plistFilePath];
        fileDescribeDict[__GRFileLengthKey] = @(fileLength);
        [fileDescribeDict writeToFile:plistFilePath atomically:YES];
    }
}

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL {
    NSString *plistFilePath = [self __describeFilePathForVideoURL:videoURL];
    
    NSDictionary *fileDescribeDict = [NSDictionary dictionaryWithContentsOfFile:plistFilePath];
    if (fileDescribeDict) {
        return [fileDescribeDict[__GRFileLengthKey] integerValue];
    }
    return 0; 
}

@end
