//
//  SMAddRSSViewController.h
//  RSSRead
//
//  Created by ming on 14-3-18.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWFeedParser.h"
#import "Subscribes.h"

@protocol SMAddRSSViewControllerDelegate
@optional
-(void)addedRSS:(Subscribes *)subscribe;
@end

@interface SMAddRSSViewController : UIViewController<UITextFieldDelegate,MWFeedParserDelegate>
@property(nonatomic,assign)id<SMAddRSSViewControllerDelegate>smAddRSSViewControllerDelegate;

@end