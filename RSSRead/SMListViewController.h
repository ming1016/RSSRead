//
//  SMListView.h
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SMTableView.h"

@interface SMListViewController : UIViewController

@property (nonatomic, strong) UIView *listView;
@property (nonatomic, strong) SMTableView *tableView;

//初始化
- (instancetype)initWithTableView;

@end
