//
//  GRMyStoryDetailViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRMyStoryDetailViewController.h"
#import <Masonry/Masonry.h>

#import "GRStoryPlayerView.h"
#import "GRCacheVideoPlayer.h"
#import "GRStoryPanableView.h"
#import "GRStoryPlayProcessGroupView.h"
#import "GRStoryLeftRightTouchView.h"

@implementation GRStory

@end

@interface GRMyStoryDetailViewController () <GRCacheVideoPlayerDelegate, GRStoryLeftRightTouchViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic, readwrite) GRStory *story;
@property (strong, nonatomic) GRCacheVideoPlayer *playerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *othersView;
@property (strong, nonatomic) GRStoryPanableView *storyPanableView;

@property (weak, nonatomic) IBOutlet GRStoryPlayProcessGroupView *headerGroupProcessView;
@property (weak, nonatomic) IBOutlet GRStoryLeftRightTouchView *leftRightTouchView;

@property (assign, nonatomic) NSInteger currentIndex;

@end

@implementation GRMyStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __loadStory];
    [self __configUI]; 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.playerView.frame = self.view.bounds; 
} 

- (void)__configUI {
    GRCacheVideoPlayer *playerView = [[GRCacheVideoPlayer alloc] initWithFrame:self.view.bounds];
    [self.contentView addSubview:playerView];
    self.playerView = playerView;
    
    [self __configPanContainerViewUI];
    
    [self.headerGroupProcessView bindDataWithCount:5];
    
    self.leftRightTouchView.delegate = self; 
}

- (void)__loadStory {
    self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.story.index];
    NSArray *colors = @[[UIColor redColor],
                        [UIColor blueColor],
                        [UIColor greenColor],
                        [UIColor brownColor],
                        [UIColor purpleColor]];
    NSInteger index = (arc4random() % [colors count]);
    self.view.backgroundColor = colors[index];
}

- (void)load:(GRStory *)story {
    self.story = story;
    [self __loadStory];
} 

- (void)removeStory {
    [self.playerView stop]; 
    self.story = nil;
}

- (void)play {
    [self.playerView playWithURL:self.story.videoURL];
    self.playerView.delegate = self; 
}

- (void)stop {
    [self.playerView stop]; 
} 

- (void)pause {
    [self.playerView pause]; 
} 

- (void)__configPanContainerViewUI {
    [self.view layoutIfNeeded];
    [self.othersView layoutIfNeeded];
    [self.othersView addSubview:self.storyPanableView];
    [self.storyPanableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.othersView);
    }];
} 

- (GRStoryPanableView *)storyPanableView {
    if (!_storyPanableView) {
        _storyPanableView = [[GRStoryPanableView alloc] init];
    }
    return _storyPanableView;
}

#pragma mark - GRCacheVideoPlayerDelegate
- (void)cacheVideoPlayer:(GRCacheVideoPlayer *)player playProcess:(CGFloat)process {
    [self.headerGroupProcessView setProcess:process index:self.currentIndex];
}

- (void)cacheVideoPlayer:(GRCacheVideoPlayer *)player playFail:(BOOL)isFail {
}

#pragma mark - GRStoryLeftRightTouchViewDelegate
- (void)storyLeftRightTouchView:(GRStoryLeftRightTouchView *)storyLeftRightTouchView touchDirectionType:(GRStoryLeftRightTouchType)touchDirectionType {
    if (touchDirectionType == GRStoryLeftRightTouchTypeLeft) {
        self.currentIndex = [self.headerGroupProcessView movePrevious];
        [self play];
    } else if (touchDirectionType == GRStoryLeftRightTouchTypeRight) {
        self.currentIndex = [self.headerGroupProcessView moveNext];
        [self play];
    }
}

@end
