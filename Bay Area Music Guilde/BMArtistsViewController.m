//
//  BMLocationsViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMArtistsViewController.h"
#import "RKCoreDataStore.h"
#import "NSDate+BM.h"
#import "BMVenue.h"
#import "BMEvent.h"

@implementation BMArtistTableViewCell

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
    
    BMArtistEventTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"BMArtistEventTableViewCell"];
    BMEvent * event = self.events[indexPath.row];

    cell.titleLabel.text = event.venue.name;
    cell.monthLabel.text = [monthFormatter stringFromDate:event.date];
    cell.dayLabel.text = [dayFormatter stringFromDate:event.date];
    return cell;
}


@end


@implementation BMArtistEventTableViewCell

- (void)awakeFromNib
{
//    self.layer.cornerRadius = 10.0;
}

@end


@implementation BMArtistsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _cellSizes = [NSMutableDictionary dictionary];
    [self.fetchController performFetch:nil];
    
    [self.tableView reloadData];
}


- (NSFetchedResultsController *)fetchController
{
    if (!_fetchController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMArtist"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[[RKCoreDataStore sharedStore] managedObjectContext]
                                                                 sectionNameKeyPath:nil
                                                                          cacheName:nil];
        _fetchController.delegate = self;
    }
    return _fetchController;
}


#pragma mark - UITableView datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMArtistTableViewCell *cell = (BMArtistTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BMArtistTableViewCell"];
    BMArtist *artist = [self.fetchController objectAtIndexPath:indexPath];
    cell.artistLabel.text = artist.name;
    if ([indexPath isEqual:self.expandedIndexPath]) {
        cell.events = [artist.events sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
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
        return 60 + (numEvents * 43);
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
        BMArtistTableViewCell *cell = (BMArtistTableViewCell*)[tableView cellForRowAtIndexPath:oldExpandedIndexPath];
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
    BMArtistTableViewCell *outerCell = (BMArtistTableViewCell *)[self.tableView cellForRowAtIndexPath:self.expandedIndexPath];

    [self.eventDelegate viewController:self wantsToViewEvent:[outerCell.events objectAtIndex:indexPath.row]];
}

@end