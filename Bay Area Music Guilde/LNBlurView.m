//
//  LNBlurView.m
//  learnist-ios
//
//  Created by Grockit on 11/20/13.
//  Copyright (c) 2013 Learnist. All rights reserved.
//

#import "LNBlurView.h"
#import <Accelerate/Accelerate.h>

@interface LNBlurView ()
{
    CGContextRef _effectInContext;
    CGContextRef _effectOutContext;
    vImage_Buffer _effectInBuffer;
    vImage_Buffer _effectOutBuffer;
    uint32_t _kernel;
    CGSize _bufferSize;
    BOOL _initialized;
}

@end


@implementation LNBlurView

- (id)initWithFrame:(CGRect)frame
{
	if (self = [super initWithFrame:frame]) {
	}

	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if (self = [super initWithCoder:aDecoder]) {
		[self setup];
        [self updateBuffers];
	}

	return self;
}

- (void)setup
{
    _scaleFactor = 0.25f;
	_blurRadius = 4.0f;
    uint32_t radius = (uint32_t)floor(_blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
    radius += (radius + 1) % 2;
    _kernel = radius;
    _freezeCurrentImage = NO;
}

- (void)dealloc
{
	if (_effectInContext) {
		CGContextRelease(_effectInContext);
	}
	if (_effectOutContext) {
		CGContextRelease(_effectOutContext);
	}
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    if (blurRadius != _blurRadius) {
        _blurRadius = blurRadius;
        uint32_t radius = (uint32_t)floor(_blurRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
        radius += (radius + 1) % 2;
        _kernel = radius;
        [self process];
    }
}

- (void)setScaleFactor:(CGFloat)scaleFactor
{
    if (scaleFactor != _scaleFactor) {
        _scaleFactor = scaleFactor;
        [self updateBuffers];
        [self process];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        if (!_initialized) {
            _initialized = YES;
            [self setup];
            [self updateBuffers];
        }
    }
}

- (void)didMoveToSuperview
{
    [self process];
}

- (void)redraw
{
    [self process];
}

- (void)updateBuffers
{
    _bufferSize = CGSizeMake(_scaleFactor * self.bounds.size.width, _scaleFactor * self.bounds.size.height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    _effectInContext = CGBitmapContextCreate(NULL, _bufferSize.width, _bufferSize.height, 8, _bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    _effectOutContext = CGBitmapContextCreate(NULL, _bufferSize.width, _bufferSize.height, 8, _bufferSize.width * 8, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextConcatCTM(_effectInContext, (CGAffineTransform){1, 0, 0, -1, 0, _bufferSize.height});
    CGContextScaleCTM(_effectInContext, _scaleFactor, _scaleFactor);
    CGContextTranslateCTM(_effectInContext, -self.frame.origin.x, -self.frame.origin.y);

    _effectInBuffer = (vImage_Buffer) {
        .data = CGBitmapContextGetData(_effectInContext),
        .width = CGBitmapContextGetWidth(_effectInContext),
        .height = CGBitmapContextGetHeight(_effectInContext),
        .rowBytes = CGBitmapContextGetBytesPerRow(_effectInContext)
    };

    _effectOutBuffer = (vImage_Buffer) {
        .data = CGBitmapContextGetData(_effectOutContext),
        .width = CGBitmapContextGetWidth(_effectOutContext),
        .height = CGBitmapContextGetHeight(_effectOutContext),
        .rowBytes = CGBitmapContextGetBytesPerRow(_effectOutContext)
    };
}

- (void)process
{
    if (self.superview && !self.freezeCurrentImage) {
        NSArray *sublayers = self.layer.superlayer.sublayers;
        NSUInteger selfIndex = [sublayers indexOfObject:self.layer];
        NSMutableArray *previousStates = [NSMutableArray arrayWithCapacity:sublayers.count - selfIndex];
        CALayer *layer = nil;
        for (NSUInteger i = selfIndex; i < sublayers.count; i++) {
            layer = sublayers[i];
            [previousStates addObject:@(layer.hidden)];
            [layer setHidden:YES];
        }

        BOOL masksBounds = self.layer.superlayer.masksToBounds;
        self.layer.superlayer.masksToBounds = NO;
        [self.layer.superlayer renderInContext:_effectInContext];
        self.layer.superlayer.masksToBounds = masksBounds;
        
        for (NSUInteger i = selfIndex; i < sublayers.count; i++) {
            layer = sublayers[i];
            [layer setHidden:[previousStates[i - selfIndex] boolValue]];
        }


        vImageBoxConvolve_ARGB8888(&_effectInBuffer, &_effectOutBuffer, NULL, 0, 0, _kernel, _kernel, 0, kvImageEdgeExtend);
        vImageBoxConvolve_ARGB8888(&_effectOutBuffer, &_effectInBuffer, NULL, 0, 0, _kernel, _kernel, 0, kvImageEdgeExtend);
        vImageBoxConvolve_ARGB8888(&_effectInBuffer, &_effectOutBuffer, NULL, 0, 0, _kernel, _kernel, 0, kvImageEdgeExtend);
        CGImageRef outImage = CGBitmapContextCreateImage(_effectOutContext);
        self.layer.contents = (__bridge id)(outImage);
        CGImageRelease(outImage);
    }
}

@end