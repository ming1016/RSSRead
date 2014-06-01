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
#import "SMRSSListCellMgr.h"
#import "RSS.h"
#import "SMScreenShotMgr.h"
#import "Subscribes.h"
#import "MBProgressHUD+Ext.h"
#import <MWFeedParser/MWFeedParser.h>
#import "SMPreferences.h"

@interface SMRSSListViewController ()<RMSwipeTableViewCellDelegate>
@property(nonatomic,strong)NSMutableArray *rssArray;
@property(nonatomic,strong)MWFeedParser *feedParser;
@property(nonatomic,weak)MBProgressHUD *HUD;
@property(nonatomic,strong)MWFeedInfo *feedInfo;
@property(nonatomic,strong)NSMutableArray *parsedItems;
@property (strong, nonatomic) NSMutableArray *cellMgrs;
@property(nonatomic,strong)UIColor *bgColor;
@property(nonatomic,strong)UIColor *selectBgColor;

@end

@implementation SMRSSListViewController {
    UIRefreshControl *_refreshControl;
    UIActivityIndicatorView *_indicator;
}

-(void)doBack {
    [self.delegate updateSubscribeList];
    [self.navigationController popViewControllerAnimated:YES];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
//        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    _rssArray = [NSMutableArray array];
    _parsedItems = [NSMutableArray array];
    
    if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
        _bgColor = [SMUIKitHelper colorWithHexString:@"#252525"];
        _selectBgColor = [UIColor darkGrayColor];
    } else {
        _bgColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
        _selectBgColor = [SMUIKitHelper colorWithHexString:@"#f2f2f2"];
    }
  
    //初始化
    self.view.backgroundColor = _bgColor;
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
    if (_isFav) {
        self.title = @"收藏列表";
    } else {
        if(_isUnsubscribed) {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加该源" style:UIBarButtonItemStylePlain target:self action:@selector(addThisRSS)];
        } else {
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全部标记已读" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllRSS)];
        }
    }
    //加上此判断主要为了解决Detail详细页返回延时问题
    if (_isNewVC) {
        _isNewVC = NO;
        [self loadTableViewFromCoreData];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [[SMScreenShotMgr sharedInstance] takeScreenShot];
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
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [SMFeedParserWrapper parseUrl:[NSURL URLWithString:_subscribeUrl] timeout:10 completion:^(NSArray *items) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if(items && items.count){
                SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                rssModel.smRSSModelDelegate = self;
                for(MWFeedItem *item in items){
                    RSS *rss = [rssModel insertRSSWithFeedItem:item withFeedUrlStr:_subscribeUrl];
                    
                    if (rss) {
                        [_rssArray addObject:rss];
                    }
                    
                }
                
                [self calculateRowHeight];
                [self.tableView reloadData];
            }
        }];
    } else {
        [self calculateRowHeight];
        [self.tableView reloadData];
    }
    
}
- (void)calculateRowHeight
{
    if(_cellMgrs == nil) {
        _cellMgrs = [NSMutableArray array];
    } else {
        [_cellMgrs removeAllObjects];
    }
    
    for (RSS *rss in _rssArray) {
        SMRSSListCellMgr *mgr = [[SMRSSListCellMgr alloc] init];
        [mgr setRss:rss];
        [_cellMgrs addObject:mgr];
    }
    
}
-(void)refreshView:(UIRefreshControl *)refresh {
    [_refreshControl beginRefreshing];
    
    __weak SMRSSListViewController *weakSelf = self;
    [SMFeedParserWrapper parseUrl:[NSURL URLWithString:_subscribeUrl] timeout:10 completion:^(NSArray *items) {
        if(items && items.count){
            SMRSSModel *rssModel = [[SMRSSModel alloc]init];
            rssModel.smRSSModelDelegate = self;
            [rssModel insertRSSFeedItems:items ofFeedUrlStr:_subscribeUrl];
        }
        [weakSelf.refreshControl endRefreshing];
        [weakSelf loadTableViewFromCoreData];
    }];
}
- (void)addThisRSS
{
    //读取解析rss
    NSURL *feedURL = [NSURL URLWithString:_subscribeUrl];
    _feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
    _feedParser.delegate = self;
    _feedParser.feedParseType = ParseTypeFull;
    _feedParser.connectionType = ConnectionTypeSynchronously;
    
    //判断添加源是否失败
    _HUD.labelText = [_feedParser parse] ? @"成功添加":@"无法解析该源";
    [self.view.window addSubview:_HUD];
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:2];
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
    SMRSSListCellMgr *mgr = _cellMgrs[indexPath.row];
    return mgr.cellHeight;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SMRSSListCell";
    SMRSSListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SMRSSListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = _selectBgColor;
    }
    cell.delegate = self;
    [cell setSubscribeTitle:_subscribeTitle];
    [cell setCellMgr:_cellMgrs[indexPath.row]];
    [cell setRss:_rssArray[indexPath.row]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSS *rss = [_rssArray objectAtIndex:indexPath.row];
    
    SMDetailViewController *detailVC = [SMDetailViewController new];
    detailVC.delegate = self;
    [detailVC setRss:rss];
    [self.navigationController pushViewController:detailVC animated:YES];
    
    SMRSSModel *rssModel = [SMRSSModel new];
    [rssModel markAsRead:rss];//标记已读
    [self loadTableViewFromCoreData];//更新列表
    [self.delegate updateSubscribeList];//更新首页已读数
}

