//
//  UILabel+LNVerticallyAlignedLabel.h
//  learnist-ios
//
//  Created by Stacey Dao on 11/4/13.
//  Copyright (c) 2013 Learnist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Extras)

- (void) setVerticalAlignmentTop;
- (void) setVerticalAlignmentBottomWithFrame:(CGRect)originalFrame;
- (void) sizeToFitVertical;
- (void) sizeToFitHorizontal;
@end
