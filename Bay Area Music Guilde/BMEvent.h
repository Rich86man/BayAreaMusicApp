//
//  BMEvent.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BMBaseModel.h"

@class BMArtist, BMVenue;

@interface BMEvent : NSManagedObject <BMBaseModel>

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSDate * day;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSString * hour;
@property (nonatomic, retain) NSNumber * pitWarning;
@property (nonatomic, retain) NSNumber * sellOutWarning;
@property (nonatomic, retain) NSNumber * recommendation;
@property (nonatomic, retain) NSNumber * noInOutWarning;
@property (nonatomic, retain) NSSet *artists;
@property (nonatomic, retain) BMVenue *venue;

- (NSString *)artistsString;
- (BOOL)isEqualToEvent:(BMEvent *)event;

@end

@interface BMEvent (CoreDataGeneratedAccessors)

- (void)addArtistsObject:(BMArtist *)value;
- (void)removeArtistsObject:(BMArtist *)value;
- (void)addArtists:(NSSet *)values;
- (void)removeArtists:(NSSet *)values;

@end
