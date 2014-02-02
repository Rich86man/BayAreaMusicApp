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
    self.store = [[BMEventStore alloc] init];
    [self.store getEventsWithCompletion:nil];
    [self addParallaxAndBlur];
}

- (BMDatesViewController *)datesController
{
    if (!_datesController) {
        _datesController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMDatesViewController"];
        _datesController.eventDelegate = self;
    }
    return _datesController;
}


- (BMVenuesViewController *)venuesController
{
    if(!_venuesController) {
        _venuesController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMVenuesViewController"];
    }
    return _venuesController;
}


- (BMLocationsViewController *)locationsController
{
    if (!_locationsController) {
        _locationsController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMLocationsViewController"];
    }
    return _locationsController;
}


- (BMEventSummaryViewController *)eventSummaryController
{
    if (!_eventSummaryController) {
        _eventSummaryController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMEventSummaryViewController"];
    }
    return _eventSummaryController;
}


- (IBAction)datesButtonPressed:(UIButton *)sender
{
    if ([self.childViewControllers containsObject:self.datesController]) { return; }
    [self setSelectedExclusive:sender];
    [self addChildViewController:self.datesController];
    [self.view addSubview:self.datesController.view];
    self.datesController.view.y = self.view.size.height;
    [self showChildController:self.datesController];
}


- (IBAction)venuesButtonPressed:(UIButton *)sender
{
    [self setSelectedExclusive:sender];
    [self hideChildController];
    
}


- (IBAction)locationsButtonPressed:(UIButton *)sender
{
    [self setSelectedExclusive:sender];
    [self hideChildController];

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
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:.6 initialSpringVelocity:.6 options:0 animations:^{
        childController.view.y = 200;
        self.buttonsView.y = self.datesController.view.y - self.buttonsView.height;
        self.headerView.alpha = 1.0;
        self.logoImageView.alpha = 0.0f;
        self.blurView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        childController.view.height = self.view.height - 200;
    }];
}


- (void)hideChildController
{
    if (self.childViewControllers.count != 1) { return; }
    
    UIViewController *childController = self.childViewControllers[0];

    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:1 initialSpringVelocity:.4 options:0 animations:^{
        childController.view.y = self.view.height;
        self.buttonsView.y = self.view.height - self.buttonsView.height - 20;
        self.headerView.alpha = 0.0;
        self.logoImageView.alpha = 1.0f;
        self.blurView.alpha = 0.0f;
        for (UIButton *anotherButton in @[self.datesButton, self.artistsButton, self.venuesButton]) {
            anotherButton.selected = NO;
        }
    } completion:^(BOOL finished) {
        [childController.view removeFromSuperview];
        [childController removeFromParentViewController];
    }];
}


- (IBAction)viewTapped:(UITapGestureRecognizer *)sender
{
    [self hideChildController];
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
    blurView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEventSummaryViewController:)];
    [blurView addGestureRecognizer:tapRecognizer];
    
    self.eventSummaryController.event = event;
    [self addChildViewController:self.eventSummaryController];
    
    self.eventSummaryController.view.alpha = 0.0f;
    [self.view addSubview:self.eventSummaryController.view];
    self.eventSummaryController.view.size = CGSizeMake(270, 328);
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

@end
