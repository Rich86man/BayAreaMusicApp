//
//  BMFlipsideViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BMFlipsideViewController;

@protocol BMFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BMFlipsideViewController *)controller;
@end

@interface BMFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BMFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
