//
//  GRMyStoryDetailViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRMyStoryDetailViewController.h"
#import "GRStoryPlayerView.h"
#import "GRCacheVideoPlayer.h"

@implementation GRStory

@end

@interface GRMyStoryDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic, readwrite) GRStory *story;
@property (strong, nonatomic) GRCacheVideoPlayer *playerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

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
}

- (void)stop {
    [self.playerView stop]; 
} 

- (void)pause {
    [self.playerView pause]; 
} 

@end
