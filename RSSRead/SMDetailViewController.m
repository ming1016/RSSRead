//
//  SMDetailViewController.m
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMDetailViewController.h"
#import "SMUIKitHelper.h"
#import "SMRSSModel.h"

@interface SMDetailViewController ()

@property(nonatomic,strong)NSString *showContent;
@property(nonatomic,strong)SMRSSModel *rssModel;
@property(nonatomic,strong)UIWebView *webView;
@end

@implementation SMDetailViewController

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
    
    CGRect rect = self.view.bounds;
    rect.size.height = rect.size.height - 64;
    rect.size.width = rect.size.width;
    _webView = [[UIWebView alloc]initWithFrame:rect];
    [_webView setBackgroundColor:[UIColor whiteColor]];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.directionalLockEnabled = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_webView];
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
    _rssModel = [[SMRSSModel alloc]init];
    [self renderDetailViewFromRSS];
    
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [_webView loadHTMLString:@"" baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view.
    self.title = @"正文";
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
    
    NSString *htmlStr = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\"><style>body{color:#333333;font-size:12pt;}</style></head><body><h3><a style=\"color:#333333;text-decoration:none;\" href=\"%@\">%@</a></h3>%@%@</body></html>",_rss.link,_rss.title,_showContent,mTxt];
    [_webView loadHTMLString:htmlStr baseURL:nil];
    
    
    [self checkRightButton];
    [_rssModel markAsRead:_rss];
}

-(void)checkRightButton {
    if ([_rss.isFav isEqual:@1]) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消收藏" style:UIBarButtonItemStylePlain target:self action:@selector(unFavRSS)];
    } else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"收藏" style:UIBarButtonItemStylePlain target:self action:@selector(favRSS)];
    }
}

-(void)favRSS {
    [_rssModel favRSS:_rss];
    _rss.isFav = @1;
    [self checkRightButton];
    [self.delegate faved];
}

-(void)unFavRSS {
    [_rssModel unFavRSS:_rss];
    _rss.isFav = @0;
    [self checkRightButton];
    [self.delegate unFav];
    [self doBack];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
