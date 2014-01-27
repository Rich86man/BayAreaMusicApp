//
//  BMMainViewController.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/26/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import "BMFlipsideViewController.h"

#import <CoreData/CoreData.h>

@interface BMMainViewController : UIViewController <BMFlipsideViewControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
