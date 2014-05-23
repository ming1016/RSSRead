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
#import "MBProgressHUD.h"
#import "UIColor+RSS.h"
#import <ViewUtils.h>

@interface SMAddRSSViewController ()<SMAddRSSToolbarDelegate,UITableViewDelegate,UITableViewDataSource,SMAddRssSoucesCellDelegate>
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
@property(nonatomic,weak)MBProgressHUD *HUD;
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
    [self.navigationController setNavigationBarHidden:YES];
    
    [self setupSearchBar];

    //加载结果页面(tableView)
    [self setupResultView];
    
    //加载toolbar
//    [self setupToolbar];
    
    //加载searchbar
    
    //加载指示层
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    _HUD =HUD;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //init
    _parsedItems = [NSMutableArray array];
    
    //Core Data
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    [super viewWillDisappear:animated];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_searchBar becomeFirstResponder];
}

- (void)btnClickAddRssUsingTag:(UIButton *)btn
{
    
    btn.backgroundColor = [UIColor colorWithRed:0.883 green:0.420 blue:0.849 alpha:0.80];
    [btn setTitle:@"已操作" forState:UIControlStateNormal];
    SMAddRssSourceModel *searchRss = _RSSArray[btn.tag];
    _searchBar.text = searchRss.url;
    [self addInputRSS];
}
#pragma mark - 根据用户输入字符串搜索RSS源
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
     _HUD.labelText = @"您的网络可能没有连接";
     [_HUD show:YES];
     [_HUD hide:YES afterDelay:2];
 }];
}

#pragma mark - tableView代理方法

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
    cell.delegate =self;
    cell.btn.tag = indexPath.row;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];

}
#pragma mark  - TextField delegate 监听键盘确认键
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    //退出键盘
    [_searchBar resignFirstResponder];
    NSString *str= _searchBar.text;
    /**
     *  判断用户是添加源 还是搜索源
     */
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"http+:[^\\s]*" options:0 error:&error];
    /**
     *  检查是否是网址,不是返回值为null
     */
    if (regex != nil) {
        NSTextCheckingResult *result = [regex firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
        if(result)
        {
             //用户添加源
            [self addInputRSS];
            return YES;
        }
    }
    //用户搜索源
    [self loadRssSourcesWithStr:str];
    
    return YES;
}

- (void)addInputRSS
{
    
    dispatch_queue_t q = dispatch_queue_create("addRSS", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(q, ^{
        //读取解析rss
        NSURL *feedURL = [NSURL URLWithString:_searchBar.text];
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;
        
        
        //判断添加源是否失败
        _HUD.labelText = [_feedParser parse] ? @"成功添加":@"无法解析该源";
        [_HUD show:YES];
        [_HUD hide:YES afterDelay:2];
    });
    
    
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
   // [self doBack];
}

-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    _HUD.labelText = @"解析失败";
    [_HUD show:YES];
    [_HUD hide:YES afterDelay:2];
    
}

/**
 *  toolbar代理方法
 */
#pragma mark - toolbar按钮点击代理方法
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

#pragma mark - 键盘显示隐藏通知
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

#pragma mark - 加载自定义控件
- (void)setupSearchBar
{
   
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 0, 50, 50)];
    [closeButton setTitleColor:[UIColor rss_cyanColor] forState:UIControlStateNormal];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    [closeButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [closeButton sizeToFit];
    [closeButton addTarget:self action:@selector(doBack) forControlEvents:UIControlEventTouchUpInside];
    
    SMAddRssSearchBar *searchBar = [SMAddRssSearchBar searchBar];
    searchBar.frame = CGRectMake(closeButton.right + 12, STATUS_BAR_HEIGHT + 2, 0, 32);
    searchBar.width = SCREEN_WIDTH - searchBar.left - 6;
    searchBar.top = STATUS_BAR_HEIGHT + (44 - searchBar.height)/2;
    searchBar.delegate =self;
    self.searchBar = searchBar;
    
    closeButton.top = searchBar.top + (searchBar.height - closeButton.height)/2;
    
    [self.view addSubview:searchBar];
    [self.view addSubview:closeButton];

}

- (void)setupResultView
{
    UITableView *tableView = [[UITableView alloc] init];
    tableView.frame = CGRectMake(0, 0, 320, self.view.frame.size.height-80);
    tableView.top = 44 + STATUS_BAR_HEIGHT;
    tableView.height = self.view.height - tableView.top;
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
#pragma mark - 通知移除
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
