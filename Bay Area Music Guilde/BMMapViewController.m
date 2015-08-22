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
    
    self.appleMapsTabBarItem.image = [[UIImage imageNamed:@"appleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.appleMapsTabBarItem.selectedImage = [[UIImage imageNamed:@"appleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [self.tabBar setItems:@[self.appleMapsTabBarItem] animated:NO];
    }
    
    self.googleMapsTabBarItem.image = [[UIImage imageNamed:@"googleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.googleMapsTabBarItem.image = [[UIImage imageNamed:@"googleIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
#ifndef RELEASE
    [self.navigationController.navigationBar addGestureRecognizer:self.navigationBarTapGesture];
#endif
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
#ifndef RELEASE
    [self.navigationController.navigationBar removeGestureRecognizer:self.navigationBarTapGesture];
#endif
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
    
    [[BMEventStore sharedStore] updateVenue:self.venue withLatitude:coordinate.latitude longitude:coordinate.longitude success:^(id responseObject) {
        self.saveButton.enabled = NO;
    } failure:^( NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"failed to upload lat and lon" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }];
}


#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item == self.appleMapsTabBarItem) { // apple maps
        
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.venue.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem openInMapsWithLaunchOptions:@{MKLaunchOptionsDirectionsModeKey  : MKLaunchOptionsDirectionsModeDriving}];
    } else if (item == self.googleMapsTabBarItem) { // google maps
        NSString *googleMapsURLString = [NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f&directionsmode=driving",[self.venue.latitude floatValue], [self.venue.longitude floatValue]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
    }
}

@end