#pragma mark - Feed解析器代理方法
-(void)feedParserDidStart:(MWFeedParser *)parser {
    NSLog(@"Started Parsing");
}
-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    if (info.title) {
        _feedInfo = info;
    } else {
    }
}
-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    if (item.title) {
        [_parsedItems addObject:item];
        //        NSLog(@"title:%@ author:%@ sum:%@ content:%@",item.title,item.author,item.summary,item.content);
    } else {
        NSLog(@"failed by item");
    }
}
-(void)feedParserDidFinish:(MWFeedParser *)parser {
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"Subscribes";
    getModel.predicate = [NSPredicate predicateWithFormat:@"url=%@",[_feedInfo.url absoluteString]];
    
    NSArray *fetchedRecords = [APP_DELEGATE getFetchedRecords:getModel];
    NSError *error;
    if (fetchedRecords.count == 0) {
        Subscribes *subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:[APP_DELEGATE managedObjectContext]];
        subscribe.title = _feedInfo.title ? _feedInfo.title : @"未命名";
        subscribe.summary = _feedInfo.summary ? _feedInfo.summary : @"无描述";
        subscribe.link = _feedInfo.link ? _feedInfo.link : @"无连接";
        subscribe.url = [_feedInfo.url absoluteString] ? [_feedInfo.url absoluteString] : @"无连接";
        subscribe.createDate = [NSDate date];
        subscribe.total = [NSNumber numberWithInteger:_parsedItems.count];
        
        if (subscribe.title) {
            [[APP_DELEGATE managedObjectContext] save:&error];
        }
    } else {
        //已存在订阅的情况
    }
    SMRSSModel *rssModel = [[SMRSSModel alloc]init];
    [rssModel insertRSSFeedItems:_parsedItems ofFeedUrlStr:[_feedInfo.url absoluteString]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"已添加" style:UIBarButtonItemStylePlain target:self action:nil];

}
-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    _HUD.labelText = @"解析失败";
    [self.view.window addSubview:_HUD];
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:2];
    
}

#pragma mark - swipTableViewCell
-(void)swipeTableViewCellWillResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    RSS *rss = _rssArray[indexPath.row];
    SMRSSModel *model = [[SMRSSModel alloc] init];
    
    if (point.x >= CGRectGetHeight(swipeTableViewCell.frame)) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
        //右拉
        [model unFavRSS:rss];
        [self unFav];
    } else if (point.x < 0 && -point.x >= CGRectGetHeight(swipeTableViewCell.frame)) {
        //左拉
        swipeTableViewCell.shouldAnimateCellReset = NO;
 
        [model favRSS:rss];
        [self faved];
//        [model dislikeRSS:rss];
//        [_rssArray removeObjectAtIndex:indexPath.row];
//        [_cellMgrs removeObjectAtIndex:indexPath.row];
//        
//        [self.tableView beginUpdates];
//        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        [self.tableView endUpdates];
        
    }
}
-(void)swipeTableViewCellDidResetState:(RMSwipeTableViewCell *)swipeTableViewCell fromPoint:(CGPoint)point animation:(RMSwipeTableViewCellAnimationType)animation velocity:(CGPoint)velocity {

    if (point.x < 0 && -point.x > CGRectGetHeight(swipeTableViewCell.frame)) {
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:swipeTableViewCell];
    }
}

@end
