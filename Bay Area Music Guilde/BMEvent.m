//
//  BMEvent.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMEvent.h"
#import "BMArtist.h"
#import "BMVenue.h"
#import "NSDate+BM.h"

@implementation BMEvent

@dynamic date;
@dynamic price;
@dynamic serverId;
@dynamic hour;
@dynamic pitWarning;
@dynamic sellOutWarning;
@dynamic recommendation;
@dynamic noInOutWarning;
@dynamic artists;
@dynamic venue;
@dynamic day;

- (void)updateWithDictionary:(NSDictionary *)dict
{
    static NSDateFormatter *dateFormatter = nil;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZZ";
    }
    
    if (![self.serverId isEqualToNumber:dict[@"id"]]) {
        self.serverId = dict[@"id"];
    }
    
    if (dateFormatter && dict[@"event_date"]) {
        NSDate *newDate = [dateFormatter dateFromString:dict[@"event_date"]];
        if (![self.date isEqualToDate:newDate]) {
            self.date = newDate;
        }
    }
    if ([dict[@"price"] class] != [NSNull class] && self.price != dict[@"price"]) {
        self.price = dict[@"price"];
    }
}


- (NSString *)artistsString
{
    if (self.artists.count < 1) { return nil; }
    NSMutableString *string = [NSMutableString string];
    for (BMArtist *artist in self.artists) {
        [string appendFormat:@"%@\n", artist.name];
    }
    [string replaceCharactersInRange:NSMakeRange(string.length -1, 1) withString:@""];
    return string;
}


- (BOOL)isEqualToEvent:(BMEvent *)event
{
    return [self.serverId isEqualToNumber:event.serverId];
}

@end
