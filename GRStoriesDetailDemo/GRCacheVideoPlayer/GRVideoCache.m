//
//  GRVideoCache.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRVideoCache.h"

@implementation GRVideoCache

+ (GRVideoCache *)shareInstance {
    static GRVideoCache *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GRVideoCache alloc] init];
    });
    return instance;
}

- (NSURL *)videoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *videoPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        return [NSURL URLWithString:videoPath];
    }
    return nil; 
}

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject]];
    NSString *videoPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"video"] stringByAppendingPathComponent:fileName];
    return [NSURL URLWithString:videoPath];
}

- (void)setVideoPath:(NSURL *)path forURL:(NSURL *)URL {
    NSURL *url = [self videoPathWithURL:URL];
    // move to url 
    
} 

@end
