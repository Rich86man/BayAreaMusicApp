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

static NSString * baseUrl = @"http://nameless-mountain-3360.herokuapp.com";
static NSString * localBaseUrl = @"http://localhost:4567";

@implementation BMEventStore

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
    if (self.client.operationQueue.operationCount > 0 ) {
        return;
    }
    
    [self.client GET:@"events" parameters:Nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseJson:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
    }];

}


// TODO : Do this on a bg queue
- (void)parseJson:(id)json
{
    [[RKCoreDataStore sharedStore] managedObjectContext];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
        
        for (NSDictionary *eventDictionary in json) {

            BMEvent *event = [self findOrCreateEventFromDict:eventDictionary withContext:bgContext];

            if (eventDictionary[@"venue"]) {
                event.venue = [self findOrCreateVenueFromDict:eventDictionary[@"venue"] withContext:bgContext];
            }

            for (NSDictionary *artistDict in eventDictionary[@"artists"]) {
                BMArtist *artist = [self findOrCreateArtistFromDict:artistDict withContext:bgContext];
                [event addArtistsObject:artist];
            }
        }
        NSError *error = nil;
        [bgContext save:&error];
        if (error) { NSLog(@"Error saving db after parsing : %@", error); }
        else { NSLog(@"SUCCESSFULLY PARSED JSON INTO COREDATA"); }
    });
}


- (BMEvent *)findOrCreateEventFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
{
    NSNumber* serverId = dict[@"id"];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"BMEvent"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) { NSLog(@"Error looking up Event : %@",error); }
    if (results.count >= 1) {
        id <BMBaseModel> object = results[0];
        [object updateWithDictionary:dict];
        return object;
    }
    
    BMEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"BMEvent" inManagedObjectContext:context];
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


- (BMVenue*)findOrCreateVenueFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
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
        return object;
    }
    
    BMVenue *venue = [NSEntityDescription insertNewObjectForEntityForName:@"BMVenue" inManagedObjectContext:context];
    [venue updateWithDictionary:dict];
    
    return venue;
}



@end
