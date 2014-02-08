//
//  BMEventSummaryViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BMEvent.h"
#import "BMMapViewController.h"

@interface BMEventSummaryViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) BMEvent *event;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *bandsLabel;
@property (weak, nonatomic) UILabel *errorLabel;
@property (strong, nonatomic) BMMapViewController *mapController;

- (instancetype)initWithEvent:(BMEvent*)event;
- (void)setupWithEvent:(BMEvent*)event;
- (void)setupInitialMapStateWithVenue:(BMVenue*)venue;
- (void)setupNoMapErrorState;
@end
