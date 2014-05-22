//
//  SMDetailViewController.m
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMDetailViewController.h"
#import "SMDetailViewBottomBar.h"
#import "SMUIKitHelper.h"
#import "SMRSSModel.h"
#import <ViewUtils.h>

@interface SMDetailViewController ()<SMDetailViewBottomBarDelegate>

@property(nonatomic,strong)NSString *showContent;
@property(nonatomic,strong)SMRSSModel *rssModel;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)SMDetailViewBottomBar *bottomBar;

@end

@implementation SMDetailViewController

-(void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadView {
    [super loadView];
//    UISwipeGestureRecognizer *recognizer;
//    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doBack)];
//    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//    [[self view]addGestureRecognizer:recognizer];
//    recognizer = nil;
    
    _bottomBar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SMDetailViewBottomBar class]) owner:nil options:nil] lastObject];
    _bottomBar.delegate = self;
    _bottomBar.bottom = self.view.bounds.size.height;

    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.height -= _bottomBar.height;
    [_webView setBackgroundColor:[UIColor whiteColor]];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.directionalLockEnabled = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_webView];
    [self.view addSubview:_bottomBar];

    UIView *statusBarBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, STATUS_BAR_HEIGHT)];
    [statusBarBackView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:statusBarBackView];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    _rssModel = [[SMRSSModel alloc]init];
    self.title = _rss.title;
    [self renderDetailViewFromRSS];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
//    [self renderDetailViewFromRSS];
}

-(void)renderDetailViewFromRSS {
    
    _showContent = _rss.content;
    if ([_rss.content isEqualToString:@"无内容"]) {
        _showContent = _rss.summary;
    }
    
    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"js.html"];
    
    NSError *err=nil;
    NSString *mTxt=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd HH:mm"];
    NSString *publishDate = [formatter stringFromDate:_rss.date];
    NSString *htmlStr = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\"><style>body{color:#333333;font-size:12pt;}</style></head><body><h3><a style=\"color:#333333;text-decoration:none;\" href=\"%@\">%@</a></h3><p style=\"text-align:center;font-size:9pt\">%@ 发表于 %@</p>%@%@</body></html>",_rss.link,_rss.title,_rss.author,publishDate,_showContent,mTxt];
    [_webView loadHTMLString:htmlStr baseURL:nil];
    
    [_rssModel markAsRead:_rss];
    [_bottomBar fillWithRSS:_rss];
}

-(void)favRSS {
    [_rssModel favRSS:_rss];
    _rss.isFav = @1;
    [_bottomBar fillWithRSS:_rss];
    [self.delegate faved];
}

-(void)unFavRSS {
    [_rssModel unFavRSS:_rss];
    _rss.isFav = @0;
    [_bottomBar fillWithRSS:_rss];
    [self.delegate unFav];
    [self doBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMDetailViewBottomBarDelegate

- (void)bottomBarBackButtonTouched:(id)sender;
{
    [self doBack];
}

- (void)bottomBarFavButtonTouched:(id)sender;
{
    if ([_rss.isFav isEqual:@1]) {
        [self unFavRSS];
    } else {
        [self favRSS];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
