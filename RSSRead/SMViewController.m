//
//  SMViewController.m
//  RSSRead
//
//  Created by ming on 14-3-3.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMViewController.h"

#import "SMUIKitHelper.h"
#import "AFNetworking.h"

#import "RSS.h"

#import "Subscribes.h"
#import "SMAppDelegate.h"

#import "SMSubscribeCell.h"
#import "SMRSSListViewController.h"


@interface SMViewController ()<UINavigationControllerDelegate>

@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSArray *fetchedRSSArray;
@property(nonatomic,strong)MWFeedParser *feedParser;
@property(nonatomic,strong)NSString *fetchRSSUrl;
@property(nonatomic,strong)NSMutableArray *parsedItems;
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)MWFeedInfo *feedInfo;

@property(nonatomic,strong)UITableView *tbView;
@property(nonatomic,strong)NSMutableArray *allSurscribes;
@property(nonatomic,strong)SMAppDelegate *appDelegate;
@property(nonatomic,strong)SMRSSListViewController *rssListVC;
@property(nonatomic,strong)SMGetFetchedRecordsModel *getModel;

@end

@implementation SMViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (self.title) {
        //
    } else {
        self.title = @"已阅1.0";
    }
    
    self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"更多" style:UIBarButtonItemStylePlain target:self action:@selector(seeMore)];
    
    //界面
    _tbView = [SMUIKitHelper tableViewWithRect:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBARHEIGHT) delegateAndDataSource:self];
    [_tbView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tbView];
    
    //初始化
    _rssListVC = [[SMRSSListViewController alloc]initWithNibName:nil bundle:nil];
    _parsedItems = [NSMutableArray array];
    _getModel = [[SMGetFetchedRecordsModel alloc]init];
    
    //测试Core Data
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
    
    [self loadTabelViewFromCoreData];
    
//    //测试AFNetworking
//    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
//
//    //激活
//    NSDictionary *par = @{
//                          @"mac": @"kd3.32.3",
//                          @"imei": @"dskafdksa",
//                          @"bluetooth_addr":@"kdkd2.2.22",
//                          };
//    NSString *urlString = [NSString stringWithFormat:@"%@active",SERVER_URL];
//    [manager POST:urlString parameters:par success:^(AFHTTPRequestOperation *operation,id responseObject){
//        NSLog(@"JSON:%@",responseObject);
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        NSLog(@"Error %@",error);
//    }];
    
//    NSString *token = @"233232daddasf";
    //修改资料

//    NSDictionary *par = @{
//                          @"name": @"小灰灰",
//                          @"gender":@"1",
//                          @"age":@"33",
//                          @"height":@"175",
//                          @"weight":@"120",
//                          @"job":@"猎人",
//                          @"description":@"来自北方的狼",
//                          @"token":token
//                          };
//    NSString *urlString = [NSString stringWithFormat:@"%@profile",SERVER_URL];
//    [manager POST:urlString parameters:par success:^(AFHTTPRequestOperation *operation,id responseObject){
//        NSLog(@"JSON:%@",responseObject);
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        NSLog(@"Error%@",error);
//    }];
    
    //读取主播列表
//    NSDictionary *par = @{
//                          @"gender": @"1",
//                          @"page_index":@"1",
//                          @"page_size":@"20",
//                          @"sort_by":@"1"
//                          };
//    NSString *urlString = [NSString stringWithFormat:@"%@getpresenter",SERVER_URL];
//    [manager POST:urlString parameters:par success:^(AFHTTPRequestOperation *operation,id responseObject){
//        NSLog(@"JSON:%@",responseObject);
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        NSLog(@"Error%@",error);
//    }];
    
    //发送留言
//    NSDictionary *par = @{
//                          @"uid": @"11",
//                          @"content":@"这个是消息",
//                          @"token":token
//                          };
//    NSString *urlString = [NSString stringWithFormat:@"%@sendmessage",SERVER_URL];
//    [manager POST:urlString parameters:par success:^(AFHTTPRequestOperation *operation,id responseObject){
//        NSLog(@"JSON:%@",responseObject);
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        NSLog(@"Error%@",error);
//    }];
    
    //列出留言
//    NSDictionary *par = @{
//                          @"uid": @"11",
//                          @"page_size":@"20",
//                          @"page_index":@"1",
//                          @"token":token
//                          };
//    NSString *urlString = [NSString stringWithFormat:@"%@getmessagewithpresenter",SERVER_URL];
//    [manager POST:urlString parameters:par success:^(AFHTTPRequestOperation *operation,id responseObject){
//        
//        NSLog(@"JSON:%@",responseObject);
//    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
//        NSLog(@"Error%@",error);
//    }];

    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadTabelViewFromCoreData];
}

