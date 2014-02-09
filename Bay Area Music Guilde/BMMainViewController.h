//
//  BMMainViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMEventStore.h"
#import "BMDatesViewController.h"
#import "BMVenuesViewController.h"
#import "BMArtistsViewController.h"
#import "BMBlurredView.h"
#import <CoreData/CoreData.h>
#import "BMEventHandlingDelegate.h"
#import "BMEventSummaryViewController.h"

@interface BMMainViewController : UIViewController <BMEventHandlingDelegate>
@property (strong, nonatomic) BMEventStore *store;
@property (strong, nonatomic) BMDatesViewController *datesController;
@property (strong, nonatomic) BMArtistsViewController *artistsController;
@property (strong, nonatomic) BMVenuesViewController *venuesController;
@property (strong, nonatomic) BMEventSummaryViewController * eventSummaryController;
@property (weak, nonatomic) IBOutlet UIButton *datesButton;
@property (weak, nonatomic) IBOutlet UIButton *artistsButton;
@property (weak, nonatomic) IBOutlet UIButton *venuesButton;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) BMBlurredView *blurView;

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender;
- (void)hideChildController;
- (void)setSelectedExclusive:(UIButton*)button;
@end
