//
//  SMRSSListCell.h
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSS.h"

@interface SMRSSListCell : UITableViewCell
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)NSString *subscribeTitle;

+(float)heightForRSSList:(RSS *)rss;

@end
