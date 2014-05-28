//
//  SMRSSListCell.h
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSS.h"
#import <RMSwipeTableViewCell.h>
@class SMRSSListCellMgr;
@interface SMRSSListCell : RMSwipeTableViewCell
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)SMRSSListCellMgr *cellMgr;
@property(nonatomic,strong)NSString *subscribeTitle;


@end
