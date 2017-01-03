//
//  GRRequestTask.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/28.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRRequestTask;

@protocol GRRequestTaskDelegate <NSObject>
@required
- (void)requestTask:(GRRequestTask *)task didReceiveResponse:(NSURLResponse *)response;
- (void)requestTask:(GRRequestTask *)task didReceiveData:(NSData *)data;
- (void)requestTask:(GRRequestTask *)task didFailWithError:(NSError *)error;
- (void)requestTask:(GRRequestTask *)task didFinishWithSuccess:(BOOL)success;

@end

@interface GRRequestTask : NSObject

@property (weak, nonatomic) id<GRRequestTaskDelegate> delegate;
@property (strong, nonatomic) NSURL * requestURL;
@property (assign, nonatomic) NSUInteger requestOffset;
@property (assign, nonatomic) NSUInteger fileLength;
@property (assign, nonatomic) NSUInteger cacheLength;
@property (assign, nonatomic) BOOL cache;

- (void)start;

- (void)cancel; 

@end
