//
//  SMTableView.h
//  WeiboOffline
//
//  Created by DaiMing on 15/8/12.
//  Copyright (c) 2015年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMTableViewDelegate;

@interface SMTableView : UITableView

@property (nonatomic, weak) id<SMTableViewDelegate> smTableViewDelegate;
@property (nonatomic, strong) NSMutableArray *listData;

- (void)buildData:(NSArray *)data;
- (void)appendData:(NSArray *)data;

@end

@protocol SMTableViewDelegate <NSObject>

@optional
//刷新
- (void)smTableViewRefreshData:(SMTableView *)tableView; //刷新数据
- (void)smTableViewLoadMoreData:(SMTableView *)tableView;//上拉加载

//TableViewCell
- (void)smTableView:(SMTableView *)tableView configureCell:(UITableViewCell *)cell atIndex:(NSUInteger)index; //配置cell
- (CGFloat)smTableView:(SMTableView *)tableView heightAtIndex:(NSUInteger)index;                              //cell的高度计算

@end
