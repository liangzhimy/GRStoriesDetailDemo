//
//  GRMyStoryDetailViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRMyStoryDetailViewController.h"

@implementation GRStory

@end

@interface GRMyStoryDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *textLabel;

@end

@implementation GRMyStoryDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     self.textLabel.text = [NSString stringWithFormat:@"%ld", (long)self.story.index];
    NSArray *colors = @[[UIColor redColor],
                        [UIColor blueColor],
                        [UIColor greenColor],
                        [UIColor brownColor],
                        [UIColor purpleColor]];
    NSInteger index = (arc4random() % [colors count]);
    self.view.backgroundColor = colors[index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)load:(GRStory *)story {
    self.story = story;
} 

@end
