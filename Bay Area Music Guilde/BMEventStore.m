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

static NSString * baseUrl = @"http://nameless-mountain-3360.herokuapp.com";
static NSString * localBaseUrl = @"http://localhost:4567";

@implementation BMEventStore

- (AFHTTPRequestOperationManager *)client
{
    if(!_client) {
        _client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:localBaseUrl]];
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

- (BOOL)wordIsAMonth:(NSString*)word
{
    return [word isEqualToString:@"jan"] || [word isEqualToString:@"feb"] || [word isEqualToString:@"mar"] ||
    [word isEqualToString:@"june"] || [word isEqualToString:@"jul"] || [word isEqualToString:@"aug"] ||
    [word isEqualToString:@"sep"] || [word isEqualToString:@"oct"]  || [word isEqualToString:@"nov"] ||
    [word isEqualToString:@"dec"];
}


// TODO : Do this on a bg queue
- (void)parseJson:(id)json
{
    [[RKCoreDataStore sharedStore] managedObjectContext];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        NSManagedObjectContext* bgContext = [[RKCoreDataStore sharedStore] createManagedObjectContext];
        NSFetchRequest *eventFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BMEvent"];
        eventFetchRequest.fetchLimit = 1;

        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZ";
        
        for (NSDictionary* jsonObj in json) {
            NSDictionary* eventDictionary = nil;
            if ([jsonObj isKindOfClass:[NSString class]]) {
                NSString* eventDictString = (NSString*)jsonObj;
                eventDictionary = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:[eventDictString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            } else {
                eventDictionary = jsonObj;
            }
            
            
            NSNumber *serverId = eventDictionary[@"id"];
            eventFetchRequest.predicate = [NSPredicate predicateWithFormat:@"serverId == %@",serverId];
            NSError *error = nil;
            NSArray *results = [bgContext executeFetchRequest:eventFetchRequest error:&error];
            
            if (error) { NSLog(@"Error looking up artist : %@",error); }
            if (results) { continue; }
            
            BMEvent *event = [NSEntityDescription insertNewObjectForEntityForName:@"BMEvent" inManagedObjectContext:bgContext];
            event.serverId = serverId;
            
            if (eventDictionary[@"event_date"]) { event.date = [dateFormatter dateFromString:eventDictionary[@"event_date"]]; }
            if (eventDictionary[@"price"]) { event.price = eventDictionary[@"price"]; }
            if (eventDictionary[@"venue"]) { event.venue = [self findOrCreateVenueFromDict:eventDictionary[@"venue"] withContext:bgContext]; }

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


- (BMArtist*)findOrCreateArtistFromDict:(NSDictionary*)dict withContext:(NSManagedObjectContext*)context
{
    NSNumber* serverId = dict[@"id"];
    
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"BMArtist"];
    request.fetchLimit = 1;
    request.predicate = [NSPredicate predicateWithFormat:@"serverId == %@", serverId];
    
    NSError* error = nil;
    NSArray *results = [context executeFetchRequest:request error:&error];
    
    if (error) { NSLog(@"Error looking up artist : %@",error); }
    if (results) { return results[0]; }
    
    BMArtist *artist = [NSEntityDescription insertNewObjectForEntityForName:@"BMArtist" inManagedObjectContext:context];
    artist.serverId = serverId;
    artist.name = dict[@"name"];
    
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
    if (results) { return results[0]; }
    
    BMVenue *venue = [NSEntityDescription insertNewObjectForEntityForName:@"BMVenue" inManagedObjectContext:context];
    venue.serverId = serverId;
    venue.name = dict[@"name"];
    
    return venue;
}



@end
