//
//  BMEventSummaryViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMEventSummaryViewController.h"
#import "BMVenue.h"
#import <QuartzCore/QuartzCore.h>
#import "MKMapView+BM.h"


@implementation BMEventSummaryViewController


- (instancetype)initWithEvent:(BMEvent *)event
{
    if((self = [super init])) {
        _event = event;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupWithEvent:self.event];
    self.containerView.layer.cornerRadius = 15;
    self.mapView.showsBuildings = YES;
    self.mapView.showsPointsOfInterest = YES;
    self.mapView.zoomEnabled = NO;
    self.mapView.scrollEnabled = NO;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupInitialMapStateWithVenue:self.event.venue];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.parentViewController.navigationController setNavigationBarHidden:YES animated:NO];
}


- (void)setEvent:(BMEvent *)event
{
    if (_event == event) { return; }
    _event = event;
    [self setupWithEvent:_event];
}


- (BMMapViewController *)mapController
{
    if (!_mapController) {
        _mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"BMMapViewController"];
    }
    return _mapController;
}


- (void)setupWithEvent:(BMEvent*)event
{
    static BMEvent *currentEventSetup = nil;
    if (!event) { return; }
    if (!self.isViewLoaded) { return; }
    if (currentEventSetup == event) { return; }
    currentEventSetup = event;
    
    if (CLLocationCoordinate2DIsValid(event.venue.coordinate)) {
        [self setupInitialMapStateWithVenue:event.venue];
    } else {
        [self setupNoMapErrorState];
    }
    
    self.venueLabel.text = event.venue.name;
    self.bandsLabel.text = event.artistsString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    self.dateLabel.text = [dateFormatter stringFromDate:event.date];
    if (self.errorLabel) {
        [self.errorLabel removeFromSuperview];
        _errorLabel = nil;
    }
}


- (void)setupInitialMapStateWithVenue:(BMVenue *)venue
{
    self.mapView.mapType = MKMapTypeStandard;
    NSMutableArray *badAnnotations = self.mapView.annotations.mutableCopy;
    [badAnnotations removeObject:venue];
    [self.mapView removeAnnotations:badAnnotations];
    [self.mapView addAnnotation:venue];
    [self.mapView setCenterCoordinate:venue.coordinate zoomLevel:13 animated:NO];
}


- (void)setupNoMapErrorState
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.mapView.frame];
    label.userInteractionEnabled = YES;
    label.text = @"No map data found";
    
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor colorWithWhite:0 alpha:.80];
    [self.mapView addSubview:label];
    self.errorLabel = label;
    
    MKCoordinateRegion sanFranciscoRegion = [MKMapView sanFranciscoCoordinateRegion];
    [self.mapView setRegion:sanFranciscoRegion];
}

- (IBAction)mapViewTapped:(UITapGestureRecognizer *)sender
{
    self.mapController.venue = self.event.venue;
    [self.parentViewController.navigationController pushViewController:self.mapController animated:YES];
}

@end
