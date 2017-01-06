//
//  GRVideoCache.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRVideoCache.h"
#import "GRVideoCacheProtocol.h"
#import "GRNormalVideoCache.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/SDImageCache.h>

static NSString * const __GRVideoCacheDirName = @"videoCache";
static NSString * const __GRTmpVideoCacheDirName = @"tmpVideoCache";
static NSString * const __GRFileLengthKey = @"fileLength";

@interface GRVideoCache ()

@property (strong, nonatomic) id <GRVideoCacheProtocol> videoCache;

@end

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
        _videoCache = [[GRNormalVideoCache alloc] init];
    }
    return self;
}

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL {
    return [self.videoCache tmpVideoPathWithURL:videoURL];
}

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL {
    [self.videoCache setFileLength:fileLength forURL:videoURL];
}

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL {
    return [self.videoCache fileLengthForURL:videoURL];
}

//- (void)saveImage:(UIImage *)image forKey:(NSURL *)imageURL {
//    SDImageCache *imageCache = [SDImageCache sharedImageCache];
//    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:imageURL];
//    [[SDImageCache sharedImageCache] storeImage:image forKey:key]; 
//}
//
//- (UIImage *)imageForKey:(NSString *)key {
//}

@end
