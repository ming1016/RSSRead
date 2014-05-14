//
//  SMViewController.h
//  RSSRead
//
//  Created by ming on 14-3-3.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMoreViewController.h"
#import "SMRSSModel.h"

@interface SMViewController : UIViewController<SMMoreViewControllerDelegate,UITableViewDelegate,UITableViewDataSource,MWFeedParserDelegate,SMRSSModelDelegate>

-(void)fetchWithCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler;
@end
