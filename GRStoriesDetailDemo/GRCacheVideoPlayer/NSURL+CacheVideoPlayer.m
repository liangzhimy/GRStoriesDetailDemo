//
//  NSURL+CacheVideoPlayer.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "NSURL+CacheVideoPlayer.h"

@implementation NSURL (CacheVideoPlayer)

- (NSURL *)customSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"streaming";
    return [components URL];
}

- (NSURL *)originalSchemeURL {
    NSURLComponents *components = [[NSURLComponents alloc] initWithURL:self resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    return [components URL];
}

@end
