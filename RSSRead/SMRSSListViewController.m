//
//  SMRSSListViewController.m
//  RSSRead
//
//  Created by ming on 14-3-19.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMRSSListViewController.h"
#import "SMUIKitHelper.h"
#import "SMAppDelegate.h"
#import "SMGetFetchedRecordsModel.h"
#import "SMRSSListCell.h"
#import "RSS.h"

@interface SMRSSListViewController ()
@property(nonatomic,strong)NSMutableArray *rssArray;
@end

@implementation SMRSSListViewController {
    UIRefreshControl *_refreshControl;
    UIActivityIndicatorView *_indicator;
}

-(void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rssArray = [NSMutableArray array];

    if (_isFav) {
        self.title = @"收藏列表";
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全部标记已读" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllRSS)];
    }
    //初始化
    self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //下拉刷新
    _refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshControl;
}

-(void)setSubscribeTitle:(NSString *)subscribeTitle {
    self.title = subscribeTitle;
    _subscribeTitle = subscribeTitle;
}

-(void)setIsFav:(BOOL)isFav {
    _isFav = isFav;
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //加上此判断主要为了解决Detail详细页返回延时问题
    if (_isNewVC) {
        _isNewVC = NO;
        [self loadTableViewFromCoreData];
    }
}

- (void)fetchDataFromDB
{
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"RSS";
    getModel.sortName = @"date";
    if (_isFav) {
        getModel.predicate = [NSPredicate predicateWithFormat:@"isFav=1"];
    }
    
    getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@",_subscribeUrl];
    
    
    NSArray *fetchedRecords = [APP_DELEGATE getFetchedRecords:getModel];
    [_rssArray removeAllObjects];
    [_rssArray addObjectsFromArray:fetchedRecords];
    
    [self.tableView reloadData];
}

-(void)loadTableViewFromCoreData {
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"RSS";
    getModel.sortName = @"date";
    if (_isFav) {
        getModel.predicate = [NSPredicate predicateWithFormat:@"isFav=1"];
    }else{
        getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@",_subscribeUrl];
    }
    
    NSArray *fetchedRecords = [APP_DELEGATE getFetchedRecords:getModel];
    [_rssArray removeAllObjects];
    [_rssArray addObjectsFromArray:fetchedRecords];
    
    //首次点击进入页面时进行一次拉取数据
    if (!_isFav && _rssArray.count == 0) {
        SMFeedParserWrapper *parserWrapper = [SMFeedParserWrapper new];
        [parserWrapper parseUrl:[NSURL URLWithString:_subscribeUrl] completion:^(NSArray *items) {
            if(items && items.count){
                SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                rssModel.smRSSModelDelegate = self;
                for(MWFeedItem *item in items){
                    RSS *rss = [rssModel insertRSSWithFeedItem:item withFeedUrlStr:_subscribeUrl];
                    
                    if (rss) {
                        [_rssArray addObject:rss];
                    }
                    
                }
                
                [self.tableView reloadData];
            }
        }];
    }
    
    [self.tableView reloadData];
}

-(void)refreshView:(UIRefreshControl *)refresh {
    [_refreshControl beginRefreshing];
    SMFeedParserWrapper *parserWrapper = [[SMFeedParserWrapper alloc] init];
    
    __weak SMRSSListViewController *weakSelf = self;
    [parserWrapper parseUrl:[NSURL URLWithString:_subscribeUrl] completion:^(NSArray *items) {
        if(items && items.count){
            SMRSSModel *rssModel = [[SMRSSModel alloc]init];
            rssModel.smRSSModelDelegate = self;
            [rssModel insertRSSFeedItems:items ofFeedUrlStr:_subscribeUrl];
        }
        [weakSelf.refreshControl endRefreshing];
        [weakSelf loadTableViewFromCoreData];
    }];
}

-(void)clearAllRSS {
    SMRSSModel *model = [[SMRSSModel alloc] init];
    [model markAllAsRead:_subscribeUrl];
    [self doBack];
}

-(void)quickFavRSS:(NSIndexPath *)indexPath {
    RSS *rss = _rssArray[indexPath.row];
    SMRSSModel *model = [[SMRSSModel alloc] init];
    [model favRSS:rss];
    [self faved];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMDetailDelegate
-(void)unFav {
    [self loadTableViewFromCoreData];
}
-(void)faved {
    [self loadTableViewFromCoreData];
}

#pragma mark - SWTableViewCell delegate
//左拉出现快捷收藏按钮
-(NSArray *)rightButtons {
    NSMutableArray *rightButtons = [NSMutableArray new];
    [rightButtons sw_addUtilityButtonWithColor:[SMUIKitHelper colorWithHexString:LIST_YELLOW_COLOR] title:@"收藏"];
    return rightButtons;
}
-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [self quickFavRSS:cellIndexPath];
        }
            break;
            
        default:
            break;
    }
}
- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _rssArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SMRSSListCell heightForRSSList:[_rssArray objectAtIndex:indexPath.row]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SMRSSListCell";
    SMRSSListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SMRSSListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.rightUtilityButtons = [self rightButtons];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [SMUIKitHelper colorWithHexString:@"#f2f2f2"];
        cell.delegate = self;
    }
    
    [cell setSubscribeTitle:_subscribeTitle];
    [cell setRss:_rssArray[indexPath.row]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSS *rss = [_rssArray objectAtIndex:indexPath.row];
    
    SMDetailViewController *detailVC = [SMDetailViewController new];
    [detailVC setRss:rss];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    SMRSSModel *rssModel = [SMRSSModel new];
    [rssModel markAsRead:rss];
    [self loadTableViewFromCoreData];
}



@end
