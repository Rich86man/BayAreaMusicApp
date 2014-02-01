//
//  UILabel+LNVerticallyAlignedLabel.m
//  learnist-ios
//
//  Created by Stacey Dao on 11/4/13.
//  Copyright (c) 2013 Learnist. All rights reserved.
//

#import "UILabel+Extras.h"

@implementation UILabel (Extras)

- (void) setVerticalAlignmentTop
{
    CGSize textSize = [self.text sizeWithAttributes:@{NSFontAttributeName:self.font}];
    
    CGRect textRect = CGRectMake(self.frame.origin.x,
                                 self.frame.origin.y,
                                 self.frame.size.width,
                                 textSize.height);
    [self setFrame:textRect];
    [self setNeedsDisplay];
}

// Original frame is needed for when the label is re-used in (reusable) cells
// so that the frame's origin doesn't change each time

- (void)setVerticalAlignmentBottomWithFrame:(CGRect)originalFrame
{
    if (self.text) {
        NSDictionary *attributes = @{NSFontAttributeName: self.font};

        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){originalFrame.size.width, originalFrame.size.height}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
        CGSize size = rect.size;
        CGFloat height = ceilf(size.height);

        CGRect newFrame = originalFrame;
        newFrame.origin.y = newFrame.origin.y + newFrame.size.height - height;
        newFrame.size.height = height;
        self.frame = newFrame;
    }
}


-(void)sizeToFitVertical
{
    self.numberOfLines = 0;
    CGRect labelFrame = self.frame;
    
    CGRect expectedFrame = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, 9999)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            self.font, NSFontAttributeName,
                                                            nil]
                                                   context:nil];
    labelFrame.size.height = ceil(expectedFrame.size.height); //iOS7 is not rounding up to the nearest whole number

    self.frame = labelFrame;
}

- (void)sizeToFitHorizontal
{
    self.numberOfLines = 0;
    CGRect labelFrame = self.frame;
    
    CGRect expectedFrame = [self.text boundingRectWithSize:CGSizeMake(9999, self.frame.size.height)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                            self.font, NSFontAttributeName,
                                                            nil]
                                                   context:nil];
    labelFrame.size.width = ceil(expectedFrame.size.width); //iOS7 is not rounding up to the nearest whole number
    
    self.frame = labelFrame;
}

@end
