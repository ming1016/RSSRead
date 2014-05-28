//
//  MBProgressHUD+Ext.h
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (Ext)
/**
 *  show HUD then hide after delay
 *
 *  @param view  view HUD will be added to
 *  @param text  notify string
 *  @param delay seconds
 */
+ (void)showHUDAddTo:(UIView *)view labelText:(NSString *)text hideAfterDelay:(NSTimeInterval)delay;

/**
 *  show HUD then hide after 1.2 seconds
 *
 *  @param view view HUD will be added to
 *  @param text notify string
 */
+ (void)showShortHUDAddTo:(UIView *)view labelText:(NSString *)text;

@end
