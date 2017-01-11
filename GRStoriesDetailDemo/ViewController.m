//
//  ViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "ViewController.h"
#import "GRMyStoryDetailViewController.h"
#import "GRVideoDownloadManager.h"

@interface ViewController () <GRCubeViewControllerDelegate>

@property (strong, nonatomic) NSURL *url;
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"videos" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *videoPaths = [content componentsSeparatedByString:@"\n"];
    
    NSInteger i = 0;
    NSMutableArray<GRStory *> *datas = [[NSMutableArray<GRStory *> alloc] init];
    for (NSString *videoPath in videoPaths) {
        if (videoPath.length == 0) {
            continue;
        }
        
        GRStory *story = [[GRStory alloc] init];
        story.index = i;
        story.videoURL = [NSURL URLWithString:videoPath];
        [datas addObject:story];
        i++; 
    }
    
    self.datas = datas;
}

- (void)__bindWithDatas:(NSArray *)array index:(NSInteger)index {
    
} 

- (void)__configViewControllers {
    for (NSInteger i = 0; i < 4; i++) {
        UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GRMyStoryDetailViewController *detailViewController = [mystoryboard instantiateViewControllerWithIdentifier:@"GRMyStoryDetailViewController"];
        GRStory *story = self.datas[i];
        [detailViewController load:story];
        [self addCubeSideForChildController:detailViewController];
        
        if (i == 0) { 
            [[GRVideoDownloadManager shareInstance] addCurrentPlayingDownload:story.videoURL];
        } 
        
        if (i == 0) {
            [detailViewController play];
        } 
    }
    
    [self __preLoadByCurrentViewController:self.childViewControllers[0] index:0];
} 

- (void)__closeSelf {
    NSLog(@"close self");
} 

#pragma mark - GRCubeViewControllerDelegate
- (void)__preLoadByCurrentViewController:(UIViewController *)viewController index:(NSInteger)index {
    GRMyStoryDetailViewController *storyViewController = (GRMyStoryDetailViewController *)viewController;
    if (!storyViewController.story) {
        [self __closeSelf];
        return; 
    } 
    
    NSInteger currentDataIndex = storyViewController.story.index;
    
    NSMutableArray *indexArray = [[NSMutableArray alloc] init];
    
    // min
    NSInteger minIndex = index - 1 < 0 ? self.childViewControllers.count - 1 : index - 1;
    NSInteger minDataIndex = currentDataIndex - 1;
    [indexArray addObject:@[@(minIndex), @(minDataIndex)]];
    
    // max
    for (NSInteger i = index + 1; i <= index + 2; i++) {
        NSInteger viewControllerIndex = i % self.childViewControllers.count;
        NSInteger dataIndex = currentDataIndex + i - index;
        [indexArray addObject:@[@(viewControllerIndex), @(dataIndex)]];
    }
    
    for (NSArray *indexs in indexArray) {
        NSInteger viewControllerIndex = [indexs[0] integerValue];
        NSInteger dataIndex = [indexs[1] integerValue];
        
        NSLog(@"vIndex: %ld, dIndex: %ld", viewControllerIndex, dataIndex);
        GRMyStoryDetailViewController *myStoryViewController = self.childViewControllers[viewControllerIndex];
        
        if (dataIndex < 0 || dataIndex >= self.datas.count) {
            [myStoryViewController removeStory];
            myStoryViewController.view.hidden = TRUE;
            continue;
        }
        
        myStoryViewController.view.hidden = FALSE;
        
        GRStory *story = self.datas[dataIndex];
        [[GRVideoDownloadManager shareInstance] appendDownloadURL:story.videoURL];
        [myStoryViewController load:story];
    }
} 

- (void)cubeViewController:(id)sender willScrollFromViewContoller:(UIViewController *)viewController index:(NSInteger)index {
} 

- (void)cubeViewController:(id)sender didScrollToViewController:(UIViewController *)viewController index:(NSInteger)index {
    [self __preLoadByCurrentViewController:viewController index:index];
    
    GRMyStoryDetailViewController *myStoryViewController = (GRMyStoryDetailViewController *)viewController;
    for (GRMyStoryDetailViewController *detailViewController in self.childViewControllers) {
        if (detailViewController != myStoryViewController) {
            [detailViewController stop];
        } else {
            [detailViewController play];
        }
    }
}

- (BOOL)cubeViewController:(id)sender isValidWithIndex:(NSInteger)index {
    GRMyStoryDetailViewController *myStoryViewController = self.childViewControllers[index];
    if (myStoryViewController.story) {
        return TRUE;
    } else {
        return FALSE;
    } 
} 

- (void)cubeViewController:(id)sender willScrollToValidIndex:(NSInteger)index {
    [self __closeSelf];
}


@end
