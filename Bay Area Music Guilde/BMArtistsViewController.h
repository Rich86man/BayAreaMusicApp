//
//  BMLocationsViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMFetchResultsControllerViewController.h"
#import "BMArtist.h"
#import "BMEventHandlingDelegate.h"

@interface BMArtistTableViewCell : UITableViewCell <UITableViewDataSource>
@property (strong, nonatomic) NSArray * events;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@interface BMArtistEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@interface BMArtistsViewController : BMFetchResultsControllerViewController <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) id<BMEventHandlingDelegate> eventDelegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;
- (void)cellTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
@end
