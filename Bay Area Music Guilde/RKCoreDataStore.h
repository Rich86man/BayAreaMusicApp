//
//  RKCoreData.h
//
//  Created by Richard Kirk on 6/23/13.

#import <Foundation/Foundation.h>

static NSString * const kRKMainPersistantStoreName = @"RKMainStore.sqlite";

@interface RKCoreDataStore : NSObject

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (RKCoreDataStore *)sharedStore;

- (void)mergeContexts:(NSNotification *)saveNotification;
- (void)resetPeristentStore;
- (NSManagedObjectContext *)createManagedObjectContext;

@end



