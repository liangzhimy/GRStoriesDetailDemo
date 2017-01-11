//
//  GRCubeViewController.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GRCubeViewControllerDelegate <NSObject>
@optional

- (void)cubeViewDidHide;

- (void)cubeViewDidUnhide;

@required

- (void)cubeViewController:(id)sender willScrollFromViewContoller:(UIViewController *)viewController index:(NSInteger)index;

- (void)cubeViewController:(id)sender didScrollToViewController:(UIViewController *)viewController index:(NSInteger)index;

- (BOOL)cubeViewController:(id)sender isValidWithIndex:(NSInteger)index;

- (void)cubeViewController:(id)sender willScrollToValidIndex:(NSInteger)index; 

@end

@interface GRCubeViewController : UIViewController <UIGestureRecognizerDelegate>
@property (weak, nonatomic) id<GRCubeViewControllerDelegate> delegate; 

- (void)addCubeSideForChildController:(UIViewController *)controller;

@end
