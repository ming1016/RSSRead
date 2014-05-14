//
//  SMMoreViewController.h
//  RSSRead
//
//  Created by ming on 14-3-4.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMAddRSSViewController.h"
#import "Subscribes.h"

@protocol SMMoreViewControllerDelegate

@optional
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe;

@end

@interface SMMoreViewController : UITableViewController<SMAddRSSViewControllerDelegate>
@property(nonatomic,assign)id<SMMoreViewControllerDelegate>smMoreViewControllerDelegate;

@end
