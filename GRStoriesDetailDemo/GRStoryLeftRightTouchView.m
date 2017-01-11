//
//  GRStoryLeftRightTouchView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryLeftRightTouchView.h"

@interface GRStoryLeftRightTouchView () <UIGestureRecognizerDelegate>
@property (strong, nonatomic, readwrite) UITapGestureRecognizer *tapGesturerecognizer;
@end

@implementation GRStoryLeftRightTouchView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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

- (instancetype)init {
    if (self = [super init]) {
        [self __config];
    }
    return self;
}

- (void)__config {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__tap:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    tapGestureRecognizer.delegate = self;
    self.tapGesturerecognizer = tapGestureRecognizer;
}

- (void)__tap:(UITapGestureRecognizer *)tapGestureRecognizer {
    switch (tapGestureRecognizer.state) {
        case UIGestureRecognizerStateEnded: {
            CGPoint point = [tapGestureRecognizer locationInView:self];
            CGFloat width = self.frame.size.width;
            GRStoryLeftRightTouchType storyTouchType = GRStoryLeftRightTouchTypeLeft;
            
            if (point.x <= width * .5) {
                storyTouchType = GRStoryLeftRightTouchTypeLeft; 
            } else if (point.x > width * .5) {
                storyTouchType = GRStoryLeftRightTouchTypeRight;
            }
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(storyLeftRightTouchView:touchDirectionType:)]) {
                [self.delegate storyLeftRightTouchView:self touchDirectionType:(storyTouchType)];
            }
            break; 
        } 
        default: { 
            break;
        } 
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return TRUE;
} 

@end
