//
//  SMMoreViewController.h
//  RSSRead
//
//  Created by ming on 14-3-4.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscribes.h"
#import "MSDynamicsDrawerViewController.h"
#import "SMAddRSSViewController.h"


typedef NS_ENUM(NSUInteger, MSPaneViewControllerType) {
    HomeViewController,
    AddRSSViewController,
    FavoriteListController,
    AboutViewController
};

@protocol SMMoreViewControllerDelegate

@optional
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe;

@end

@interface SMMoreViewController : UITableViewController<SMAddRSSViewControllerDelegate>

@property(nonatomic,assign)id<SMMoreViewControllerDelegate>smMoreViewControllerDelegate;
@property(nonatomic, weak) MSDynamicsDrawerViewController *dynamicsDrawerViewController;
@property(nonatomic, assign) MSPaneViewControllerType paneViewControllerType;

- (void)transitionToViewController:(MSPaneViewControllerType)paneViewControllerType;

@end
