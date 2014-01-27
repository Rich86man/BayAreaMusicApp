//
//  BMEvent.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BMArtist, BMVenue;

@interface BMEvent : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) BMVenue *venue;
@property (nonatomic, retain) NSSet *artists;
@end

@interface BMEvent (CoreDataGeneratedAccessors)

- (void)addArtistsObject:(BMArtist *)value;
- (void)removeArtistsObject:(BMArtist *)value;
- (void)addArtists:(NSSet *)values;
- (void)removeArtists:(NSSet *)values;

@end
