//
//  GRImagePlayerView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRImagePlayerView.h"
#import <SDWebImage/UIImageView+WebCache.h>

static const NSTimeInterval __GRMaxTimeInterval = 3 * 1000;

@interface GRImagePlayerView () {
    NSDate *_beginTime;
} 

@property (strong, nonatomic, readwrite) UIImage *image;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation GRImagePlayerView

- (instancetype)init {
    if (self = [super init]) {
        [self __config];
    }
    return self; 
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __config];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __config]; 
    }
    return self; 
}

- (void)__config {
    UIImageView *imageView = [[UIImageView alloc] init];
    [self addSubview:imageView];
    self.imageView = imageView;
    self.maxTimeInterval = __GRMaxTimeInterval;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.bounds; 
} 

- (void)setImage:(UIImage *)image {
    _image = image; 
} 

- (void)playWithURL:(NSURL *)videoURL {
    [self.imageView sd_setImageWithURL:videoURL placeholderImage:self.placeHoldImage options:(SDWebImageRetryFailed) progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        self.process = process;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self __beginTimer];
    }];
}

- (void)pause {

}

#pragma mark - Timer
- (void)__beginTimer {
    _beginTime = [NSDate date];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(__timeCall) userInfo:nil repeats:YES];
}

- (void)__pauseTimer {
}

- (void)__endTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)__timeCall {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_beginTime];
    if (timeInterval > self.maxTimeInterval) {
        [self __endTimer]; 
    }
    
    CGFloat process = timeInterval / self.maxTimeInterval;
    if (self.delegate && [self.delegate respondsToSelector:@selector(storyPlayerView:playProcess:)]) {
        [self.delegate storyPlayerView:self playProcess:process];
    } 
}

@end
