//
//  GRCacheVideoFileUtility.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRCacheVideoFileUtility.h"

@implementation GRCacheVideoFileUtility

+ (void)writeFileData:(NSData *)data filePath:(NSURL *)path {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:path.path];
    [handle seekToEndOfFile];
    [handle writeData:data];
} 

@end
