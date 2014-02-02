//
//  BMVenue.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BMBaseModel.h"
#import <MapKit/MapKit.h>

@class BMEvent;

@interface BMVenue : NSManagedObject <BMBaseModel, MKAnnotation>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *events;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;

- (BOOL)isEqualToVenue:(BMVenue*)venue;

@end

@interface BMVenue (CoreDataGeneratedAccessors)

- (void)addEventsObject:(BMEvent *)value;
- (void)removeEventsObject:(BMEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
