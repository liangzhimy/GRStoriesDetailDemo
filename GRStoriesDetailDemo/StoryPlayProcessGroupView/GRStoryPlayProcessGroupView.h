//
//  GRStoryPlayProcessGroupView.h
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GRStoryPlayProcessGroupView;

@protocol GRStoryPlayProcessGroupViewDelegate <NSObject>

- (NSInteger)numberOfViews;

@end

@interface GRStoryPlayProcessGroupView : UIView

@property (assign, nonatomic) CGFloat itemMargin;
@property (assign, nonatomic) CGFloat leftRightMargin; 
@property (assign, nonatomic, readonly) NSInteger currentIndex;

- (void)bindDataWithCount:(NSInteger)count;

- (void)setProcess:(CGFloat)process index:(NSInteger)index;

- (NSInteger)moveToIndex:(NSInteger)index;

- (NSInteger)moveNext;

- (NSInteger)movePrevious;

@end
