//
//  JTViewController.h
//  OpenDoorAnimatedViewController
//
//  Created by Jerome TONNELIER on 04/07/13.
//  Copyright (c) 2013 Jérôme TONNELIER. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OpenDoorViewControllerDelegate <NSObject>

- (void)didFinishAnimation;

@end

@interface JTOpenDoorViewController : UIViewController
- (id)initWithViewController:(UIViewController*)viewController;
@property CGFloat animationDuration;
@property CGFloat initialShrinkRatio;
@property (nonatomic, unsafe_unretained) id<OpenDoorViewControllerDelegate> delegate;
@end
