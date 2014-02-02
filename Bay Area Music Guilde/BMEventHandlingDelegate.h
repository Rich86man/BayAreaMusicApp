//
//  BMEventHandlingDelegate.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/2/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMEvent;

@protocol BMEventHandlingDelegate <NSObject>
- (void)viewController:(UIViewController*)controller wantsToViewEvent:(BMEvent*)event;

@end