//
//  GRNormalVideoCache.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRVideoCacheProtocol.h"

@interface GRNormalVideoCache : NSObject <GRVideoCacheProtocol>

- (NSUInteger)cacheCount;

- (NSUInteger)cacheSize; 

@end
