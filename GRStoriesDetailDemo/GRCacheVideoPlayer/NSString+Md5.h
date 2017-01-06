//
//  NSString+Md5.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/4.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface NSString (Md5)

@property (nonatomic, readonly, copy) NSString *GRMD5String;

@end
