//
//  BMEventStore.m
//  Bayarea Music Guide
//
//  Created by Captain on 9/21/13.
//  Copyright (c) 2013 Exactly what it sounds like. All rights reserved.
//

#import "BMEventStore.h"
#import "BMEvent.h"
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
#import "BMArtist.h"
#import "BMVenue.h"
#import "RKCoreDataStore.h"
#import "BMBaseModel.h"
#import "NSDate+BM.h"

static NSString * baseUrl = @"http://nameless-mountain-3360.herokuapp.com";
static NSString * localBaseUrl = @"http://localhost:4567";

@implementation BMEventStore

+ (instancetype)sharedStore
{
    static BMEventStore *_sharedStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedStore = [[[self class] alloc] init];
        
    });
    
    return _sharedStore;
}


- (instancetype)init
{
    self = [super init];
    _parsingQueue = [[NSOperationQueue alloc] init];
    _parsingQueue.maxConcurrentOperationCount = 1;
    return self;
}


- (AFHTTPRequestOperationManager *)client
{
    if(!_client) {
        _client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        _client.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return _client;
}


- (NSDate *)furthestDateStored
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMEvent"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
    request.fetchLimit = 1;
    request.resultType = NSDictionaryResultType;
    
    NSArray *results = [[[RKCoreDataStore sharedStore] managedObjectContext] executeFetchRequest:request error:nil];
    if (results && results.count > 0) {
        return results[0][@"date"];
    }
    return [NSDate date];
}


- (void)getEvents
{
    NSMutableArray *daysToFetch = [NSMutableArray arrayWithCapacity:20];
    NSDate *today = [NSDate date];
    
    // always fetch the upcoming week
    for (int i = 0; i < 7; i++) {
        [daysToFetch addObject:today];
        today = [today oneDayForward];
    }
    
    NSDate *dateToFetch = [self furthestDateStored];
    while ([dateToFetch daysAwayFromToday] < 20) {
        dateToFetch = [dateToFetch oneDayForward];
        [daysToFetch addObject:dateToFetch];
    }
    
    for (NSDate *date in daysToFetch) {
        [self getEventsWithDay:date];
    }
}


- (void)getNextBatchOfDays
{
    if (self.parsingQueue.operationCount > 0) { return; }
    
    NSDate *dateToFetch = [self furthestDateStored];
    
    // fetch 5 more days
    for (int i = 0; i < 5; i++) {
        dateToFetch = [dateToFetch oneDayForward];
        [self getEventsWithDay:dateToFetch];
    }
}


- (void)getEventsWithDay:(NSDate *)date
{
    static NSDateFormatter *eventFetchingDateFormatter = nil;
    if (!eventFetchingDateFormatter) {
        eventFetchingDateFormatter = [[NSDateFormatter alloc] init];
        [eventFetchingDateFormatter setDateFormat:@"MMM-dd"];
    }
    
    NSString *dateString = [eventFetchingDateFormatter stringFromDate:date];
    [self.client GET:@"events" parameters:@{@"date" : dateString} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        BMInsertionOperation *insertionOperation = [[BMInsertionOperation alloc] initWithJsonObject:responseObject];
        [insertionOperation setQueuePriority:NSOperationQueuePriorityHigh];
        [self.parsingQueue addOperation:insertionOperation];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}


- (void)getDeletions
{
    [self.client GET:@"deletions" parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {

        BMDeletionOperation *deletionOperation = [[BMDeletionOperation alloc] initWithJsonObject:responseObject];
        [deletionOperation setQueuePriority:NSOperationQueuePriorityLow];
        [self.parsingQueue addOperation:deletionOperation];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
}


- (void)updateVenue:(BMVenue*)venue
       withLatitude:(double)lat
          longitude:(double)lon
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *route = [NSString stringWithFormat:@"/venues/%i",[venue.serverId intValue]];
    [self.client POST:route parameters:@{@"lat" : @(lat), @"log" : @(lon)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        venue.latitude = @(lat);
        venue.longitude = @(lon);
        [[[RKCoreDataStore sharedStore] managedObjectContext] save:nil];
        success(operation, responseObject);
    } failure:failure];
}


- (void)cleanupOldEvents
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
        NSFetchRequest *eventRequest = [[NSFetchRequest alloc] initWithEntityName:@"BMEvent"];
        eventRequest.predicate = [NSPredicate predicateWithFormat:@"date < %@",[NSDate oneDayAgoFromToday]];
        
        NSArray *oldEvents = [bgContext executeFetchRequest:eventRequest error:nil];
        NSLog(@"deleting %i events",oldEvents.count);
        for (BMEvent *event in oldEvents) {
            for (BMArtist *artist in event.artists) {
                if (artist.events.count <= 1) {
                    [bgContext deleteObject:artist];
                }
            }
            
            if (event.venue.events.count <= 1) {
                [bgContext deleteObject:event.venue];
            }
            
            [bgContext deleteObject:event];
        }
        
        [bgContext save:nil];
    });
}

