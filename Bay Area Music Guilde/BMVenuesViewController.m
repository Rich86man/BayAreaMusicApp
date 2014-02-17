
//
//  BMVenuesViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMVenuesViewController.h"
#import "RKCoreDataStore.h"
#import "NSDate+BM.h"
#import "UIColor+BMColors.h"

@implementation BMVenueTableViewCell

- (void)awakeFromNib
{
    self.view.layer.cornerRadius = 10.;
    self.tableView.layer.cornerRadius = 10.;
    self.stateImageView.tintColor = [UIColor iconYellow];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.view.height > 60) {
        self.stateImageView.image = [[UIImage imageNamed:@"minus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        self.stateImageView.image = [[UIImage imageNamed:@"plus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.events.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSDateFormatter *monthFormatter = nil;
    if (!monthFormatter) {
        monthFormatter = [[NSDateFormatter alloc] init];
        [monthFormatter setDateFormat:@"MMM"];
    }
    static NSDateFormatter *dayFormatter = nil;
    if (!dayFormatter) {
        dayFormatter = [[NSDateFormatter alloc] init];
        [dayFormatter setDateFormat:@"dd"];
    }
    
    BMVenueEventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BMVenueEventTableViewCell"];
    BMEvent * event = self.events[indexPath.row];
    
    cell.artistsLabel.text = [event.artistsString stringByReplacingOccurrencesOfString:@"\n" withString:@", "];
    cell.monthLabel.text = [monthFormatter stringFromDate:event.date];
    cell.dayLabel.text = [dayFormatter stringFromDate:event.date];
    return cell;
}


@end


@implementation BMVenueEventTableViewCell



@end

@implementation BMVenuesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self fetchObjectsByName];

    [self.tableView reloadData];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self.segmentControl setEnabled:NO forSegmentAtIndex:1];
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self.locationManager startMonitoringSignificantLocationChanges];
    }
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopMonitoringSignificantLocationChanges];
}


- (CLLocationManager *)locationManager
{
    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.activityType = CLActivityTypeOtherNavigation;
        _locationManager.distanceFilter = 1600;
    }
    return _locationManager;
}


- (void)fetchObjectsByName
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMVenue"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    self.venues = [[[RKCoreDataStore sharedStore] managedObjectContext] executeFetchRequest:request error:nil];
    self.sortedByDistance = NO;
}


- (void)fetchObjectsByDistance
{
    CLLocation *userLocation = self.locationManager.location;
    if (!userLocation) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
            [[[UIAlertView alloc] initWithTitle:@"Location Services Disabled"
                                        message:@"Please allow this app to use location services to enable this feature"
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        [self.segmentControl setSelectedSegmentIndex:0];
        return;
    }
    [self.segmentControl setSelectedSegmentIndex:1];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMVenue"];
    self.venues = [[[RKCoreDataStore sharedStore] managedObjectContext] executeFetchRequest:request error:nil];
    self.venues = [self.venues sortedArrayUsingComparator:^(BMVenue *a,BMVenue *b) {
        CLLocation *aloc = [[CLLocation alloc] initWithLatitude:[a.latitude doubleValue] longitude:[a.longitude doubleValue]];
        CLLocation *bloc = [[CLLocation alloc] initWithLatitude:[b.latitude doubleValue] longitude:[b.longitude doubleValue]];

        CLLocationDistance distanceA = [aloc distanceFromLocation:userLocation];
        CLLocationDistance distanceB = [bloc distanceFromLocation:userLocation];
        if (distanceA < distanceB) {
            return NSOrderedAscending;
        } else if (distanceA > distanceB) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    self.sortedByDistance = YES;
}

#pragma mark - UITableView datasource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.venues.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMVenueTableViewCell *cell = (BMVenueTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BMVenueTableViewCell"];
    BMVenue *venue = self.venues[indexPath.row];
    cell.venueLabel.text = venue.name;
    if ([indexPath isEqual:self.expandedIndexPath]) {
        cell.events = [venue.events sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        [cell.tableView reloadData];
    }
    return cell;
}

#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return 44;
    }
    return 60;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        return 44;
    }
    if ([indexPath isEqual:self.expandedIndexPath]) {
        BMVenue *venue = self.venues[indexPath.row];
        NSInteger numEvents = venue.events.count;
        return 60 + (numEvents * 44) - 1;
    }
    return 60;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != self.tableView) {
        [self cellTableView:tableView didSelectRowAtIndexPath:indexPath];
        return;
    }
    
    if (self.expandedIndexPath) {
        NSIndexPath *oldExpandedIndexPath = self.expandedIndexPath;
        BMVenueTableViewCell *cell = (BMVenueTableViewCell*)[tableView cellForRowAtIndexPath:oldExpandedIndexPath];
        cell.events = nil;
        self.expandedIndexPath = nil;
        [tableView reloadRowsAtIndexPaths:@[oldExpandedIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        if ([oldExpandedIndexPath isEqual:indexPath]) { return; }
    }
    self.expandedIndexPath = indexPath;
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}


- (void)cellTableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    BMVenueTableViewCell *outerCell = (BMVenueTableViewCell *)[self.tableView cellForRowAtIndexPath:self.expandedIndexPath];
    
    [self.eventDelegate viewController:self wantsToViewEvent:[outerCell.events objectAtIndex:indexPath.row]];
}


- (IBAction)segmentChangedValue:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 1 && !self.sortedByDistance) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        [self fetchObjectsByDistance];
        self.expandedIndexPath = nil;
        [self.tableView reloadData];
    } else if(sender.selectedSegmentIndex == 0 && self.sortedByDistance) {
        [self fetchObjectsByName];
        self.expandedIndexPath = nil;
        [self.tableView reloadData];
    }
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self fetchObjectsByDistance];
    [self.tableView reloadData];
}

@end
