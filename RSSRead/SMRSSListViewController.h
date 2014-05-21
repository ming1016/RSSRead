//
//  SMRSSListViewController.h
//  RSSRead
//
//  Created by ming on 14-3-19.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMDetailViewController.h"
#import "SMRSSModel.h"
#import "SMFeedParserWrapper.h"
#import "SWTableViewCell.h"

@interface SMRSSListViewController : UITableViewController<SMDetailViewControllerDelegate,SMRSSModelDelegate,MWFeedParserDelegate,SWTableViewCellDelegate>
@property(nonatomic,strong)NSString *subscribeUrl;
@property(nonatomic,strong)NSString *subscribeTitle;
@property(nonatomic)BOOL isNewVC;
@property(nonatomic)BOOL isFav;
@end
