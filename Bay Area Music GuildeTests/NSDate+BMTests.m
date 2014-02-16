//
//  NSDate+BMTests.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/16/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSDate+BM.h"

@interface NSDate_BMTests : XCTestCase

@end

@implementation NSDate_BMTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}


- (void)testDaysAwayFromToday
{
    
    NSDate *oneWeekForward = [NSDate oneWeekFromToday];
    NSDate *oneWeekAgo = [NSDate oneDayAgoFromToday];
    
    XCTAssertTrue([oneWeekForward daysAwayFromToday] > 0, @"");
    XCTAssertTrue([oneWeekAgo daysAwayFromToday] < 0, @"");
    XCTAssertTrue([[NSDate date] daysAwayFromToday] == 0, @"");
}


@end
