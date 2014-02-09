//
//  BMVenuesViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMFetchResultsControllerViewController.h"
#import "BMVenue.h"
#import "BMEvent.h"
#import "BMArtist.h"
#import "BMEventHandlingDelegate.h"

@interface BMVenueTableViewCell : UITableViewCell <UITableViewDataSource>
@property (strong, nonatomic) NSArray *events;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *venueLabel;
@property (weak, nonatomic) IBOutlet UIButton *expandButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@interface BMVenueEventTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistsLabel;

@end

@interface BMVenuesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) id<BMEventHandlingDelegate> eventDelegate;
@property (strong, nonatomic) NSArray *venues;
@property (strong, nonatomic) NSIndexPath *expandedIndexPath;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (assign, nonatomic) BOOL sortedByDistance;
- (void)cellTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath;
- (IBAction)segmentChangedValue:(UISegmentedControl *)sender;
@end
