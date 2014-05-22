//
//  UIColor+TBExt.m
//  TBFramework
//
//  Created by zhou on 14-3-28.
//  Copyright (c) 2014年 zhou. All rights reserved.
//

#import "UIColor+TBExt.h"

@implementation UIColor (TBExt)


+(UIColor *) colorFromRGB:(NSUInteger)rgbValue ;
{
    return [UIColor
            colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0
            green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0
            blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0];
    

}

+(UIColor *) colorFromRGBA:(NSUInteger) rgbaValue;
{
    return
    [UIColor
     colorWithRed:((float)((rgbaValue & 0xFF000000) >> 16)) / 255.0
     green:((float)((rgbaValue & 0xFF0000) >> 8)) / 255.0
     blue:((float)(rgbaValue & 0xFF00)) / 255.0
     alpha:((float)(rgbaValue & 0xFF)) / 255.0];
    
}





@end
