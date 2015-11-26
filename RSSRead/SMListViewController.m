//
//  SMListView.m
//  RSSRead
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import "SMListViewController.h"

#import "Masonry.h"

typedef NS_ENUM(NSInteger, SMListViewType) {
    SMListViewTypeTableView,
};

@interface SMListViewController()


@property (nonatomic) SMListViewType listType;


@end

@implementation SMListViewController
#pragma mark - init 
- (instancetype)initWithTableView {
    self = [super init];
    if (self) {
        [self setupTableView];
        self.listType = SMListViewTypeTableView;
    }
    return self;
}

#pragma mark - Private

#pragma mark - Tableview
- (void)setupTableView {
    [self.listView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(self.listView);
        make.width.equalTo(self.listView);
        make.center.equalTo(self.listView);
    }];
}

#pragma mark - getter
- (SMTableView *)tableView {
    if (!_tableView) {
        _tableView = [[SMTableView alloc] init];
    }
    return _tableView;
}

- (UIView *)listView {
    if (!_listView) {
        _listView = [[UIView alloc] init];
    }
    return _listView;
}

@end
