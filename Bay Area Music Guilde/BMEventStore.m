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

- (void)getEventsWithCompletion:(void (^)(void))completion
{
    static NSDateFormatter *eventFetchingDateFormatter = nil;
    if (!eventFetchingDateFormatter) {
        eventFetchingDateFormatter = [[NSDateFormatter alloc] init];
        [eventFetchingDateFormatter setDateFormat:@"MMM-dd"];
    }
    
    NSMutableArray *daysToFetch = [NSMutableArray arrayWithCapacity:10];
    NSDate *today = [NSDate date];
    
    for (int i = 0; i < 20; i++) {
        [daysToFetch addObject:today];
        today = [today oneDayForward];
    }

    
    for (NSDate *date in daysToFetch) {
        
        NSString *dateString = [eventFetchingDateFormatter stringFromDate:date];
        [self.client GET:@"events" parameters:@{@"date" : dateString} success:^(AFHTTPRequestOperation *operation, id responseObject) {

            [self.parsingQueue addOperationWithBlock:^{
                [self parseJson:responseObject withCompletion:completion];
            }];

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",error);
        }];
    }
    
}


- (void)getEventsWithDay:(NSDate *)date
{



}


- (void)getDeletions
{
    [self.client GET:@"deletions" parameters:nil success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        
        [self.parsingQueue addOperationWithBlock:^{
            NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
            
            NSUInteger canceledEvents = 0;
            for (NSNumber *serverId in responseObject) {
                NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"BMEvent"];
                request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@",serverId];
                NSArray *results = [bgContext executeFetchRequest:request error:nil];
                
                for (BMEvent *event in results) {
                    [bgContext deleteObject:event];
                    canceledEvents++;
                }
            }
            if (canceledEvents > 0) {
                NSLog(@"deleted %i canceled events from server",canceledEvents);
                [bgContext save:nil];
            }
        }];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];
    
}


// TODO : Do this on a bg queue
- (void)parseJson:(id)json withCompletion:(void (^)(void))completion
{
    
    NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
    
    for (NSDictionary *eventDictionary in json) {
        
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
    else { NSLog(@"SUCCESSFULLY PARSED JSON INTO COREDATA"); }
    if (completion) {
        dispatch_async(dispatch_get_main_queue(),^{
            completion();
        });
    }
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
    [venue updateWithDictionary:dict];
    
    return venue;
}


- (void)updateVenue:(BMVenue*)venue
       withLatitude:(double)lat
          longitude:(double)lon
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *route = [NSString stringWithFormat:@"/venues/%i",[venue.serverId integerValue]];
    [self.client POST:route parameters:@{@"lat" : @(lat), @"log" : @(lon)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        venue.latitude = @(lat);
        venue.longitude = @(lon);
        [[[RKCoreDataStore sharedStore] managedObjectContext] save:nil];
        success(operation, responseObject);
    } failure:failure];
}

@end
