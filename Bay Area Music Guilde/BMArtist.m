//
//  BMArtist.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/9/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMArtist.h"
#import "BMEvent.h"


@implementation BMArtist

@dynamic name;
@dynamic serverId;
@dynamic firstLetterOfName;
@dynamic events;


- (void)updateWithDictionary:(NSDictionary *)dict
{
    self.name = dict[@"name"];
    self.serverId = dict[@"id"];
    
    NSString *aString = [self.name lowercaseString];
    
    NSString *stringToReturn = [aString substringToIndex:1];
    NSCharacterSet* digits = [NSCharacterSet decimalDigitCharacterSet];
    if ([stringToReturn rangeOfCharacterFromSet:digits].location != NSNotFound) {
        stringToReturn = @"#";
    }
    self.firstLetterOfName = stringToReturn;
}


- (BOOL)isEqualToArtist:(BMArtist*)artist
{
    return [self.serverId isEqualToNumber:artist.serverId];
}

@end