-(void)loadTabelViewFromCoreData {
    //查看所有的订阅源
    _getModel.entityName = @"Subscribes";
    _getModel.sortName = @"total";
    _allSurscribes = [NSMutableArray arrayWithArray:[_appDelegate getFetchedRecords:_getModel]];
    if (_allSurscribes && [_allSurscribes count]) {
        
    } else {
        //从plist文件中读取推荐源
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"RecommendFeedList" ofType:@"plist"];
        NSArray *recommends = [[NSArray alloc]initWithContentsOfFile:plistPath];
        
        NSError *error;
        for (NSDictionary *aDict in recommends) {
            //
            Subscribes *subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:_managedObjectContext];
            subscribe.title = aDict[@"title"];
            subscribe.summary = aDict[@"summary"];
            subscribe.link = aDict[@"link"];
            subscribe.url = aDict[@"url"];
            subscribe.createDate = [NSDate date];
            subscribe.total = @0;
            [_managedObjectContext save:&error];
        }
    }
    [_tbView reloadData];
//    for (Subscribes *rssSc in _allSurscribes) {
//        NSLog(@"title:%@ link:%@ summary:%@ url:%@ count:%d",rssSc.title,rssSc.link,rssSc.summary,rssSc.url,[rssSc.total intValue]);
//    }
}

-(void)seeMore {
    SMMoreViewController *moreVC = [[SMMoreViewController alloc]init];
    moreVC.smMoreViewControllerDelegate = self;
    moreVC.title = @"更多";
    [self.navigationController pushViewController:moreVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allSurscribes.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SMSubscribeCell";
    SMSubscribeCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SMSubscribeCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [SMUIKitHelper colorWithHexString:@"#f2f2f2"];
    }
    if (_allSurscribes.count > 0) {
        [cell setSubscribe:_allSurscribes[indexPath.row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Subscribes *aSub = _allSurscribes[indexPath.row];
    _rssListVC.subscribeUrl = aSub.url;
    [_rssListVC setSubscribeTitle:aSub.title];
    _rssListVC.isNewVC = YES;
    [self.navigationController pushViewController:_rssListVC animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //
        SMRSSModel *rssModel = [[SMRSSModel alloc]init];
        Subscribes *aSubscribe = _allSurscribes[indexPath.row];
        [rssModel deleteSubscrib:aSubscribe.url];
        [_allSurscribes removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }
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
}

#pragma mark - moreDelegate
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe {
    [self loadTabelViewFromCoreData];
}

#pragma mark - SMRSSModelDelegate
-(void)rssInserted {
    [self loadTabelViewFromCoreData];
}

#pragma mark - background mode
-(void)fetchWithCompletionHandler:(void(^)(UIBackgroundFetchResult))completionHandler {
    [self updateRSSimmedately];
}

-(void)updateRSSimmedately {
    //取
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"Subscribes";
    NSArray *allSubscribes = [_appDelegate getFetchedRecords:getModel];
    
    //
    NSDictionary *udd = [[NSUserDefaults standardUserDefaults]dictionaryForKey:@"userConfig"];
    NSUInteger subListNum = 0;
    if (udd[@"fetchSubscribeNumInBackground"]) {
        subListNum = [udd[@"fetchSubscribeNumInBackground"]integerValue];
        if (subListNum >= allSubscribes.count) {
            subListNum = 0;
        }
    }
    NSMutableDictionary *mudd = [NSMutableDictionary dictionaryWithDictionary:udd];
    mudd[@"fetchSubscribeNumInBackground"] = [NSNumber numberWithInteger:subListNum + 1];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:mudd forKey:@"userConfig"];
    [ud synchronize];
    
    Subscribes *subscribe = allSubscribes[subListNum];
    _fetchRSSUrl = subscribe.url;
    
    //解析rss
    NSURL *feedUrl = [NSURL URLWithString:_fetchRSSUrl];
    _feedParser = [[MWFeedParser alloc]initWithFeedURL:feedUrl];
    _feedParser.delegate = self;
    _feedParser.feedParseType = ParseTypeFull;
    _feedParser.connectionType = ConnectionTypeAsynchronously;
    [_feedParser parse];
}


@end
