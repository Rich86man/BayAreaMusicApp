//
//  BMMapViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/8/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BMVenue.h"

@interface BMMapViewController : UIViewController <UISearchBarDelegate, MKMapViewDelegate>
@property (strong, nonatomic) BMVenue *venue;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
