//
//  BMEvent.m
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMEvent.h"
#import "BMArtist.h"
#import "BMVenue.h"

@implementation BMEvent

@dynamic date;
@dynamic price;
@dynamic serverId;
@dynamic venue;
@dynamic artists;

static NSDateFormatter *dateFormatter;

- (void)updateWithDictionary:(NSDictionary *)dict
{
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZ";
    }

    self.serverId = dict[@"id"];
    if (dateFormatter && dict[@"event_date"]) {
        self.date = [dateFormatter dateFromString:dict[@"event_date"]];
    }
    self.price = [dict[@"price"] class] != [NSNull class] ? dict[@"price"] : nil;
}


- (NSString *)artistsString
{
    NSMutableString *string = [NSMutableString string];
    for (BMArtist *artist in self.artists) {
        [string appendFormat:@"%@\n", artist.name];
    }
    [string replaceCharactersInRange:NSMakeRange(string.length -1, 1) withString:@""];
    return string;
}

@end
