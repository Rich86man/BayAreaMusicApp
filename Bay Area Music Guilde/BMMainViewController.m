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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.store = [[BMEventStore alloc] init];
    [self.store getEventsWithCompletion:nil];
}

- (BMDatesViewController *)datesController
{
    if (!_datesController) {
        _datesController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMDatesViewController"];
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


- (IBAction)datesButtonPressed:(UIButton *)sender
{
    if ([self.childViewControllers containsObject:self.datesController]) { return; }
    
    [self addChildViewController:self.datesController];
    [self.view addSubview:self.datesController.view];
    self.datesController.view.y = self.view.size.height;
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:.7 initialSpringVelocity:.4 options:0 animations:^{
        self.datesController.view.y = 200;
        self.buttonsView.y = self.datesController.view.y - self.buttonsView.height;
    } completion:nil];
}


- (IBAction)venuesButtonPressed:(UIButton *)sender
{
    
}


- (IBAction)locationsButtonPressed:(UIButton *)sender
{

}


- (void)hideChildController
{
    if (self.childViewControllers.count != 1) { return; }
    
    UIViewController *childController = self.childViewControllers[0];

    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:.7 initialSpringVelocity:.4 options:0 animations:^{
        childController.view.y = self.view.height;
        self.buttonsView.y = self.view.height - self.buttonsView.height;
    } completion:^(BOOL finished) {
        [childController removeFromParentViewController];
        if (childController == self.datesController) {
            _datesController = nil;
        }
    }];
}


- (IBAction)viewTapped:(UITapGestureRecognizer *)sender
{
    [self hideChildController];
}

@end
