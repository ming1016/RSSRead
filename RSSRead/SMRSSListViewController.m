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
@property(nonatomic,strong)SMAppDelegate *appDelegate;
@property(nonatomic,strong)NSMutableArray *rssArray;
@property(nonatomic,strong)SMDetailViewController *detailVC;
@property(nonatomic,strong)SMRSSModel *rssModel;
@property(nonatomic,strong)MWFeedParser *feedParser;
@property(nonatomic,strong)MWFeedInfo *feedInfo;
@property(nonatomic,strong)NSMutableArray *parsedItems;
@end

@implementation SMRSSListViewController {
    UIRefreshControl *_refreshControl;
}

-(void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadView {
    [super loadView];
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doBack)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view]addGestureRecognizer:recognizer];
    recognizer = nil;
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
    if (_isFav) {
        self.title = @"收藏列表";
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"全部标记已读" style:UIBarButtonItemStylePlain target:self action:@selector(clearAllRSS)];
        
        self.title = @"列表";
    }
    //初始化
    _parsedItems = [NSMutableArray array];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    _detailVC = [[SMDetailViewController alloc]initWithNibName:nil bundle:nil];
    _detailVC.delegate = self;
    self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //下拉刷新
    _refreshControl = [[UIRefreshControl alloc]init];
    [_refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshControl;
    
    [self loadTableViewFromCoreData];
    
    _rssModel = [[SMRSSModel alloc]init];
}



-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_isNewVC == YES) {
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        _isNewVC = NO;
        [self loadTableViewFromCoreData];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

-(void)loadTableViewFromCoreData {
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"RSS";
    getModel.sortName = @"date";
    if (_isFav) {
        //
        getModel.predicate = [NSPredicate predicateWithFormat:@"isFav=1"];
    } else {
        getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@",_subscribeUrl];
    }
    
    NSArray *fetchedRecords = [_appDelegate getFetchedRecords:getModel];
    _rssArray = [NSMutableArray arrayWithArray:fetchedRecords];
    if (!_isFav && _rssArray.count == 0) {
        //
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:[NSURL URLWithString:_subscribeUrl]];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;
        [_feedParser parse];
    }
    
    [self.tableView reloadData];
}

-(void)refreshView:(UIRefreshControl *)refresh {
//    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"更新中..."];
    [_refreshControl beginRefreshing];
    _feedParser = [[MWFeedParser alloc]initWithFeedURL:[NSURL URLWithString:_subscribeUrl]];
    _feedParser.delegate = self;
    _feedParser.feedParseType = ParseTypeFull;
    _feedParser.connectionType = ConnectionTypeAsynchronously;
    [_feedParser parse];
    
}

-(void)clearAllRSS {
    [_rssModel markAllAsRead:_subscribeUrl];
    [self doBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MWFeedParser Delegate
-(void)feedParserDidStart:(MWFeedParser *)parser {
    
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    _feedInfo = info;
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    if (item.title) {
        [_parsedItems addObject:item];
    }
}

-(void)feedParserDidFinish:(MWFeedParser *)parser {
    if (_parsedItems && [_parsedItems count]) {
        SMRSSModel *rssModel = [[SMRSSModel alloc]init];
        rssModel.smRSSModelDelegate = self;
        [rssModel insertRSS:_parsedItems withFeedInfo:_feedInfo];
    }
    [_refreshControl endRefreshing];
}

#pragma mark - rssModelDelegate
-(void)rssInserted {
    [self loadTableViewFromCoreData];
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
    
    if (_rssArray.count > 0) {
        [cell setSubscribeTitle:_subscribeTitle];
        [cell setRss:_rssArray[indexPath.row]];
        
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RSS *rss = [_rssArray objectAtIndex:indexPath.row];
    [_detailVC setRss:rss];
    
    [self.navigationController pushViewController:_detailVC animated:YES];
    
    [_rssModel markAsRead:rss];
    [self loadTableViewFromCoreData];
}



@end
