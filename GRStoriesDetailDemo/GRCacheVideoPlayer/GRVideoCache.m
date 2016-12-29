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

- (NSString *)__videoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *videoPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:__GRVideoCacheDirName] stringByAppendingPathComponent:fileName];
//    NSLog(@"__videoPathWithURL: %@ path: %@", videoURL, videoPath);
    return videoPath;
}

- (NSURL *)videoPathWithURL:(NSURL *)videoURL {
    NSString *videoPath = [self __videoPathWithURL:videoURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        return [NSURL URLWithString:videoPath];
    }
    return nil; 
}

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *videoPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:__GRTmpVideoCacheDirName] stringByAppendingPathComponent:fileName];
//    NSLog(@"tmpVideoPathWithURL:%@ %@", videoURL, videoPath);
    return [NSURL URLWithString:videoPath];
}

- (BOOL)setVideoPath:(NSURL *)path forURL:(NSURL *)videoURL {
    return FALSE; 
//    NSURL *destinationFileURL = [NSURL URLWithString:[self __videoPathWithURL:videoURL]];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSError *error = nil;
//    NSLog(@"sourcePath: %@ destPath: %@", path.path, destinationFileURL.path);
//    [fileManager moveItemAtPath:path.path toPath:destinationFileURL.path error:&error]; 
//    NSLog(@"error : %@", error);
//    if (error == nil) {
//        return TRUE;
//    }
//    return FALSE; 
}

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL {
    //TODO : for test, then replace better store 
    [[NSUserDefaults standardUserDefaults] setObject:@(fileLength) forKey:[videoURL absoluteString]];
}

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:[videoURL absoluteString]] unsignedIntegerValue];
} 

@end
