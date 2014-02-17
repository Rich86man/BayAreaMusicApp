//
//  BMMainViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMMainViewController.h"
#import "UIView+CGRectUtils.h"

@implementation BMMainViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    [self addParallaxAndBlur];
    self.navigationController.navigationBarHidden = YES;
    
    self.closeButton.layer.cornerRadius = 5.0;
    self.closeButton.layer.borderColor = self.closeButton.titleLabel.textColor.CGColor;
    self.closeButton.layer.borderWidth = 1.0;
}


- (BMDatesViewController *)datesController
{
    if (!_datesController) {
        _datesController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMDatesViewController"];
        _datesController.eventDelegate = self;
    }
    return _datesController;
}


- (BMArtistsViewController *)artistsController
{
    if (!_artistsController) {
        _artistsController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMArtistsViewController"];
        _artistsController.eventDelegate = self;
    }
    return _artistsController;
}


- (BMVenuesViewController *)venuesController
{
    if(!_venuesController) {
        _venuesController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMVenuesViewController"];
        _venuesController.eventDelegate = self;
    }
    return _venuesController;
}


- (BMEventSummaryViewController *)eventSummaryController
{
    if (!_eventSummaryController) {
        _eventSummaryController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMEventSummaryViewController"];
    }
    return _eventSummaryController;
}


- (UIPanGestureRecognizer *)panGesture
{
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

- (IBAction)datesButtonPressed:(UIButton *)sender
{
    if ([self.childViewControllers containsObject:self.datesController]) { return; }
    [self setSelectedExclusive:sender];
    [self showChildController:self.datesController];
}


- (IBAction)venuesButtonPressed:(UIButton *)sender
{
    if ([self.childViewControllers containsObject:self.artistsController]) { return; }
    [self setSelectedExclusive:sender];
    [self showChildController:self.artistsController];
}


- (IBAction)locationsButtonPressed:(UIButton *)sender
{
    if ([self.childViewControllers containsObject:self.venuesController]) { return; }
    [self setSelectedExclusive:sender];
    [self showChildController:self.venuesController];

}

- (void)addParallaxAndBlur
{
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                                        type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-10);
    verticalMotionEffect.maximumRelativeValue = @(10);
    
    // Set horizontal effect
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                                                          type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-10);
    horizontalMotionEffect.maximumRelativeValue = @(10);
    
    // Create group to combine both
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    // Add both effects to your view
    self.blurView = [[BMBlurredView alloc] initWithFrame:self.backgroundImageView.bounds];
    [self.backgroundImageView addSubview:self.blurView];
    self.blurView.alpha = 0.0f;
    
    [self.backgroundImageView addMotionEffect:group];
    [self.blurView addMotionEffect:group];
}


- (void)showChildController:(UIViewController *)childController
{
    if (self.childViewControllers.count > 0) { [self hideChildControllerAnotherShowing:YES]; }
    
    [self addChildViewController:childController];
    [self.view addSubview:childController.view];
    childController.view.y = self.view.size.height;
    childController.view.height = self.view.height;

    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:.6 initialSpringVelocity:.6 options:0 animations:^{
        childController.view.y = 200;
        self.buttonsView.y = childController.view.y - self.buttonsView.height;
        self.headerView.alpha = 1.0;
        self.logoImageView.alpha = 0.0f;
        self.blurView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        childController.view.height = self.view.height - 200;
        [childController.view addGestureRecognizer:self.panGesture];
    }];
}


- (void)hideChildControllerAnotherShowing:(BOOL)showing
{
    if (self.childViewControllers.count != 1) { return; }
    
    UIViewController *childController = self.childViewControllers[0];
    [childController removeFromParentViewController];
    [UIView animateWithDuration:0.8 delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:.4 options:0 animations:^{
        childController.view.y = self.view.height;
        if (!showing) {
            self.buttonsView.y = self.view.height - self.buttonsView.height - 20;
            self.headerView.alpha = 0.0;
            self.logoImageView.alpha = 1.0f;
            self.blurView.alpha = 0.0f;
            for (UIButton *anotherButton in @[self.datesButton, self.artistsButton, self.venuesButton]) {
                anotherButton.selected = NO;
            }
        }
    } completion:^(BOOL finished) {
        [childController.view removeFromSuperview];
    }];
}


- (IBAction)viewTapped:(UITapGestureRecognizer *)sender
{
    [self hideChildControllerAnotherShowing:NO];
}


- (IBAction)closeButtonTapped:(UIButton *)sender
{
    [self hideChildControllerAnotherShowing:NO];
}


- (void)setSelectedExclusive:(UIButton *)button
{
    for (UIButton *anotherButton in @[self.datesButton, self.artistsButton, self.venuesButton]) {
        anotherButton.selected = anotherButton == button;
    }
}


#pragma mark - BMEventHandlingDelegate

- (void)viewController:(UIViewController *)controller wantsToViewEvent:(BMEvent *)event
{
    BMBlurredView * blurView = [[BMBlurredView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:blurView];
    [blurView redraw];
    [blurView setTag:4567];
    blurView.alpha = 0.0f;
    UIView *theDarkness = [[UIView alloc] initWithFrame:blurView.bounds];
    theDarkness.backgroundColor = [UIColor colorWithWhite:0 alpha:.3];
    theDarkness.userInteractionEnabled = NO;
    [blurView addSubview:theDarkness];
    blurView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEventSummaryViewController:)];
    [blurView addGestureRecognizer:tapRecognizer];
    
    self.eventSummaryController.event = event;
    [self addChildViewController:self.eventSummaryController];
    self.eventSummaryController.view.alpha = 0.0f;
    [self.view addSubview:self.eventSummaryController.view];
    self.eventSummaryController.view.center = self.view.center;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.eventSummaryController.view.alpha = 1.0f;
        blurView.alpha = 1.0f;
    } completion:nil];
}


- (void)hideEventSummaryViewController:(id)sender
{
    BMBlurredView *blurView = (BMBlurredView*)[self.view viewWithTag:4567];
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.eventSummaryController.view.alpha = 0.0f;
        blurView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [blurView removeFromSuperview];
        [self.eventSummaryController.view removeFromSuperview];
        [self.eventSummaryController removeFromParentViewController];
    }];
}



#pragma mark - PanGesture

- (void)handlePanGesture:(UIPanGestureRecognizer*)gestureRecognizer
{
    UIView *controllerView = gestureRecognizer.view;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.view];

    if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        controllerView.y = MAX(MIN(touchPoint.y, 200), 60);
        controllerView.height = MAX(self.view.height - touchPoint.y, self.view.height - 200);
        self.buttonsView.y = controllerView.y - self.buttonsView.height;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat velocity = abs([gestureRecognizer velocityInView:self.view].y) / 10000;
        controllerView.height = touchPoint.y < 130 ? 518 : 568;

        [UIView animateWithDuration:0.4 delay:0.0 usingSpringWithDamping:.7 initialSpringVelocity:velocity options:0 animations:^{
            controllerView.y = touchPoint.y < 130 ? 60 : 200;
            
            self.buttonsView.y = controllerView.y - self.buttonsView.height;
        } completion:^(BOOL finished) {
            controllerView.height = touchPoint.y < 130 ? 518 : 368;
        }];
    
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:gestureRecognizer.view];
    return touchPoint.y < 30;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
