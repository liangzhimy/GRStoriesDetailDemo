//
//  GRStoryPlayProcessView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryPlayProcessView.h"

@interface GRStoryPlayProcessView ()

@property (assign, nonatomic) CGFloat progressWidth;
@property (strong, nonatomic) CALayer *bgLayer;
@property (strong, nonatomic) CALayer *backgroundLayer;

@end

@implementation GRStoryPlayProcessView
@synthesize progress = _progress;

- (instancetype)init {
    if (self = [super init]) {
        [self __initCommon]; 
    }
    return self; 
} 

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __initCommon];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __initCommon];
    }
    return self;
}

- (void)__initCommon {
    _progressWidth = 0.f;
    self.layer.cornerRadius = 2.f;
    self.layer.masksToBounds = TRUE; 
    
    CALayer *backgroundLayer = [CALayer layer];
    backgroundLayer.backgroundColor = [UIColor whiteColor].CGColor;
    backgroundLayer.opacity = 0.5;
    _backgroundLayer = backgroundLayer;
    [self.layer insertSublayer:_backgroundLayer atIndex:1];
    self.backgroundColor = [UIColor clearColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundLayer.frame = self.bounds;
    
    if (!self.bgLayer) {
        CALayer *gradientLayer = [CALayer layer];
        gradientLayer.backgroundColor = UIColorFromRGBWithAlpha(0xFFC208, 1.0).CGColor;
        self.bgLayer = gradientLayer;
        
        gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self.layer insertSublayer:gradientLayer above:self.backgroundLayer];
        
        self.progressWidth = _progress * self.frame.size.width;
        self.bgLayer.frame = CGRectMake(0, 0, self.progressWidth, self.bgLayer.bounds.size.height);
    } else {
        self.progressWidth = _progress * self.frame.size.width;
        self.bgLayer.frame = CGRectMake(0, 0, self.progressWidth, self.bgLayer.bounds.size.height);
    }
}

- (void)setProgress:(CGFloat)progress {
    progress = MIN(1.0, progress);
    [self layoutIfNeeded];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _progress = progress;
    self.progressWidth = progress * self.frame.size.width;
    self.bgLayer.frame = CGRectMake(0, 0, self.progressWidth, self.bgLayer.bounds.size.height);
    [CATransaction commit];
}

- (CGRect)progressRectWithView:(UIView *)view {
    return [self convertRect:self.bgLayer.frame toView:view];
}

@end
