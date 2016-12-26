//
//  ViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "ViewController.h"
#import "GRMyStoryDetailViewController.h"

@interface ViewController ()

@property (strong, nonatomic) NSMutableArray<GRStory *> *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self __config];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)__config {
    self.delegate = self;
    [self __configData];
    [self __configViewControllers];
} 

- (void)__configData {
    NSMutableArray<GRStory *> *datas = [[NSMutableArray<GRStory *> alloc] init];
    for (NSInteger i = 0; i < 10; i++) {
        GRStory *story = [[GRStory alloc] init];
        story.index = i;
        [datas addObject:story]; 
    }
    
    self.datas = datas; 
}

- (void)__configViewControllers {
    for (NSInteger i = 0; i < 4; i++) {
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GRMyStoryDetailViewController *detailViewController = [mystoryboard instantiateViewControllerWithIdentifier:@"GRMyStoryDetailViewController"];
        GRStory *story = self.datas[i];
        [detailViewController load:story];
        [self addCubeSideForChildController:detailViewController];
    } 
} 

#pragma mark - GRCubeViewControllerDelegate

- (void)cubeViewController:(id)sender willScrollFromViewContoller:(UIViewController *)viewController index:(NSInteger)index {
} 

- (void)cubeViewController:(id)sender didScrollToViewController:(UIViewController *)viewController index:(NSInteger)index { 
    GRMyStoryDetailViewController *storyViewController = (GRMyStoryDetailViewController *)viewController;
    
    NSInteger minIndex = MAX(0, index - 2);
    NSInteger maxIndex = MIN(self.childViewControllers.count - 1, index + 2);
    for (NSInteger i = minIndex; i < maxIndex; i++) {
        if (i == index) {
            continue; 
        }
        
        
    }
    
//    NSInteger index = storyViewController.story.index;
//    GRStory *story = self.datas[index];
}

@end
