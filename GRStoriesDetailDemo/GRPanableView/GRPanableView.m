//
//  GRPanableView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRPanableView.h"
static CGFloat const __GRAnimationDuration = .2;
static CGFloat const __GRVelocityY = 150.f;

@interface GRPanableView () <UIGestureRecognizerDelegate> {
    CGPoint _beginPoint;
    CGPoint _lastPoint;
    BOOL _isAnimating;
    BOOL _isContainerHidden;
}

@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightContraint;
@property (assign, nonatomic) CGFloat height;
@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *panGestureRecognizer;

@end

@implementation GRPanableView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.heightContraint.constant = 0.f;
    _isContainerHidden = TRUE;
    [self __config];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
    }
    return self; 
}

- (void)__config {
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__panGesture:)];
    panGestureRecognizer.delegate = self;
    self.panGestureRecognizer = panGestureRecognizer;
    [self.headView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(__tapGesture:)];
    [self.headView addGestureRecognizer:tapGesture];
} 

- (void)__tapGesture:(UIGestureRecognizer *)gesture {
    [self __containerAnimationHidden:!_isContainerHidden];
}

- (void)__panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            _beginPoint = point;
            _lastPoint = point;
            break;
        } 
        case UIGestureRecognizerStateChanged: {
            if (_isAnimating) {
                return;
            }
            
            CGFloat y = -(point.y - _lastPoint.y);
            CGFloat containerHeight = MIN([self __maxContainerViewHeight], self.heightContraint.constant + y);
            self.heightContraint.constant = containerHeight;
            _lastPoint = point;
            break;
        } 
        case UIGestureRecognizerStateEnded: {
            CGPoint velocity = [gesture velocityInView:self];
            
            if (fabs(velocity.y) > __GRVelocityY) {
                if (velocity.y > 0) {
                    [self __containerAnimationHidden:YES];
                } else {
                    [self __containerAnimationHidden:NO];
                } 
            } else {
                [self __containerAnimationHidden:_isContainerHidden];
            }
            
            _beginPoint = CGPointZero;
            _lastPoint = CGPointZero;
        }
        default: { 
            _beginPoint = CGPointZero; 
            _lastPoint = CGPointZero;
            break;
        } 
    }
}

- (CGFloat)__maxContainerViewHeight {
    return self.frame.size.height - self.headView.frame.size.height;
}

- (void)__containerAnimationHidden:(BOOL)hidden {
    if (_isAnimating) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(panableView:beginAimationWithContentViewHidden:)]) {
        [self.delegate panableView:self beginAimationWithContentViewHidden:hidden];
    } 
    
    if (hidden) {
        _isAnimating = TRUE;
        
        [self layoutIfNeeded];
        [UIView animateWithDuration:__GRAnimationDuration animations:^{
            self.heightContraint.constant = 0.f;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if (finished) {
                _isAnimating = FALSE;
                _isContainerHidden = hidden;
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(panableView:endAimationWithContentViewHidden:)]) {
                    [self.delegate panableView:self endAimationWithContentViewHidden:hidden]; 
                } 
            }
        }];
    } else {
        _isAnimating = TRUE;
        
        [self layoutIfNeeded];
        CGFloat maxContainerViewHeight = [self __maxContainerViewHeight];
        [UIView animateWithDuration:__GRAnimationDuration animations:^{
            self.heightContraint.constant = maxContainerViewHeight;
            [self layoutIfNeeded]; 
        } completion:^(BOOL finished) {
            if (finished) {
                _isAnimating = FALSE;
                _isContainerHidden = hidden;
                 
                if (self.delegate && [self.delegate respondsToSelector:@selector(panableView:endAimationWithContentViewHidden:)]) {
                    [self.delegate panableView:self endAimationWithContentViewHidden:hidden]; 
                } 
            } 
        }];
    } 
}

@end
