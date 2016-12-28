//
//  GRCacheVideoFileUtility.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRCacheVideoFileUtility : NSObject

+ (void)writeFileData:(NSData *)data filePath:(NSURL *)path;

@end
