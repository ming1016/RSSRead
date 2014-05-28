//
//  MBProgressHUD+Ext.m
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "MBProgressHUD+Ext.h"

@implementation MBProgressHUD (Ext)

+ (void)showHUDAddTo:(UIView *)view labelText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.removeFromSuperViewOnHide = YES;
    hud.labelText = text;
    [hud hide:YES afterDelay:delay];
}

+ (void)showShortHUDAddTo:(UIView *)view labelText:(NSString *)text;
{
    [self showHUDAddTo:view labelText:text hideAfterDelay:1.2f];
}

@end
