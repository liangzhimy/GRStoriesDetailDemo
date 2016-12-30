//
//  GRCacheVideoFileUtility.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRCacheVideoFileUtility.h"

@implementation GRCacheVideoFileUtility

+ (BOOL)createFilePathIfNotExist:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = FALSE;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDir]) {
        [fileManager createFileAtPath:filePath contents:nil attributes:nil];
        return TRUE;
    }
    return FALSE;
} 

+ (void)writeFileData:(NSData *)data filePath:(NSURL *)path {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:path.path];
    [handle seekToEndOfFile];
    [handle writeData:data];
} 

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length filePath:(NSURL *)path {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:path.path];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (NSUInteger)byteSizeWithFileURL:(NSURL *)fileURL {
    uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:nil] fileSize];
    return fileSize;
}

@end
