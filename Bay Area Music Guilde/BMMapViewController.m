//
//  BMMapViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/8/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMMapViewController.h"
#import "MKMapView+BM.h"
#import "BMEventStore.h"

@interface BMMapViewController()
@property (strong, nonatomic) UITapGestureRecognizer *navigationBarTapGesture;
@property (strong, nonatomic) UIBarButtonItem *saveButton;
@property (strong, nonatomic) MKAnnotationView *currentAnnotationView;
- (void)navigationBarTapped:(UITapGestureRecognizer*)tapGesture;

@end

@implementation BMMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupWithVenue:self.venue];
    self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveLocation)];
    self.saveButton.enabled = NO;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController.navigationBar addGestureRecognizer:self.navigationBarTapGesture];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController.navigationBar removeGestureRecognizer:self.navigationBarTapGesture];
}


- (UITapGestureRecognizer *)navigationBarTapGesture
{
    if (!_navigationBarTapGesture) {
        _navigationBarTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navigationBarTapped:)];
        _navigationBarTapGesture.numberOfTapsRequired = 2;
    }
    return _navigationBarTapGesture;
}


- (void)setVenue:(BMVenue *)venue
{
    if (_venue == venue) { return; }
    _venue = venue;
    [self setupWithVenue:_venue];
}


- (void)setupWithVenue:(BMVenue *)venue
{
    static BMVenue *currentVenueSetup = nil;
    if (!venue) { return; }
    if (!self.isViewLoaded) { return; }
    if (currentVenueSetup == venue) { return; }
    currentVenueSetup = venue;
    
    self.mapView.mapType = MKMapTypeStandard;
    [self.mapView removeAllAnnotations];
    [self.mapView addAnnotation:venue];
    [self.mapView setCenterCoordinate:venue.coordinate zoomLevel:10 animated:NO];
    self.title = venue.name;
}


#pragma mark - Tap gesture

- (void)navigationBarTapped:(UITapGestureRecognizer*)tapGesture
{
    [UIView animateWithDuration:0.3 animations:^{
        self.searchBar.y = self.searchBar.y == 64 ? 0 : 64;
    }];
}


#pragma mark - MKMapView delegate

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    self.saveButton.enabled = YES;
    self.currentAnnotationView = view;
}


- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    self.currentAnnotationView = nil;
}

#pragma mark - Search Delegate


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchBar.text;
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [self.mapView addAnnotations:[response.mapItems valueForKey:@"placemark"]];
        [self.mapView setRegion:response.boundingRegion animated:YES];
        self.navigationItem.rightBarButtonItem = self.saveButton;
    }];
}


- (void)saveLocation
{
    id<MKAnnotation> annotation = self.currentAnnotationView.annotation;
    CLLocationCoordinate2D coordinate = annotation.coordinate;
    
    if (!CLLocationCoordinate2DIsValid(coordinate)) { return; }
    
    [[BMEventStore sharedStore] updateVenue:self.venue withLatitude:coordinate.latitude longitude:coordinate.longitude success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.saveButton.enabled = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"failed to upload lat and lon" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }];
    
}

@end
