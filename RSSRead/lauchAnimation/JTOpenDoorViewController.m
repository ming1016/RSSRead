//
//  JTViewController.m
//  OpenDoorAnimatedViewController
//
//  Created by Jerome TONNELIER on 04/07/13.
//  Copyright (c) 2013 Jérôme TONNELIER. All rights reserved.
//

#import "JTOpenDoorViewController.h"
#import <QuartzCore/QuartzCore.h>

NSUInteger DeviceSystemMajorVersion();
NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}

#define PRIOR_TO_IOS_7 (DeviceSystemMajorVersion() < 7)

#define LEFT_FRAME CGRectMake(0, 0, CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame))
#define RIGHT_FRAME CGRectMake(CGRectGetMidX(self.view.frame), 0, CGRectGetMidX(self.view.frame), CGRectGetHeight(self.view.frame))

#define kDefaultAnimationDuration 1.0
#define kDefaultShrinkRation 0.9 // 70%

@interface JTOpenDoorViewController ()
@property (nonatomic, strong) UIImageView* imageView;
@property (nonatomic, strong) UIViewController* targetViewController;
@end

@implementation JTOpenDoorViewController

- (id)initWithViewController:(UIViewController*)viewController
{
    if ((self = [super init]))
    {
        self.targetViewController = viewController;
        self.animationDuration = kDefaultAnimationDuration;
        self.initialShrinkRatio = kDefaultShrinkRation;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat offset = 0;
    if (PRIOR_TO_IOS_7)
    {
        offset = [[UIApplication sharedApplication] statusBarFrame].size.height;
    }
	// Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -offset, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)+offset)];
    NSString* imageName;
    if ([[UIScreen mainScreen] bounds].size.height == 568 && [[UIScreen mainScreen] scale] == 2.0)
    {
        //imageName = @"Default-568h";
        imageName = @"LaunchImage-700-568h@2x";
    }
    else
    {
        //imageName = @"Default";
        imageName = @"LaunchImage-700@2x";
    }
    UIImage* defaultImage = [UIImage imageNamed:imageName];
    self.imageView.image = defaultImage;
    [self.view addSubview:self.imageView];
}

- (void)viewDidAppear:(BOOL)animated
{
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
        UIImage* leftImage = [self screenshotForRect:LEFT_FRAME];
        UIImage* rightImage = [self screenshotForRect:RIGHT_FRAME];
        __block UIImageView* leftImageView = [[UIImageView alloc] initWithFrame:LEFT_FRAME];
        leftImageView.image = leftImage;
        __block UIImageView* rightImageView = [[UIImageView alloc] initWithFrame:RIGHT_FRAME];
        rightImageView.image = rightImage;
        
        // we add the target viewControllers's view above the imageView and shrink it a little bit
        [self.view insertSubview:self.targetViewController.view belowSubview:self.imageView];
        self.targetViewController.view.frame = self.view.bounds;
        
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        [self.view insertSubview:rightImageView aboveSubview:self.targetViewController.view];
        [self.view insertSubview:leftImageView aboveSubview:self.targetViewController.view];
        
        [self setAnchorPoint:CGPointMake(0, 0.5) forView:leftImageView];
        [self setAnchorPoint:CGPointMake(1, 0.5) forView:rightImageView];
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:self.animationDuration];
        [CATransaction setCompletionBlock:^{
            [leftImageView removeFromSuperview];
            [rightImageView removeFromSuperview];
            leftImageView = nil;
            rightImageView = nil;
            if (self.delegate)
            {
                [self.delegate didFinishAnimation];
            }
        }];
        
        CABasicAnimation *leftTransformAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
        CATransform3D t = CATransform3DIdentity;
        t.m34 = 1.0/ -500;
        t = CATransform3DRotate(t, 100.0f * M_PI / 180.0f, 0, 1, 0);
        t = CATransform3DScale(t, 0.7, 0.7, 0.7);
        leftTransformAnimation.toValue = [NSValue valueWithCATransform3D:t];
//        leftTransformAnimation.duration = self.animationDuration;
        leftTransformAnimation.removedOnCompletion = NO;
        leftTransformAnimation.fillMode = kCAFillModeForwards;
        [leftImageView.layer addAnimation:leftTransformAnimation forKey:@"transform"];
        
        CABasicAnimation *rightTransformAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
        CATransform3D t2 = CATransform3DIdentity;
        t2.m34 = 1.0/ -500;
        t2 = CATransform3DRotate(t2, -100.0f * M_PI / 180.0f, 0, 1, 0);
        t2 = CATransform3DScale(t2, 0.7, 0.7, 0.7);
        rightTransformAnimation.toValue = [NSValue valueWithCATransform3D:t2];
//        rightTransformAnimation.duration = self.animationDuration;
        rightTransformAnimation.removedOnCompletion = NO;
        rightTransformAnimation.fillMode = kCAFillModeForwards;
        [rightImageView.layer addAnimation:rightTransformAnimation forKey:@"transform"];
        
        CABasicAnimation *translateTransformAnimation = [CABasicAnimation animationWithKeyPath: @"transform"];
        CATransform3D t3 = CATransform3DIdentity;
        t3.m34 = 1.0/ -500;
        t3 = CATransform3DTranslate(t3, 0, 0, -3500);
        translateTransformAnimation.fromValue = [NSValue valueWithCATransform3D:t3];
        translateTransformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
        translateTransformAnimation.duration = self.animationDuration*0.9;
        translateTransformAnimation.removedOnCompletion = YES;
        translateTransformAnimation.fillMode = kCAFillModeForwards;
        [self.targetViewController.view.layer addAnimation:translateTransformAnimation forKey:@"transform"];
        
        [CATransaction commit];
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSLog(@"animationDidStop %@", anim);
}

-(void)resizeLayer:(CALayer*)layer to:(CGSize)size
{
    // Prepare the animation from the old size to the new size
    CGRect oldBounds = layer.bounds;
    CGRect newBounds = oldBounds;
    newBounds.size = size;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
    
    // NSValue/+valueWithRect:(NSRect)rect is available on Mac OS X
    // NSValue/+valueWithCGRect:(CGRect)rect is available on iOS
    // comment/uncomment the corresponding lines depending on which platform you're targeting
    
    // iOS
    animation.fromValue = [NSValue valueWithCGRect:oldBounds];
    animation.toValue = [NSValue valueWithCGRect:newBounds];
    
    // Update the layer's bounds so the layer doesn't snap back when the animation completes.
    layer.bounds = newBounds;
    
    // Add the animation, overriding the implicit animation.
    [layer addAnimation:animation forKey:@"bounds"];
}

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)screenshotForRect:(CGRect)screenRect
{
    CGSize imageSize = self.view.frame.size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    // Iterate over every window from back to front
    // -renderInContext: renders in the coordinate space of the layer,
    // so we must first apply the layer's geometry to the graphics context
    CGContextSaveGState(context);
    // Render the layer hierarchy to the current context
    [[self.view layer] renderInContext:context];
    // Restore the context
    CGContextRestoreGState(context);
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect croppedRect = screenRect;
    if (scale > 1)
    {
        croppedRect = CGRectMake(screenRect.origin.x * scale,
                                 screenRect.origin.y * scale,
                                 screenRect.size.width * scale,
                                 screenRect.size.height * scale);
    }
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], croppedRect);
    UIImage *croppedScreenshot = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    UIGraphicsEndImageContext();
    
    return croppedScreenshot;
}

@end
