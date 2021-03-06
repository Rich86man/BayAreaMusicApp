//
//  BMArtist.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/9/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "BMBaseModel.h"

@class BMEvent;

@interface BMArtist : NSManagedObject <BMBaseModel>

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * serverId;
@property (nonatomic, retain) NSString * firstLetterOfName;
@property (nonatomic, retain) NSSet *events;

- (BOOL)isEqualToArtist:(BMArtist*)artist;
- (NSString *)firstLetterOfName;
@end

@interface BMArtist (CoreDataGeneratedAccessors)

- (void)addEventsObject:(BMEvent *)value;
- (void)removeEventsObject:(BMEvent *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
