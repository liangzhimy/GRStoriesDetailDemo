//
//  GRResourceLoader.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface GRResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

- (void)stopLoading;

@end
