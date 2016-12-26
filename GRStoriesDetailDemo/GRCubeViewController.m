//
//  GRCubeViewController.m
//  GRStoriesDetailDemo
//
//  Created by liangzhimy on 16/12/26.
//  Copyright © 2016年 liangzhimy. All rights reserved.
//

#import "GRCubeViewController.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat __GRPerspective = -0.001f;
static const CGFloat __GRDuration    =  0.4f;

@interface GRCubeViewController ()

@property (nonatomic)         NSInteger       facingSide;

@property (nonatomic, strong) CADisplayLink  *displayLink;
@property (nonatomic)         CFTimeInterval  startTime;

@property (nonatomic)         CFTimeInterval  animationDuration;
@property (nonatomic)         CGFloat         startAngle;
@property (nonatomic)         CGFloat         targetAngle;

@end

@implementation GRCubeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(__handlePan:)];
    [self.view addGestureRecognizer:pan];
    
    self.facingSide = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Management of cube sides

- (void)addCubeSideForChildController:(UIViewController *)controller {
    double angle = [self.childViewControllers count] * M_PI_2;
    [self addChildViewController:controller];
    controller.view.frame = self.view.bounds;
    controller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:controller.view];
    controller.view.alpha = 0.0;
    [self __rotateCubeSideForViewController:controller
                                  byAngle:angle
                         applyPerspective:YES];
    [controller didMoveToParentViewController:self];
}

- (void)__rotateCubeSideForViewController:(UIViewController *)controller byAngle:(CGFloat)angle applyPerspective:(BOOL)applyPerspective {
    while (angle > M_PI) {
        angle -= (M_PI * 2.0);
    }
    
    if (angle <= -M_PI_2 || angle >= M_PI_2) {
        if (controller.view.alpha != 0.0) {
            controller.view.alpha = 0.0;
            
            if ([controller respondsToSelector:@selector(cubeViewDidHide)]) {
                [(id<GRCubeViewControllerDelegate>)controller cubeViewDidHide];
            }
        }
        return;
    }
    
    double halfWidth = self.view.bounds.size.width / 2.0;
    CGFloat perspective = __GRPerspective;
    CATransform3D transform = CATransform3DIdentity;
    if (applyPerspective) transform.m34 = perspective;
    transform = CATransform3DTranslate(transform, 0, 0, -halfWidth);
    transform = CATransform3DRotate(transform, angle, 0, 1, 0);
    transform = CATransform3DTranslate(transform, 0, 0, halfWidth);
    controller.view.layer.transform = transform;
    
    if (controller.view.alpha == 0.0) {
        controller.view.alpha = 1.0;
        controller.view.frame = controller.view.superview.bounds;
        
        if ([controller respondsToSelector:@selector(cubeViewDidUnhide)]) {
            [(id<GRCubeViewControllerDelegate>)controller cubeViewDidUnhide];
        }
    }
}

- (void)__rotateAllSidesBy:(double)rotation {
    NSInteger count = self.childViewControllers.count;
    [self.childViewControllers enumerateObjectsUsingBlock:^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
        CGFloat startingAngle = ((idx + _facingSide) % count) * M_PI_2;
        
        NSLog(@"__rotateAllSidesBy [%ld]  %f ", (long)idx, startingAngle);
        [self __rotateCubeSideForViewController:controller byAngle:startingAngle+rotation applyPerspective:YES];
    }];
}

#pragma mark - Gesture Recognizer

- (void)__handlePan:(UIPanGestureRecognizer*)gesture {
    CGPoint translation = [gesture translationInView:gesture.view];
    double percentageOfWidth = translation.x / self.view.frame.size.width;
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self __rotateBegin:self.facingSide];
        double rotation = percentageOfWidth * M_PI_2;
        [self __rotateAllSidesBy:rotation];
    } else  if (gesture.state == UIGestureRecognizerStateBegan ||
        gesture.state == UIGestureRecognizerStateChanged) {
        double rotation = percentageOfWidth * M_PI_2;
        [self __rotateAllSidesBy:rotation];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
        gesture.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [gesture velocityInView:gesture.view];
        
        double percentageOfWidthIncludingVelocity = (translation.x + 0.25 * velocity.x) / self.view.frame.size.width;
        self.startAngle = percentageOfWidth * M_PI_2;
        if (translation.x < 0 && percentageOfWidthIncludingVelocity < -0.5) { 
            // if moved left (and/or flicked left)
            self.targetAngle = -M_PI_2;
        } else if (translation.x > 0 && percentageOfWidthIncludingVelocity > 0.5) {
            // if moved right (and/or flicked right)
            self.targetAngle = M_PI_2;
        } else {
            // otherwise, move back to zero
            self.targetAngle = 0.0;
        } 
        
        [self __startDisplayLink];
    }
}

#pragma mark - CADisplayLink

- (void)__startDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
    self.startTime = CACurrentMediaTime();
    self.animationDuration = fabs(self.targetAngle - self.startAngle) / M_PI_2 * __GRDuration;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)__stopDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink {
    CFTimeInterval elapsed = CACurrentMediaTime() - self.startTime;
    CGFloat percentComplete = (elapsed / self.animationDuration);
    
    if (percentComplete >= 0.0 && percentComplete < 1.0) {
        // if animation is still in progress, then update to show progress
        CGFloat rotation = (self.targetAngle - self.startAngle) * percentComplete + self.startAngle;
        [self __rotateAllSidesBy:rotation];
    } else {
        // we are done
        [self __stopDisplayLink];
        NSInteger count = self.childViewControllers.count;
        CGFloat faceAdjustment = self.targetAngle / M_PI_2;
        self.facingSide = (int)floorf(faceAdjustment + self.facingSide + 4.5) % count;
        NSLog(@"facingSide, %ld", self.facingSide);
        [self __rotateFinish:self.facingSide];
        [self __rotateAllSidesBy:0.0];
    }
}

- (void)__rotateBegin:(NSInteger)side {
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = 0; i < count; i++) {
        NSInteger currentIndex  = ((i + _facingSide) % count);
        if (currentIndex == 0) {
            UIViewController *viewController = self.childViewControllers[i];
            [self.delegate cubeViewController:self willScrollFromViewContoller:viewController index:currentIndex];
        }
    }
}

- (void)__rotateFinish:(NSInteger)side {
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = 0; i < count; i++) {
        NSInteger currentIndex  = ((i + _facingSide) % count);
        if (currentIndex == 0) {
            UIViewController *viewController = self.childViewControllers[i];
            [self.delegate cubeViewController:self didScrollToViewController:viewController index:currentIndex];
        } 
    }
}

@end
