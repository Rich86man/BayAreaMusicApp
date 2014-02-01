//
//  BMBaseModel.h
//  Bay Area Music Guilde
//
//  Created by Captain on 1/31/14.
//  Copyright (c) 2014 Exactly what it sounds like. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BMBaseModel <NSObject>

- (void)updateWithDictionary:(NSDictionary *)dict;
@end
