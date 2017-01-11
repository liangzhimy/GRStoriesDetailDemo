//
//  GRStoryViewCountView.h
//  GRStoryPannableViewDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GRArrowViewDirection) {
    GRArrowViewDirectionUp,
    GRArrowViewDirectionDown
};

@interface GRStoryViewCountView : UIView

@property (assign, nonatomic) NSInteger viewCount;
@property (weak, nonatomic, readonly) IBOutlet UIImageView *arrowImageView;

- (void)arrowToDirecotion:(GRArrowViewDirection)direction animation:(BOOL)animation;

@end
