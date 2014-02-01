//
//  BMDatesViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMFetchResultsControllerViewController.h"

@interface BMDateTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;
@property (weak, nonatomic) IBOutlet UIButton *button;

+ (CGFloat)heightWithText:(NSString*)text;
+ (CGFloat)baseHeight;

@end


@interface BMDatesViewController : BMFetchResultsControllerViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *objectChanges;

@end
