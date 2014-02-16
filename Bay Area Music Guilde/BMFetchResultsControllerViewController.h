//
//  BMFetchResultsControllerViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 2/1/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BMFetchResultsControllerViewController : UIViewController <NSFetchedResultsControllerDelegate>
{
    @protected
    __weak UITableView *_tableView;
    NSFetchedResultsController *_fetchController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSFetchedResultsController *fetchController;
// Declare some collection properties to hold the various updates we might get from the NSFetchedResultsControllerDelegate
@property (nonatomic, strong) NSMutableIndexSet *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableIndexSet *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (BOOL)indexPathIsLastIndexPath:(NSIndexPath *)indexPath;
@end
