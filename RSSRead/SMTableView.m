//
//  SMTableView.m
//  WeiboOffline
//
//  Created by DaiMing on 15/8/12.
//  Copyright (c) 2015年 starming. All rights reserved.
//

#import "SMTableView.h"
#import "Masonry.h"
#import "MJRefresh.h"

static NSString *smTableViewCellIdentifier = @"SMTableViewCell";

@interface SMTableView ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation SMTableView

#pragma mark - life cycle
- (id)init {
    self = [super init];
    if (self) {
        [self registerClass:[UITableViewCell class] forCellReuseIdentifier:smTableViewCellIdentifier];
        self.listData = [NSMutableArray array];
        self.backgroundColor = [UIColor clearColor];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
        self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
        self.delegate = self;
        self.dataSource = self;
        [self.mj_header beginRefreshing];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

#pragma mark - Interface
- (void)buildData:(NSArray *)data {
    [self.mj_header endRefreshing];
    [self.mj_footer resetNoMoreData];
    if (data.count > 0) {
        self.listData = [NSMutableArray arrayWithArray:data];
        [self reloadData];
    }
}

- (void)appendData:(NSArray *)data {
    [self.mj_footer endRefreshing];
    if (data.count > 0) {
        [self.listData addObjectsFromArray:data];
        [self reloadData];
        [self.mj_footer resetNoMoreData];
    } else {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}

#pragma mark - Event
#pragma mark - refresh event
- (void)refreshData {
    if ([self.smTableViewDelegate respondsToSelector:@selector(smTableViewRefreshData:)]) {
        [self.smTableViewDelegate smTableViewRefreshData:self];
    }
}
- (void)loadMoreData {
    if ([self.smTableViewDelegate respondsToSelector:@selector(smTableViewLoadMoreData:)]) {
        [self.smTableViewDelegate smTableViewLoadMoreData:self];
    }
}


#pragma mark - Delegate
#pragma mark - TableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.smTableViewDelegate respondsToSelector:@selector(smTableView:heightAtIndex:)]) {
        return [self.smTableViewDelegate smTableView:self heightAtIndex:indexPath.row];
    }
    return 140;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.listData.count > 0) {
        return self.listData.count;
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:smTableViewCellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    if ([self.smTableViewDelegate respondsToSelector:@selector(smTableView:configureCell:atIndex:)]) {
        [self.smTableViewDelegate smTableView:self configureCell:cell atIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}



@end
