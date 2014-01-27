//
//  BMEventStore.h
//  Bayarea Music Guide
//
//  Created by Captain on 9/21/13.
//  Copyright (c) 2013 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperationManager;

@interface BMEventStore : NSObject
@property (strong, nonatomic) AFHTTPRequestOperationManager* client;

- (void)getEventsWithCompletion:(void (^)(void))completion;

- (void)parseJson:(id)json;
@end
