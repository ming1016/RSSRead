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
#import "MBProgressHUD.h"
#import "HYCircleLoadingView.h"
#import "SMBlurBackground.h"
#import "UIColor+RSS.h"
#import "SMPreferences.h"

@interface SMViewController ()<UINavigationControllerDelegate>

@property(nonatomic,weak)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)MWFeedInfo *feedInfo;

@property(nonatomic,strong)UITableView *tbView;
@property(nonatomic,strong)NSMutableArray *allSurscribes;
@property(nonatomic,strong)MBProgressHUD *hud;
@property(nonatomic,strong)HYCircleLoadingView *loadingView;
@property(nonatomic,strong)AFHTTPRequestOperationManager *afManager;
@property(nonatomic,strong)QBlurView *blurView;
@property(nonatomic,strong)UIBarButtonItem *loadingItem;
@property(nonatomic,strong)UIBarButtonItem *btRefreash;
@property(nonatomic)BOOL isInited;
@end

@implementation SMViewController

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"首页";
    }
    return self;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 设置title view
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_view"]];
    [self.navigationItem setTitleView:imgView];
    
    [self.view addSubview:[SMBlurBackground SMbackgroundView]];
    
    UIView *naviWhiteCover = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, NAVBARHEIGHT)];
    naviWhiteCover.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:naviWhiteCover];
    
    //更多按钮
    self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(addNewRSS)];
    //读取中的hud
    _loadingView = [[HYCircleLoadingView alloc] initWithFrame:CGRectMake(0, 0, 23, 23)];
    _loadingView.lineColor = [UIColor rss_cyanColor];
    _loadingItem = [[UIBarButtonItem alloc]initWithCustomView:_loadingView];
    //刷新
    _btRefreash = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(fetchRss)];
    
    self.navigationItem.leftBarButtonItem = _loadingItem;
    [_loadingView startAnimation];
    
    //界面
    _tbView = [SMUIKitHelper tableViewWithRect:CGRectMake(0, NAVBARHEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBARHEIGHT - QM_TABLEVIEW_ROWHEIGHT) delegateAndDataSource:self];
    [_tbView setBackgroundColor:[UIColor clearColor]];
    [_tbView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tbView];
    
    //初始化
    _allSurscribes = [NSMutableArray array];
    
    //Core Data
    _managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    
    //Using more fashion hud by HYCircleLoadingView
    
    //Check the net isWorking
    _afManager = [AFHTTPRequestOperationManager manager];
    _afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    if ([[SMPreferences sharedInstance] isInitWithFetchRSS]) {
        [_afManager GET:SERVER_OF_CHECKNETWORKING parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject){
            [self performSelectorInBackground:@selector(fetchRss) withObject:nil];
        }failure:^(AFHTTPRequestOperation *operation,NSError *error){
            self.navigationItem.leftBarButtonItem = _btRefreash;
        }];
    } else {
        self.navigationItem.leftBarButtonItem = _btRefreash;
    }
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAllSubscribeSources];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//}

-(void)getAllSubscribeSources {
    //查看所有的订阅源
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc] init];
    getModel.entityName = @"Subscribes";
    getModel.sortName = @"total";
    [_allSurscribes removeAllObjects];
    [_allSurscribes addObjectsFromArray:[APP_DELEGATE getFetchedRecords:getModel]];
    
    if (![_allSurscribes count]){
        //从plist文件中读取推荐源
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"RecommendFeedList" ofType:@"plist"];
        NSArray *recommends = [[NSArray alloc]initWithContentsOfFile:plistPath];
        
        for (NSDictionary *aDict in recommends) {
            NSError *error;
            Subscribes *subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:APP_DELEGATE.managedObjectContext];
            subscribe.title = aDict[@"title"];
            subscribe.summary = aDict[@"summary"];
            subscribe.link = aDict[@"link"];
            subscribe.url = aDict[@"url"];
            subscribe.createDate = [NSDate date];
            subscribe.total = @0;
            subscribe.lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
            subscribe.updateTimeInterval = @60;//默认1分钟更新一次
            [APP_DELEGATE.managedObjectContext save:&error];
            if(!error){
                [_allSurscribes addObject:subscribe];
            }else{
                NSLog(@"save subscribe data error");
            }
        }
    }
    [_tbView reloadData];
}
#pragma mark - 获取rss
- (void)fetchRss{
    self.navigationItem.leftBarButtonItem = _loadingItem;
    if (_isInited) {
        [_loadingView startAnimation];
    } else {
        _isInited = YES;
    }
    
    dispatch_group_t group = dispatch_group_create();
    

    [_allSurscribes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Subscribes *subscribe = (Subscribes *)obj;
        
        dispatch_group_enter(group);
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SMFeedParserWrapper parseUrl:[NSURL URLWithString:subscribe.url] timeout:10 completion:^(NSArray *items) {
                if(items && items.count){
                    SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                    rssModel.smRSSModelDelegate = self;
                    [rssModel insertRSSFeedItems:items ofFeedUrlStr:subscribe.url];
                    [_tbView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                }
                
                dispatch_group_leave(group);
                
            }];

        });
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_loadingView stopAnimation];
        self.navigationItem.leftBarButtonItem = _btRefreash;
    });
}

//跳转到添加控制器
-(void)addNewRSS {
    SMAddRSSViewController *addRSSVC = [[SMAddRSSViewController alloc]initWithNibName:nil bundle:nil];
    addRSSVC.smAddRSSViewControllerDelegate = self;
    [self.navigationController pushViewController:addRSSVC animated:YES];
    //    [self.navigationController presentViewController:addRSSVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

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
        cell.selectedBackgroundView.backgroundColor = [UIColor rss_cyanColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    if (_allSurscribes.count > 0) {
        [cell setSubscribe:_allSurscribes[indexPath.row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Subscribes *aSub = _allSurscribes[indexPath.row];
    SMRSSListViewController * rssListVC = [[SMRSSListViewController alloc] init];
    rssListVC.subscribeUrl = aSub.url;
    rssListVC.subscribeTitle = aSub.title;
    rssListVC.isNewVC = YES;
    rssListVC.delegate = self;
    rssListVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:rssListVC animated:YES];
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

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

#pragma mark - rsslistviewcontroller delegate
-(void)updateSubscribeList {
    [self getAllSubscribeSources];
}

#pragma mark - addsubscribesdelegate
-(void)addedRSS:(Subscribes *)subscribe {
    [self getAllSubscribeSources];
}

#pragma mark - moreDelegate
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe {
    [self getAllSubscribeSources];
}


@end
