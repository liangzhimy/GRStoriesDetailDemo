//
//  GRVideoCacheProtocol.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GRVideoCacheProtocol <NSObject>
@required

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL;

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL;

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL;

- (void)cleanCache;

- (void)removeAll;

@end
