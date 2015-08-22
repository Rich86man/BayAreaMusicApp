//
//  BMDatesViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMFetchResultsControllerViewController.h"
#import "BMEventHandlingDelegate.h"

@interface BMDateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;

+ (CGFloat)heightWithText:(NSString*)text;
+ (CGFloat)baseHeight;

@end

@interface BMDatesViewController : BMFetchResultsControllerViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) id <BMEventHandlingDelegate> eventDelegate;

@end

