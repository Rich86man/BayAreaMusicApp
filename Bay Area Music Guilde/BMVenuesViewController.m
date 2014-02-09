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

@implementation BMVenueTableViewCell

- (void)awakeFromNib
{
    self.view.layer.cornerRadius = 10.;
    self.tableView.layer.cornerRadius = 10.;
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
    
    cell.artistsLabel.text = [event.artistsString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
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
    
    [self.fetchController performFetch:nil];

    [self.tableView reloadData];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self.segmentControl setEnabled:NO forSegmentAtIndex:1];
    }
}


- (CLLocationManager *)locationManager
{
    if(!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        _locationManager.activityType = CLActivityTypeOtherNavigation;
    }
    return _locationManager;
}

- (NSFetchedResultsController *)fetchController
{
    if (!_fetchController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMVenue"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[[RKCoreDataStore sharedStore] managedObjectContext]
                                                                 sectionNameKeyPath:@"name"
                                                                          cacheName:nil];
        _fetchController.delegate = self;
    }
    return _fetchController;
}


#pragma mark - UITableView datasource


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMVenueTableViewCell *cell = (BMVenueTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BMVenueTableViewCell"];
    BMVenue *venue = [self.fetchController objectAtIndexPath:indexPath];
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
        BMArtist *artist = [self.fetchController objectAtIndexPath:indexPath];
        NSInteger numEvents = artist.events.count;
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
    [self.locationManager startMonitoringSignificantLocationChanges];
    
    
}


#pragma mark - CLLocationManager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
}

@end
