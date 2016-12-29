//
//  GRResourceLoader.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class GRResourceLoader;
@protocol GRResourceLoaderDelegate <NSObject>

@required
- (void)loader:(GRResourceLoader *)loader cacheProgress:(CGFloat)progress;

@optional
- (void)loader:(GRResourceLoader *)loader failLoadingWithError:(NSError *)error;

@end

@interface GRResourceLoader : NSObject <AVAssetResourceLoaderDelegate>

@property (weak, nonatomic) id<GRResourceLoaderDelegate> delegate;
@property (assign, nonatomic) BOOL cacheFinished;

- (void)stopLoading;

@end
