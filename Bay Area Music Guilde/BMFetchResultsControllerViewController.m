//
//  BMFetchResultsControllerViewController.m
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMFetchResultsControllerViewController.h"

@implementation BMFetchResultsControllerViewController


#pragma UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.fetchController.sections.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


#pragma mark - Overridden getters

/**
 * Lazily instantiate these collections.
 */

- (NSMutableIndexSet *)deletedSectionIndexes
{
    if (_deletedSectionIndexes == nil) {
        _deletedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    
    return _deletedSectionIndexes;
}

- (NSMutableIndexSet *)insertedSectionIndexes
{
    if (_insertedSectionIndexes == nil) {
        _insertedSectionIndexes = [[NSMutableIndexSet alloc] init];
    }
    
    return _insertedSectionIndexes;
}

- (NSMutableArray *)deletedRowIndexPaths
{
    if (_deletedRowIndexPaths == nil) {
        _deletedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths
{
    if (_insertedRowIndexPaths == nil) {
        _insertedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths
{
    if (_updatedRowIndexPaths == nil) {
        _updatedRowIndexPaths = [[NSMutableArray alloc] init];
    }
    
    return _updatedRowIndexPaths;
}


#pragma mark - NSFetchedResultsControllerDelegate methods
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    NSLog(@"object changed : %@",anObject);
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

@end
