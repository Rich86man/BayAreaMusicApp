//
//  BMDatesViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMDatesViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import "RKCoreDataStore.h"
#import "BMEvent.h"
#import "BMVenue.h"
#import "BMArtist.h"
#import "UILabel+Extras.h"
#import "NSDate+BM.h"

static CGFloat baseHeight = 75;

@implementation BMDateTableViewCell

- (void)awakeFromNib
{
    self.view.layer.cornerRadius = 10.;
}

- (IBAction)buttonPressed:(UIButton *)sender
{
    
}

+ (CGFloat)heightWithText:(NSString*)text
{
    static CGSize baseLabelSize = {225, 20};
    static UIFont *font = nil;
    if (!font) {
        font = [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:14];
    }
    CGFloat dynamicHeight = [text boundingRectWithSize:CGSizeMake(baseLabelSize.width, 9999)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: font}
                                               context:nil].size.height;

    if (dynamicHeight <= baseLabelSize.height) {
        return baseHeight;
    }
    return baseHeight - baseLabelSize.height + dynamicHeight + 10;
}

+ (CGFloat)baseHeight
{
    return baseHeight;
}

@end


@implementation BMDatesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.fetchController performFetch:nil];

    [self.tableView reloadData];
}


- (NSFetchedResultsController *)fetchController
{
    if (!_fetchController) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BMEvent"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"day" ascending:YES],
                                    [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(date >= %@) AND (date <= %@)",[NSDate twoDaysAgoFromToday], [NSDate oneWeekFromToday]];
        request.predicate = predicate;
        _fetchController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                               managedObjectContext:[[RKCoreDataStore sharedStore] managedObjectContext]
                                                                 sectionNameKeyPath:@"day"
                                                                          cacheName:nil];
        _fetchController.delegate = self;
    }
    return _fetchController;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMEvent *event = [self.fetchController objectAtIndexPath:indexPath];
    [self.eventDelegate viewController:self wantsToViewEvent:event];
}


#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMDateTableViewCell *cell = (BMDateTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"BMDateTableViewCell"];
    BMEvent *event = [self.fetchController objectAtIndexPath:indexPath];
    cell.venueLabel.text = event.venue.name;
    cell.artistsLabel.text = event.artistsString;

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return baseHeight;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMEvent *event = [self.fetchController objectAtIndexPath:indexPath];
    return [BMDateTableViewCell heightWithText:event.artistsString];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 15)];
    view.backgroundColor = [UIColor colorWithRed:(183.0/255.0) green:(78.0/255.0) blue:(173.0/255.0) alpha:1];
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-MediumItalic" size:12];
    
    NSString *rawDateStr = [[[self.fetchController sections] objectAtIndex:section] name];
    // Convert rawDateStr string to NSDate...
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];

    }
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss ZZ"];
    NSDate *date = [formatter dateFromString:rawDateStr];
    // Convert NSDate to format we want...
    [formatter setDateFormat:@"E MMMM d"];
    label.text = [formatter stringFromDate:date];
    
    [view addSubview:label];
    return view;
}

@end
