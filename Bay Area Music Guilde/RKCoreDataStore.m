//
//  RKCoreData.m
//
//  Created by Richard Kirk on 6/23/13.

#import "RKCoreDataStore.h"

#define DEBUG_RK_COREDATA YES

@interface RKCoreDataStore()
- (NSString *) persistantStorePath;
@end

@implementation RKCoreDataStore

+ (RKCoreDataStore *)sharedStore
{
    static RKCoreDataStore *privateInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        privateInstance = [[RKCoreDataStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:privateInstance
                 selector:@selector(mergeContexts:)
                     name:NSManagedObjectContextDidSaveNotification
                   object:nil];
    });
    return privateInstance;
}


- (void)mergeContexts:(NSNotification *)saveNotification
{
    NSManagedObjectContext *context = [self managedObjectContext];
    @synchronized(context) {
        // don't changes from ourselves
        if ([saveNotification object] != context) {
            // only notify on the main thread
            if ([NSThread isMainThread]) {
                [context mergeChangesFromContextDidSaveNotification:saveNotification];
            }
            else {
                dispatch_sync( dispatch_get_main_queue() , ^( void ) {
                    [context mergeChangesFromContextDidSaveNotification:saveNotification];
                } );
            }
        }
    }
}


- (void)resetPeristentStore
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[self persistantStorePath] error:&error];
    if(error && DEBUG_RK_COREDATA) { NSLog(@"RKCOREDATA : %@",error); }
    
    [ self managedObjectContext ];
}


- (NSManagedObjectContext *)createManagedObjectContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSManagedObjectContext* context = nil;
    if (coordinator != nil) {
        context = [[NSManagedObjectContext alloc] init];
        [context setMergePolicy: NSMergeByPropertyStoreTrumpMergePolicy];
        [context setPersistentStoreCoordinator:coordinator];
    }
    return context;
}


#pragma mark CoreData accessors

- (NSManagedObjectContext *)managedObjectContext
{
    @synchronized(self) {
        if (_managedObjectContext != nil){
            return _managedObjectContext;
        }
        _managedObjectContext = [self createManagedObjectContext];
    }
    return _managedObjectContext;
}


- (NSManagedObjectModel *)managedObjectModel
{
    @synchronized(self) {
        if (_managedObjectModel != nil) {
            return _managedObjectModel;
        }
        _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    }
    return _managedObjectModel;
}


- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    @synchronized(self) {
        if (!_persistentStoreCoordinator) {
            NSURL *storeUrl = [NSURL fileURLWithPath:[self persistantStorePath]];
            NSError * error = nil;
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            
            NSDictionary *options =  @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                       NSInferMappingModelAutomaticallyOption : @(YES)};
            
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                            configuration:nil
                                                                      URL:storeUrl
                                                                  options:options
                                                                    error:&error]) {
                
                if(DEBUG_RK_COREDATA) {
                    NSLog(@"RKCOREDATA : Failed to create SQLite database");
                    NSLog(@"RKCOREDATA : Deleting Old Database and Creating New");
                    if(error) {
                        NSLog(@"RKCOREDATA : %@", error);
                    }
                }
                
                [[NSFileManager defaultManager] removeItemAtPath:storeUrl.path error:&error];
                
                error = nil;
                [ _persistentStoreCoordinator addPersistentStoreWithType: NSSQLiteStoreType
                                                           configuration: nil
                                                                     URL: storeUrl
                                                                 options: options
                                                                   error: &error ];
                
                if(error && DEBUG_RK_COREDATA) { NSLog(@"RKCOREDATA : %@",error); }
                
            }
        }
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - Helper Methods

- (NSString*)persistantStorePath
{
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [documentsDir stringByAppendingPathComponent:kRKMainPersistantStoreName];
}

 @end