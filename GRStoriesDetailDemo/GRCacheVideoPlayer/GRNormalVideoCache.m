//
//  GRNormalVideoCache.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRNormalVideoCache.h"
#import "NSString+Md5.h"
#import <UIKit/UIKit.h>

static NSString * const __GRTmpVideoCacheDirName = @"tmpVideoCache";
static NSString * const __GRFileLengthKey = @"fileLength";

@interface GRNormalVideoCache ()

/**
 *  The video cache path, set it in correct context to hit the cache.
 */
@property (nonatomic, copy) NSString *videoCachedDirectoryPath;

/**
 * The maximum length of time to keep an video in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;

/**
 *  The endurance size that cache can hold. If cached size reach it, then all the cache would be cleared.
 */
@property (assign, nonatomic) NSUInteger enduranceSize;

@end

@implementation GRNormalVideoCache

- (instancetype)init {
    if (self = [super init]) {
        [self __config]; 
    }
    return self;
}

- (void)__config {
    // 1 day
    _maxCacheAge = 1 * 24 * 60 * 60;
    // 100m
    _maxCacheSize = 100 * 1024 * 1024;
    // 150m
    _enduranceSize = 150 * 1024 * 1024;
    
    _videoCachedDirectoryPath = [self __videoMediaCacheDirectory];
    [self __createDirectory];
    [self __addObserver];
}

- (void)dealloc {
    [self __removeObserver];
}

- (NSString *)__videoMediaCacheDirectory {
    NSString *tmpDir = [NSTemporaryDirectory() stringByAppendingPathComponent:__GRTmpVideoCacheDirName];
    return tmpDir;
}

- (void)__createDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:self.videoCachedDirectoryPath]) {
        [fileManager createDirectoryAtPath:self.videoCachedDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL {
    NSString *fileName = [videoURL.absoluteString lastPathComponent];
    fileName = [NSString stringWithFormat:@"%@.mp4", [[fileName componentsSeparatedByString:@"."] firstObject].GRMD5String];
    NSString *videoPath = [self.videoCachedDirectoryPath stringByAppendingPathComponent:fileName];
    NSURL *tmpVideoPathURL = [NSURL URLWithString:videoPath];
    return tmpVideoPathURL;
}

- (NSString *)__describeFilePathForVideoURL:(NSURL *)videoURL {
    NSURL *tmpVideoURL = [self tmpVideoPathWithURL:videoURL];
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

#pragma mark - cache
- (NSUInteger)cacheCount {
    NSArray *filelist= [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.videoCachedDirectoryPath error:nil];
    NSUInteger filesCount = [filelist count];
    return filesCount;
}

- (NSUInteger)cacheSize {
    NSArray *filesArray = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:self.videoCachedDirectoryPath error:nil];
    
    __block NSUInteger fileSize = 0;
    [filesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *fileName = obj;
        NSDictionary *fileDictionary = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.videoCachedDirectoryPath stringByAppendingPathComponent:fileName] error:nil];
        fileSize += [fileDictionary fileSize];
    }]; 
    
    return fileSize;
}

- (void)cleanCache {
    [self __eliminateToFixCache];
}

- (void)removeAll {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:self.videoCachedDirectoryPath error:&error];
}

- (void)__eliminateToFixCache {
    NSURL *diskCacheURL = [NSURL fileURLWithPath:self.videoCachedDirectoryPath isDirectory:YES];
    NSArray *resourceKeys = @[NSURLIsDirectoryKey, NSURLContentModificationDateKey, NSURLTotalFileAllocatedSizeKey];
    
    // This enumerator prefetches useful properties for our cache files.
    NSDirectoryEnumerator *fileEnumerator = [[NSFileManager defaultManager] enumeratorAtURL:diskCacheURL
                                                                 includingPropertiesForKeys:resourceKeys
                                                                                    options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                               errorHandler:NULL];
    
    NSDate *expirationDate = [NSDate dateWithTimeIntervalSinceNow:-self.maxCacheAge];
    NSMutableDictionary *cacheFiles = [NSMutableDictionary dictionary];
    NSUInteger currentCacheSize = 0;
    
    // Enumerate all of the files in the cache directory.  This loop has two purposes:
    //
    //  1. Removing files that are older than the expiration date.
    //  2. Storing file attributes for the size-based cleanup pass.
    NSMutableArray *urlsToDelete = [[NSMutableArray alloc] init];
    for (NSURL *fileURL in fileEnumerator) {
        NSDictionary *resourceValues = [fileURL resourceValuesForKeys:resourceKeys error:NULL];
        
        // Skip directories.
        if ([resourceValues[NSURLIsDirectoryKey] boolValue]) {
            continue;
        }
        
        // Remove files that are older than the expiration date;
        NSDate *modificationDate = resourceValues[NSURLContentModificationDateKey];
        if ([[modificationDate laterDate:expirationDate] isEqualToDate:expirationDate]) {
            [urlsToDelete addObject:fileURL];
            continue;
        }
        
        // Store a reference to this file and account for its total size.
        NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
        currentCacheSize += [totalAllocatedSize unsignedIntegerValue];
        [cacheFiles setObject:resourceValues forKey:fileURL];
    }
    
    for (NSURL *fileURL in urlsToDelete) {
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil];
    }
    
    // If our remaining disk cache exceeds a configured maximum size, perform a second
    // size-based cleanup pass.  We delete the oldest files first.
    if (self.maxCacheSize > 0 && currentCacheSize > self.maxCacheSize) {
        // Target half of our maximum cache size for this cleanup pass.
        const NSUInteger desiredCacheSize = self.maxCacheSize / 2;
        
        // Sort the remaining cache files by their last modification time (oldest first).
        NSArray *sortedFiles = [cacheFiles keysSortedByValueWithOptions:NSSortConcurrent
                                                        usingComparator:^NSComparisonResult(id obj1, id obj2) {
                                                            return [obj1[NSURLContentModificationDateKey] compare:obj2[NSURLContentModificationDateKey]];
                                                        }];
        
        // Delete files until we fall below our desired cache size.
        for (NSURL *fileURL in sortedFiles) {
            if ([[NSFileManager defaultManager] removeItemAtURL:fileURL error:nil]) {
                NSDictionary *resourceValues = cacheFiles[fileURL];
                NSNumber *totalAllocatedSize = resourceValues[NSURLTotalFileAllocatedSizeKey];
                currentCacheSize -= [totalAllocatedSize unsignedIntegerValue];
                
                if (currentCacheSize < desiredCacheSize) {
                    break;
                }
            }
        }
    }
}


#pragma mark - Observer
- (void)__enterBackground:(NSNotification *)notification {
    [self cleanCache];
}

- (void)__addObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(__enterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)__removeObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
