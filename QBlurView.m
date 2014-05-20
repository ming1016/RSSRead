//
//  QBlurView.m
//  QBlurView
//
//  Created by brightshen on 13-11-5.
//  Copyright (c) 2013年 brightshen. All rights reserved.
//

#import "QBlurView.h"
#import <Accelerate/Accelerate.h>

@interface QBlurView()

@property(atomic, strong) UIImage *effectImage;

@end

@implementation QBlurView{
    dispatch_source_t source;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clearsContextBeforeDrawing = YES;
        _blurRadius = 10;
        _saturationDeltaFactor = 1.0;
        source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_OR, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        __weak id weakSelf = self;
        dispatch_source_set_event_handler(source, ^{
            [weakSelf refresh];
        });
        dispatch_resume(source);
    }
    return self;
}

- (void)setSynchronized:(BOOL)synchronized{
    if (_synchronized!=synchronized) {
        _synchronized = synchronized;
        if (_synchronized) {
            dispatch_suspend(source);
        }
        else{
            dispatch_resume(source);
        }
    }
}

- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    [self setNeedsRefresh];
}

- (void)setCenter:(CGPoint)center{
    [super setCenter:center];
    [self setNeedsRefresh];
}

- (void)setTransform:(CGAffineTransform)transform{
    [super setTransform:transform];
    [self setNeedsRefresh];
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    [self setNeedsRefresh];
}

- (void)setNeedsRefresh{
    if (_synchronized) {
        [self setNeedsDisplay];
    }
    else{
        if (source) {
            dispatch_source_merge_data(source, 1);
        }
    }
}

- (void)setBlurRadius:(CGFloat)blurRadius{
    _blurRadius = blurRadius;
    [self setNeedsRefresh];
}

- (void)setSaturationDeltaFactor:(CGFloat)saturationDeltaFactor{
    _saturationDeltaFactor = saturationDeltaFactor;
    [self setNeedsRefresh];
}

- (void)didMoveToWindow{
    [super didMoveToWindow];
    [self setNeedsRefresh];
}

- (void)refresh{
    BOOL hasBlur = _blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(_saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    
    CGRect visibleRect = [self.superview convertRect:self.frame toView:self];
    visibleRect.origin.y += self.frame.origin.y;
    visibleRect.origin.x += self.frame.origin.x;
    
    // Drawing code
    UIGraphicsBeginImageContextWithOptions(visibleRect.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectInContext = UIGraphicsGetCurrentContext();
    vImage_Buffer effectInBuffer;
    effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
    effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
    effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
    effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
    
    CGContextTranslateCTM(effectInContext, -visibleRect.origin.x, -visibleRect.origin.y);
    CALayer *layer = self.superview.layer;
    self.layer.hidden = YES;
    [layer renderInContext:effectInContext];
    self.layer.hidden = NO;
    
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
    vImage_Buffer effectOutBuffer;
    effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
    effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
    effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
    effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
    
    if (hasBlur) {
        // A description of how to compute the box kernel width from the Gaussian
        // radius (aka standard deviation) appears in the SVG spec:
        // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
        //
        // For larger values of 's' (s >= 2.0), an approximation can be used: Three
        // successive box-blurs build a piece-wise quadratic convolution kernel, which
        // approximates the Gaussian kernel to within roughly 3%.
        //
        // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
        //
        // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
        //
        CGFloat inputRadius = _blurRadius * [[UIScreen mainScreen] scale];
        NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
        if (radius % 2 != 1) {
            radius += 1; // force radius to be odd so that the three box-blur methodology works.
        }
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
    }
    BOOL effectImageBuffersAreSwapped = NO;
    if (hasSaturationChange) {
        CGFloat s = _saturationDeltaFactor;
        CGFloat floatingPointSaturationMatrix[] = {
            0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
            0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
            0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
            0,                    0,                    0,  1,
        };
        const int32_t divisor = 256;
        NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
        int16_t saturationMatrix[matrixSize];
        for (NSUInteger i = 0; i < matrixSize; ++i) {
            saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
        }
        if (hasBlur) {
            vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            effectImageBuffersAreSwapped = YES;
        }
        else {
            vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
        }
    }
    
    
    if (!effectImageBuffersAreSwapped)
        self.effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (effectImageBuffersAreSwapped)
        self.effectImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (!_synchronized) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
}

- (void)drawRect:(CGRect)rect
{
    if (_synchronized) {
        [self refresh];
    }
    [self.effectImage drawAtPoint:CGPointZero];
}

- (void)dealloc{
    dispatch_source_cancel(source);
    dispatch_release(source);
}

@end