@end



@implementation BMInsertionOperation

- (instancetype)initWithJsonObject:(id)jsonObject
{
    if (self = [super init]) {
        _jsonObject = jsonObject;
    }
    return self;
}


- (void)main
{
    NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
    
    for (NSDictionary *eventDictionary in self.jsonObject) {
        
        BMEvent *event = [self findOrCreateEventFromDict:eventDictionary withContext:bgContext];
        
        if (eventDictionary[@"venue"]) {
            BMVenue *newVenue = [self findOrCreateVenueFromDict:eventDictionary[@"venue"] withContext:bgContext];
            if(![event.venue isEqualToVenue:newVenue]) {
                NSLog(@"event : %@ got a new Venue : %@",event, newVenue);
                event.venue = newVenue;
            }
        }
        
        for (NSDictionary *artistDict in eventDictionary[@"artists"]) {
            BMArtist *artist = [self findOrCreateArtistFromDict:artistDict withContext:bgContext];
            if (![event.artists containsObject:artist]) {
                NSLog(@"event : %@ got a new Artist : %@",event, artist);
                [event addArtistsObject:artist];
            }
            
        }
    }
    NSError *error = nil;
    [bgContext save:&error];
    if (error) { NSLog(@"Error saving db after parsing : %@", error); }
    else { NSLog(@"SUCCESSFULLY PARSED PAGE OF JSON INTO COREDATA"); }
}


- (BMEvent*)findEventWithServerId:(NSNumber*)serverId andContext:(NSManagedObjectContext*)context
{
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"BMEvent"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) { NSLog(@"Error looking up Event : %@",error); }
    if (results.count >= 1) {
        id <BMBaseModel> object = results[0];
        return object;
    }
    return nil;
}


- (BMEvent *)findOrCreateEventFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
{
    NSNumber* serverId = dict[@"id"];
    BMEvent * event = [self findEventWithServerId:serverId andContext:context];
    
    if (!event) {
        event = [NSEntityDescription insertNewObjectForEntityForName:@"BMEvent" inManagedObjectContext:context];
        NSLog(@"Created new event with serverId : %i", [serverId intValue])
    }
    [event updateWithDictionary:dict];
    return event;
}


- (BMArtist*)findOrCreateArtistFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
{
    NSNumber* serverId = dict[@"id"];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"BMArtist"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) { NSLog(@"Error looking up artist : %@",error); }
    if (results.count >= 1) {
        id <BMBaseModel> object = results[0];
        [object updateWithDictionary:dict];
        return object;
    }
    BMArtist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"BMArtist" inManagedObjectContext:context];
    NSLog(@"Created new artist with serverId : %i", [serverId intValue])
    [artist updateWithDictionary:dict];
    
    return artist;
}


- (BMVenue *)findOrCreateVenueFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
{
    NSNumber* serverId = dict[@"id"];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"BMVenue"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) { NSLog(@"Error looking up venue : %@",error); }
    if (results.count >= 1) {
        id <BMBaseModel> object = results[0];
        [object updateWithDictionary:dict];
        return (BMVenue *)object;
    }
    
    BMVenue *venue = [NSEntityDescription insertNewObjectForEntityForName:@"BMVenue" inManagedObjectContext:context];
    NSLog(@"Created new venue with serverId : %i", [serverId intValue])
    [venue updateWithDictionary:dict];
    
    return venue;
}

@end


@implementation BMDeletionOperation

- (instancetype)initWithJsonObject:(id)jsonObject
{
    if (self = [super init]) {
        _jsonObject = jsonObject;
    }
    return self;
}


- (void)main
{
    NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
    
    NSUInteger canceledEvents = 0;
    for (NSNumber *serverId in self.jsonObject) {
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BMEvent"];
        request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@",serverId];
        NSArray *results = [bgContext executeFetchRequest:request error:nil];
        
        for (BMEvent *event in results) {
            [bgContext deleteObject:event];
            canceledEvents++;
        }
    }

    if (canceledEvents > 0) {
        NSLog(@"deleted %lu canceled events from server",(unsigned long)canceledEvents);
        [bgContext save:nil];
    } else {
        NSLog(@"found no canceled events from server in db");
    }
}

@end


