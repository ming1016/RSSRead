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

@property(nonatomic,weak)NSManagedObjectContext *managedObjectContext;
//@property(nonatomic,strong)NSMutableArray *parsedItems;
@property(nonatomic,strong)NSDateFormatter *dateFormatter;
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)MWFeedInfo *feedInfo;

@property(nonatomic,strong)UITableView *tbView;
@property(nonatomic,strong)NSMutableArray *allSurscribes;


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
//    _parsedItems = [NSMutableArray array];
    _allSurscribes = [NSMutableArray array];
    
    //测试Core Data
    _managedObjectContext = APP_DELEGATE.managedObjectContext;
    
    


    [self getAllSubscribeSources];
    
    [self performSelectorInBackground:@selector(fetchRss) withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAllSubscribeSources];
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
//    for (Subscribes *rssSc in _allSurscribes) {
//        NSLog(@"title:%@ link:%@ summary:%@ url:%@ count:%d",rssSc.title,rssSc.link,rssSc.summary,rssSc.url,[rssSc.total intValue]);
//    }
}

- (void)fetchRss{
    [_allSurscribes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Subscribes *subscribe = (Subscribes *)obj;
        SMFeedParserWrapper *parserWrapper = [[SMFeedParserWrapper alloc] init];
        
        [parserWrapper parseUrl:[NSURL URLWithString:subscribe.url] completion:^(NSArray *items) {
            if(items && items.count){
                SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                rssModel.smRSSModelDelegate = self;
                [rssModel insertRSSFeedItems:items ofFeedUrlStr:subscribe.url];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tbView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                });
        }
        }];
    }];
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

#pragma mark - moreDelegate
-(void)addSubscribeToMainViewController:(Subscribes *)subscribe {
    [self getAllSubscribeSources];
}


@end
