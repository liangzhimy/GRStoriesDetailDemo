//
//  GRVideoCache.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRVideoCache : NSObject

+ (GRVideoCache *)shareInstance; 

- (NSURL *)videoPathWithURL:(NSURL *)videoURL;

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL;

- (BOOL)setVideoPath:(NSURL *)path forURL:(NSURL *)videoURL;

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL;

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL;

@end
