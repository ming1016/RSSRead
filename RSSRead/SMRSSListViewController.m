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
        self.title = @"列表";
    }
    //初始化
    self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //下拉刷新
    _refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshControl;
    
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadTableViewFromCoreData];
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
                    [rssModel insertRSSFeedItem:item withFeedUrlStr:_subscribeUrl];
                    
                    RSS *rss = [[RSS alloc] init];
                    rss.author = item.author ? item.author : @"未知作者";
                    rss.content = item.content ? item.content : @"无内容";
                    rss.createDate = [NSDate date];
                    rss.date = item.date;
                    rss.identifier = item.identifier;
                    rss.isFav = @0;
                    rss.isRead = @0;
                    rss.link = item.link ? item.link : @"无连接";
                    rss.subscribeUrl = _subscribeUrl;
                    rss.summary = item.summary ? item.summary : @"无描述";
                    rss.title = item.title ? item.title : @"无标题";
                    rss.updated = item.updated;
                    
                    [_rssArray addObject:rss];
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
    return [SMRSSListCell heightForRSSList:[_rssArray objectAtIndex:indexPath.row]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SMRSSListCell";
    SMRSSListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SMRSSListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [SMUIKitHelper colorWithHexString:@"#f2f2f2"];
    }
    
//    if (_rssArray.count > 0) {
        [cell setSubscribeTitle:_subscribeTitle];
        [cell setRss:_rssArray[indexPath.row]];
        
//    }
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
