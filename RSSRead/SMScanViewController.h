//
//  ViewController.h
//  NewProject
//
//  Created by 学鸿 张 on 13-11-29.
//  Copyright (c) 2013年 Steven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZBarSDK.h"

@protocol SMScanViewControllerDelegate <NSObject>

@required
- (void)scanFinishedWithURL:(NSString *)urlString;

@end

@interface SMScanViewController : UIViewController

@property (weak, nonatomic) id<SMScanViewControllerDelegate> delegate;

@end
