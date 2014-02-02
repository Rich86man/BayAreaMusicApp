//
//  LNBlurView.h
//  learnist-ios
//
//  Created by Grockit on 11/20/13.
//  Copyright (c) 2013 Learnist. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LNBlurView : UIView
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, assign) BOOL freezeCurrentImage;

- (void)redraw;
@end
