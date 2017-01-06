//
//  NSString+Md5.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "NSString+Md5.h"

@implementation NSString (Md5)

- (NSString *)GRMD5String {
    if ([self length] <= 0) {
        return nil;
    }
    
    const char *cStringToHash = [self UTF8String];
    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStringToHash, (CC_LONG)(strlen(cStringToHash)), hash);
    
    NSMutableString *hashString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02X", hash[i]];
    }
    NSString *result = [NSString stringWithString:hashString];
    return result;
}

@end
