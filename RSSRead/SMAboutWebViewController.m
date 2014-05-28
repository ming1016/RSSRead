//
//  SMAboutWebViewController.m
//  RSSRead
//
//  Created by ming on 14-5-28.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAboutWebViewController.h"
#import "MBProgressHUD+Ext.h"

@interface SMAboutWebViewController ()<UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property (nonatomic,weak) MBProgressHUD *HUD;
@end

@implementation SMAboutWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadView {
    [super loadView];
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    [_webView setBackgroundColor:[UIColor whiteColor]];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.directionalLockEnabled = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [_webView setOpaque:NO]; // 默认是透明的
    [self.view addSubview:_webView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}
-(void)setUrl:(NSString *)url {
    NSLog(@"dddd %@",url);
    _url = url;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    //显示的文字
    HUD.labelText = @"已阅正在为您努力加载中";
    //是否有庶罩
    HUD.dimBackground = YES;
    [HUD show:YES];
    self.HUD =HUD;
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.HUD hide:YES afterDelay:0.5];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.HUD.labelText = @"亲,你的网络可能有问题.";
    [self.HUD hide:YES afterDelay:2];
    [self.webView removeFromSuperview];
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
