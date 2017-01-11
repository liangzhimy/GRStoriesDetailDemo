//
//  GRStoryLeftRightTouchView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/10.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRStoryLeftRightTouchView;

typedef NS_ENUM(NSUInteger, GRStoryLeftRightTouchType) {
    GRStoryLeftRightTouchTypeLeft,
    GRStoryLeftRightTouchTypeRight
};

@protocol GRStoryLeftRightTouchViewDelegate <NSObject>

- (void)storyLeftRightTouchView:(GRStoryLeftRightTouchView *)storyLeftRightTouchView touchDirectionType:(GRStoryLeftRightTouchType)touchDirectionType;

@end

@interface GRStoryLeftRightTouchView : UIView

@property (weak, nonatomic) id<GRStoryLeftRightTouchViewDelegate> delegate;
@property (strong, nonatomic, readonly) UITapGestureRecognizer *tapGesturerecognizer; 

@end
