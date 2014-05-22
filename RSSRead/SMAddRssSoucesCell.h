//
//  SMAddRssSoucesCell.h
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMAddRssSourceModel;
@interface SMAddRssSoucesCell : UITableViewCell

@property (nonatomic,strong) SMAddRssSourceModel* searchRss;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
