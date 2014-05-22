//
//  SMAddRSSViewController.m
//  RSSRead
//
//  Created by ming on 14-3-18.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAddRSSViewController.h"
#import "SMUIKitHelper.h"
#import "SMAppDelegate.h"
#import "RSS.h"
#import "SMRSSModel.h"
#import "SMAddRSSToolbar.h"
#import "SMAddRssSearchBar.h"
#import "AFNetworking.h"
#import "SMAddRssSourceModel.h"
#import "SMAddRssSoucesCell.h"

@interface SMAddRSSViewController ()<SMAddRSSToolbarDelegate,UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)MWFeedParser *feedParser;
@property(nonatomic,strong)Subscribes *subscribe;
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,strong)MWFeedInfo *feedInfo;
@property(nonatomic,strong)NSMutableArray *parsedItems;
@property(nonatomic,strong)SMAppDelegate *appDelegate;
@property(nonatomic,weak) SMAddRssSearchBar *searchBar;
@property(nonatomic,weak) SMAddRSSToolbar *toolbar;
@property(nonatomic,strong)NSMutableArray *RSSArray;
@property(nonatomic,weak)UITableView *tableView;
@end

@implementation SMAddRSSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
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

    //加载结果页面(tableView)
    [self setupResultView];
   
    //加载toolbar
    [self setupToolbar];
    
    //加载searchbar
    [self setupSearchBar];
    
    //init
    _parsedItems = [NSMutableArray array];
    
    //Core Data
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
    [self loadRssSourcesWithStr:@"伯乐在线"];
}

/**
 *  根据用户输入字符串搜索RSS源
 *
 *  @param str 用户输入字符串
 */
- (void)loadRssSourcesWithStr:(NSString *)str
{
    
    AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
    /**
     *  封装请求参数
     */
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"context"] =@"";
    params[@"hl"] = @"zh_CN";
    params[@"q"]=str;
    params[@"key"] = @"ABQIAAAA6C4bndUCBastUbawfhKGURTFnqBuwPowtiyJohQxh-8vJXk-MBTetbTPnQAbLgs9lUkeE34hNbC15Q";
    params[@"v"] =@"1.0";

    [mgr GET:@"http://www.google.com/uds/GfindFeeds" parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
     
     NSDictionary *dic = responseObject[@"responseData"];
     NSArray *rssArray = dic[@"entries"];
     NSMutableArray *Array = [NSMutableArray array];
       for (NSDictionary *dict in rssArray) {
        SMAddRssSourceModel *rssModel = [SMAddRssSourceModel rssWithDict:dict];
            [Array addObject:rssModel];
                 }
        _RSSArray = Array;

         [self.tableView reloadData];
 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
 }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _RSSArray.count;
}

//表行高
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1.创建cell
    SMAddRssSoucesCell *cell = [SMAddRssSoucesCell cellWithTableView:tableView];
    cell.searchRss = self.RSSArray[indexPath.row];
   
    return cell;
}

#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    

    [_searchBar resignFirstResponder];
    if (_searchBar.text != nil) {
        //
        NSString *tfString =nil;
        #warning 这边判断要重写
        if ((_searchBar.text.length >7)&&[[_searchBar.text substringToIndex:7]isEqualToString:@"http://"]) {
            tfString = _searchBar.text;
        } else {
            tfString = [NSString stringWithFormat:@"http://%@",_searchBar.text];
        }
        //读取解析rss
        NSURL *feedURL = [NSURL URLWithString:tfString];
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;
        [_feedParser parse];
        //这里需要一个hud不让用户操作。
    }
    return YES;
}

#pragma mark - MWFeedParserDelegate
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
    NSArray *fetchedRecords = [_appDelegate getFetchedRecords:getModel];
    NSError *error;
    if (fetchedRecords.count == 0) {
        _subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:_managedObjectContext];
        _subscribe.title = _feedInfo.title ? _feedInfo.title : @"未命名";
        _subscribe.summary = _feedInfo.summary ? _feedInfo.summary : @"无描述";
        _subscribe.link = _feedInfo.link ? _feedInfo.link : @"无连接";
        _subscribe.url = [_feedInfo.url absoluteString] ? [_feedInfo.url absoluteString] : @"无连接";
        _subscribe.createDate = [NSDate date];
        _subscribe.total = [NSNumber numberWithInteger:_parsedItems.count];
        
        
        if (_subscribe.title) {
            [_managedObjectContext save:&error];
            [_smAddRSSViewControllerDelegate addedRSS:_subscribe];
        }
    } else {
        //已存在订阅的情况
    }
    SMRSSModel *rssModel = [[SMRSSModel alloc]init];
    [rssModel insertRSSFeedItems:_parsedItems ofFeedUrlStr:[_feedInfo.url absoluteString]];
    [self doBack];
}

-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
}

/**
 *  toolbar代理方法
 */
- (void)Toolbar:(SMAddRSSToolbar *)toolbar didClickedButtonWithString:(NSString *)str
{
    if ([str isEqualToString:@"clear"]) {
        _searchBar.text = @"";
        _searchBar.placeholder = @"请重新输入RSS";
    }
    else{
    _searchBar.text = [_searchBar.text stringByAppendingString:str];
    }
}

/**
 *  键盘即将显示的时候调用
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.toolbar.hidden = NO;
    
    [UIView animateWithDuration:duration animations:^{
        self.toolbar.transform = CGAffineTransformMakeTranslation(0, -keyboardF.size.height-44);
    }];
}

/**
 *  键盘即将退出的时候调用
 */
- (void)keyboardWillHide:(NSNotification *)note
{
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{

        self.toolbar.transform = CGAffineTransformIdentity;
        self.toolbar.hidden = YES;
        
    }];
}

- (void)setupSearchBar
{
    SMAddRssSearchBar *searchBar = [SMAddRssSearchBar searchBar];
    searchBar.frame = CGRectMake(5, 79, 310, 40);
    searchBar.delegate =self;
    self.searchBar = searchBar;
    [self.view addSubview:searchBar];
}

- (void)setupResultView
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0,80, 320, 400);
    tableView.delegate =self;
    tableView.dataSource =self;
    _tableView =tableView;
    [self.view addSubview:tableView];
}


/**
 *  加载toolbar
 */
-(void)setupToolbar
{
    SMAddRSSToolbar *toolbar = [[SMAddRSSToolbar alloc] init];
    toolbar.delegate =self;
    [self.view addSubview:toolbar];
    self.toolbar = toolbar;
    // 3.监听键盘的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end

//    //提示lable
//    CGRect rect = _searchBar.frame;
//    rect.origin.y += 55;
//    NSString *sendingText = @"您输入的rss正在添加中，请耐心等待...";
//    rect.size = [sendingText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
//    //label of sending
//    _lbSending = [SMUIKitHelper labelShadowWithRect:rect text:sendingText textColor:@"#333333" fontSize:14];
//    [self.view addSubview:_lbSending];
//    _lbSending.hidden = YES;
