//
//  NSDate+BM.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "NSDate+BM.h"

@implementation NSDate (BM)

- (NSDate *)oneWeekForward
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeek:1];
    return [gregorian dateByAddingComponents:offsetComponents toDate:self options:0];
}


- (NSDate *)oneWeekPast
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setWeek:-1];
    return [gregorian dateByAddingComponents:offsetComponents toDate:self options:0];
}


+ (NSDate *)oneWeekFromToday
{
    return [[NSDate date] oneWeekForward];
}


+ (NSDate *)oneWeekAgoFromToday
{
    return [[NSDate date] oneWeekPast];
}

@end
