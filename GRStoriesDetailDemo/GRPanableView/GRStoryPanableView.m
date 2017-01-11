//
//  GRStoryPanableView.m
//  GRStoryPannableViewDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryPanableView.h"
#import "GRPanableView.h"
#import "GRStoryViewCountView.h"
#import <Masonry.h>

@interface GRStoryPanableView () <GRPanableViewDelegate>

@property (strong, nonatomic) GRPanableView *storyPanContainerView;
@property (strong, nonatomic) GRStoryViewCountView *viewCountView;

@end

@implementation GRStoryPanableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self __configUI];
    }
    return self; 
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self __configUI];
    }
    return self; 
} 

- (instancetype)init {
    if (self = [super init]) {
        [self __configUI]; 
    }
    return self; 
}

- (void)__configUI {
    [self addSubview:self.storyPanContainerView];
    [self.storyPanContainerView.headView addSubview:self.viewCountView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.storyPanContainerView.frame = self.bounds;
    [self.storyPanContainerView layoutIfNeeded]; 
    CGRect headBounds = self.storyPanContainerView.headView.bounds;
    self.viewCountView.center = CGPointMake(headBounds.size.width * .5, headBounds.size.height * .5);
} 

#pragma mark - property
- (GRStoryViewCountView *)viewCountView {
    if (!_viewCountView) {
        NSArray *arr = [[NSBundle bundleForClass:[GRStoryViewCountView class]] loadNibNamed:@"GRStoryViewCountView" owner:nil options:nil];
        _viewCountView = [arr lastObject];
    }
    return _viewCountView;
}

- (GRPanableView *)storyPanContainerView {
    if (!_storyPanContainerView) {
        NSArray *arr = [[NSBundle bundleForClass:[GRPanableView class]] loadNibNamed:@"GRPanableView" owner:nil options:nil];
        _storyPanContainerView = [arr lastObject];
        _storyPanContainerView.delegate = self; 
    }
    return _storyPanContainerView;
}

- (UIView *)containerView {
    return self.storyPanContainerView.containerView;
}

- (void)setViewCount:(NSInteger)viewCount {
    _viewCount = viewCount;
    self.viewCountView.viewCount = viewCount; 
}

#pragma mark - GRPanableViewDelegate

- (void)panableView:(GRPanableView *)panableView beginAimationWithContentViewHidden:(BOOL)hidden {
    
}

- (void)panableView:(GRPanableView *)panableView endAimationWithContentViewHidden:(BOOL)hidden {
    if (hidden) {
        [self.viewCountView arrowToDirecotion:GRArrowViewDirectionUp animation:YES];
    }  else {
        [self.viewCountView arrowToDirecotion:GRArrowViewDirectionDown animation:YES];
    }
}

@end
