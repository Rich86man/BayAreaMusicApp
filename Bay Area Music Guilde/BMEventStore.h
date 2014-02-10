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
@class AFHTTPRequestOperation;

@interface BMEventStore : NSObject
@property (strong, nonatomic) AFHTTPRequestOperationManager* client;

+ (instancetype)sharedStore;

- (void)getEventsWithCompletion:(void (^)(void))completion;

- (void)parseJson:(id)json withCompletion:(void (^)(void))completion;

- (void)updateVenue:(BMVenue*)venue
       withLatitude:(double)lat
          longitude:(double)lon
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
@end
