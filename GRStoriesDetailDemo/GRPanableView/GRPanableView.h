//
//  GRPanableView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRPanableView; 
@protocol GRPanableViewDelegate <NSObject>
@optional
- (void)panableView:(GRPanableView *)panableView beginAimationWithContentViewHidden:(BOOL)hidden;
- (void)panableView:(GRPanableView *)panableView endAimationWithContentViewHidden:(BOOL)hidden;

@end

@interface GRPanableView : UIView

@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic, readonly) IBOutlet UIView *containerView;
@property (weak, nonatomic, readonly) IBOutlet UIView *headView;
@property (weak, nonatomic) id<GRPanableViewDelegate> delegate; 

@end
