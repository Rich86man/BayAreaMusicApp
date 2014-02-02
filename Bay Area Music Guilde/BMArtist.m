//
//  BMArtist.m
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMArtist.h"
#import "BMEvent.h"


@implementation BMArtist

@dynamic name;
@dynamic serverId;
@dynamic events;


- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.name = dict[@"name"];
    self.serverId = dict[@"id"];
}


- (BOOL)isEqualToArtist:(BMArtist*)artist
{
    return [self.serverId isEqualToNumber:artist.serverId];
}

@end
