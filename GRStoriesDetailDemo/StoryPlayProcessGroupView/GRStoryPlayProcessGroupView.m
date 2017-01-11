//
//  GRStoryPlayProcessGroupView.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 17/1/9.
//  Copyright © 2017年 liangzhimy. All rights reserved.
//

#import "GRStoryPlayProcessGroupView.h"
#import "GRStoryPlayProcessView.h"

static const CGFloat __GRLeftRightMargin = 8.f;
static const CGFloat __GRItemSpace = 5.f;

@interface GRStoryPlayProcessGroupView ()

@property (assign, nonatomic) CGFloat itemWidth; 
@property (assign, nonatomic) NSInteger count;
@property (strong, nonatomic) NSMutableArray<GRStoryPlayProcessView *> *items;
@property (assign, nonatomic, readwrite) NSInteger currentIndex;

@end

@implementation GRStoryPlayProcessGroupView
@synthesize currentIndex = _currentIndex;

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

- (void)__configUI {
    self.leftRightMargin = __GRLeftRightMargin;
    self.itemMargin = __GRItemSpace;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.itemWidth = [self __calulateItemWidthWithCount:self.count];
    NSLog(@"itemWidth : %f", self.itemWidth); 
    CGFloat x = self.leftRightMargin;
    CGFloat y = 0.f;
    CGFloat width = self.itemWidth;
    CGFloat height = self.frame.size.height;
    
    for (NSInteger i = 0; i < self.count; i++) {
        GRStoryPlayProcessView *storyPlayProcessView = self.items[i];
        storyPlayProcessView.frame = CGRectMake(x, y, width, height);
        [storyPlayProcessView layoutSubviews];
        
        x += self.itemMargin + width;
    }
}

#pragma mark - property
- (NSMutableArray<GRStoryPlayProcessView *> *)items {
    if (!_items) {
        _items = [[NSMutableArray alloc] init];
    }
    return _items; 
}

#pragma mark - method
- (void)bindDataWithCount:(NSInteger)count {
    self.count = count;
    self.itemWidth = [self __calulateItemWidthWithCount:count];
    
    for (NSInteger i = 0; i < self.count; i++) {
        GRStoryPlayProcessView *storyPlayProcessView = [[GRStoryPlayProcessView alloc] init];
        [self.items addObject:storyPlayProcessView];
        [self addSubview:storyPlayProcessView];
    }
    
    [self layoutSubviews]; 
}

- (CGFloat)__calulateItemWidthWithCount:(NSInteger)count {
    if (count <= 0) {
        return 0.f; 
    }
    
    CGFloat width = self.frame.size.width;
    CGFloat itemWidth = ((width - self.leftRightMargin * 2) - (count - 1) * self.itemMargin) / count;
    return itemWidth;
} 

- (void)setProcess:(CGFloat)process index:(NSInteger)index {
    if (self.items.count <= index) {
        return;
    }
    
    [self moveToIndex:index];
    
    GRStoryPlayProcessView *storyPlayProcessView = self.items[index];
    storyPlayProcessView.progress = process;
}

- (NSInteger)moveToIndex:(NSInteger)index {
    if (self.items.count <= index) {
        return self.currentIndex;
    }
    
    if (self.currentIndex == index) {
        return self.currentIndex;
    } 
    
    self.currentIndex = index;
    
    for (NSInteger i = 0; i < self.count; i++) {
        GRStoryPlayProcessView *storyPlayProcessView = self.items[i];
        if (i < index) { 
            storyPlayProcessView.progress = 1.f;
        } if (i == index) {
            storyPlayProcessView.progress = 0.f;
        } else if (i > index) {
            storyPlayProcessView.progress = 0.f;
        } 
    }
    [self layoutSubviews];
    return self.currentIndex; 
}

- (NSInteger)moveNext {
    NSInteger maxIndex = MAX(self.count - 1, 0);
    NSInteger needMoveToIndex = MIN(self.currentIndex + 1, maxIndex);
    return [self moveToIndex:needMoveToIndex];
}

- (NSInteger)movePrevious {
    NSInteger needMoveToIndex = MAX(0, self.currentIndex - 1);
    return [self moveToIndex:needMoveToIndex];
}

@end
