//
//  BMVenue.m
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMVenue.h"
#import "BMEvent.h"

@implementation BMVenue

@dynamic name;
@dynamic serverId;
@dynamic events;
@dynamic latitude;
@dynamic longitude;

- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.name = dict[@"name"];
    self.serverId = dict[@"id"];
    self.latitude = dict[@"latitude"] != [NSNull null] ? dict[@"latitude"] : @0;
    self.longitude = dict[@"longitude"] != [NSNull null] ? dict[@"longitude"] : @0;
}

// if our server didn't return coordinates, lets intentially make this return an invlalid CLLocationCoordinate2D
// A coordinate is considered invalid if it meets at least one of the following criteria:
// Its latitude is greater than 90 degrees or less than -90 degrees.
// Its longitude is greater than 180 degrees or less than -180 degrees.
// http://stackoverflow.com/questions/21233804/invalid-location-coordinate
- (CLLocationCoordinate2D)coordinate
{
    if ([self.longitude integerValue] == 0 && [self.latitude integerValue] == 0) {
        return CLLocationCoordinate2DMake(91, 181);
    }
    return CLLocationCoordinate2DMake([self.latitude doubleValue], [self.longitude doubleValue]);
}

- (NSString*)title
{
    return self.name;
}


- (BOOL)isEqualToVenue:(BMVenue*)venue
{
    return [self.serverId isEqualToNumber:venue.serverId];
}


@end
