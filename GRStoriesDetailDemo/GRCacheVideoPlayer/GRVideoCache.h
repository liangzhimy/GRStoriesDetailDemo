//
//  GRVideoCache.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface GRVideoCache : NSObject

+ (GRVideoCache *)shareInstance; 

- (NSURL *)tmpVideoPathWithURL:(NSURL *)videoURL;

- (NSUInteger)fileLengthForURL:(NSURL *)videoURL;

- (void)setFileLength:(NSUInteger)fileLength forURL:(NSURL *)videoURL;

//- (void)saveImage:(UIImage *)image forKey:(NSString *)key;
//
//- (UIImage *)imageForKey:(NSString *)key; 
//
@end
