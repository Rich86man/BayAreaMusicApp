//
//  BMEventStore.h
//  Bayarea Music Guide
//
//  Created by Captain on 9/21/13.
//  Copyright (c) 2013 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperationManager;
@class BMVenue;
@class BMArtist;
@class BMEvent;
@class AFHTTPRequestOperation;


@interface BMEventStore : NSObject
@property (strong, nonatomic) AFHTTPRequestOperationManager* client;
@property (strong, nonatomic) NSOperationQueue *parsingQueue;

+ (instancetype)sharedStore;
- (void)getEventsWithCompletion:(void (^)(void))completion;
- (void)getNextBatchOfDays;
- (void)updateVenue:(BMVenue*)venue
       withLatitude:(double)lat
          longitude:(double)lon
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)getEventsWithDay:(NSDate *)date;
- (void)getDeletions;
- (NSDate *)furthestDateStored;

@end


@interface BMInsertionOperation : NSOperation
@property (strong, nonatomic) id jsonObject;

- (instancetype)initWithJsonObject:(id)jsonObject;
- (BMVenue *)findOrCreateVenueFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context;
- (BMArtist*)findOrCreateArtistFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context;
- (BMEvent *)findOrCreateEventFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context;
- (BMEvent*)findEventWithServerId:(NSNumber*)serverId andContext:(NSManagedObjectContext*)context;
@end


@interface BMDeletionOperation : NSOperation
@property (strong, nonatomic) id jsonObject;

- (instancetype)initWithJsonObject:(id)jsonObject;

@end


