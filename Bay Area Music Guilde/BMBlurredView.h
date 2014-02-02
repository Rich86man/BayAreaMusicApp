#import <UIKit/UIKit.h>

@interface BMBlurredView : UIView
@property (nonatomic, assign) CGFloat blurRadius;
@property (nonatomic, assign) CGFloat scaleFactor;
@property (nonatomic, assign) BOOL freezeCurrentImage;

- (void)redraw;
@end
