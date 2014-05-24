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
    self.title = @"返回";//给navigation push过去的vc的返回有个中文提示
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
    UIBarButtonItem *loadingItem = [[UIBarButtonItem alloc]initWithCustomView:_loadingView];
    self.navigationItem.leftBarButtonItem = loadingItem;
    
    
    //界面
    _tbView = [SMUIKitHelper tableViewWithRect:CGRectMake(0, NAVBARHEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVBARHEIGHT) delegateAndDataSource:self];
    [_tbView setBackgroundColor:[UIColor clearColor]];
    [_tbView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:_tbView];
    
    //初始化
    _allSurscribes = [NSMutableArray array];
    
    //Core Data
    _managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    //Using more fashion hud by HYCircleLoadingView
    [_loadingView startAnimation];
    
    //Check the net isWorking
    _afManager = [AFHTTPRequestOperationManager manager];
    _afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [self getAllSubscribeSources];
    [_afManager GET:SERVER_OF_CHECKNETWORKING parameters:nil success:^(AFHTTPRequestOperation *operation,id responseObject){
        if ([[SMPreferences sharedInstance] isInitWithFetchRSS]) {
            [self performSelectorInBackground:@selector(fetchRss) withObject:nil];
        } else {
            [_loadingView stopAnimation];
        }
    }failure:^(AFHTTPRequestOperation *operation,NSError *error){
        [_loadingView stopAnimation];
    }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

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
    
    dispatch_group_t group = dispatch_group_create();
    
    [_allSurscribes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Subscribes *subscribe = (Subscribes *)obj;
        SMFeedParserWrapper *parserWrapper = [[SMFeedParserWrapper alloc] init];
      
        dispatch_group_enter(group);
        
        [parserWrapper parseUrl:[NSURL URLWithString:subscribe.url] completion:^(NSArray *items) {
            if(items && items.count){
                SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                rssModel.smRSSModelDelegate = self;
                [rssModel insertRSSFeedItems:items ofFeedUrlStr:subscribe.url];
                [_tbView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            dispatch_group_leave(group);
            
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [_loadingView stopAnimation];
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
//        cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc]initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor blackColor];
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

#pragma mark addsubscribesdelegate
-(void)addedRSS:(Subscribes *)subscribe {
    [self getAllSubscribeSources];
}

#pragma mark - moreDelegate
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe {
    [self getAllSubscribeSources];
}


@end
