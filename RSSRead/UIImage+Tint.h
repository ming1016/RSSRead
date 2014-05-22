//
//  UIImage+Tint.h
//  RSSRead
//
//  Created by zhou on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Tint)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;

@end
