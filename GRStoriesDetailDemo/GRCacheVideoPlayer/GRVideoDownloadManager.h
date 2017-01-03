//
//  GRVideoDownloadManager.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/30.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GRRequestTask.h"

@class GRVideoDownloadManager;
@protocol GRVideoDownloadManagerDelegate <NSObject>

- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didReceiveResponse:(NSURLResponse *)response;

- (void)videoDownloadManager:(GRVideoDownloadManager *)manager task:(GRRequestTask *)task didReceiveData:(NSData *)data;

@end

@interface GRVideoDownloadManager : NSObject {
}

@property (weak, nonatomic) id<GRVideoDownloadManagerDelegate> delegate;

+ (instancetype)shareInstance;
- (void)addCurrentPlayingDownload:(NSURL *)videoURL;
- (void)appendDownloadURL:(NSURL *)videoURL;
- (void)cancelDownload:(NSURL *)videoURL; 

@end
