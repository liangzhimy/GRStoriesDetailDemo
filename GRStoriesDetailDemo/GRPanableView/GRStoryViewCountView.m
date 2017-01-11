//
//  GRStoryViewCountView.m
//  GRStoryPannableViewDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryViewCountView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static CGFloat const __GRCornerRadius = 12.f;
static CGFloat const __GRAnimationDuration = .1f;
static CGFloat const __GRRotateDegress = 180.f;

@interface GRStoryViewCountView ()
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (assign, nonatomic) GRArrowViewDirection direction;
@end

@implementation GRStoryViewCountView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundView.layer.cornerRadius = __GRCornerRadius;
    self.backgroundView.layer.masksToBounds = TRUE;
    self.viewCount = 0; 
}

- (void)setViewCount:(NSInteger)viewCount {
    _viewCount = viewCount;
    
    self.countLabel.text = [NSString stringWithFormat:@"%ld", _viewCount]; 
}

- (void)arrowToDirecotion:(GRArrowViewDirection)direction animation:(BOOL)animation {
    if (self.direction == direction) {
        return; 
    } 
    _direction = direction;
    
    if (animation) {
        [UIView animateWithDuration:__GRAnimationDuration animations:^{
            _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, DEGREES_TO_RADIANS(__GRRotateDegress));
        }];
    } else {
        _arrowImageView.transform = CGAffineTransformRotate(_arrowImageView.transform, DEGREES_TO_RADIANS(__GRRotateDegress));
    }
} 

@end
