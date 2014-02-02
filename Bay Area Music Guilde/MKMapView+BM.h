//
//  MKMapView+BM.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (BM)

+ (MKCoordinateRegion)sanFranciscoCoordinateRegion;
- (void)removeAllAnnotations;
@end

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;
@end
