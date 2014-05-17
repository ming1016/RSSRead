//
//  SMAboutViewController.m
//  RSSRead
//
//  Created by ming on 14-5-14.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAboutViewController.h"

@interface SMAboutViewController ()
@property(nonatomic,strong)UIWebView *webView;
@end

@implementation SMAboutViewController

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
    
    CGRect rect = self.view.bounds;
    rect.size.height = rect.size.height - 64;
    rect.size.width = rect.size.width;
    _webView = [[UIWebView alloc]initWithFrame:rect];
    [_webView setBackgroundColor:[UIColor whiteColor]];
    _webView.scalesPageToFit = NO;
    _webView.scrollView.directionalLockEnabled = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_webView];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString *filePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"about.html"];
    NSError *err = nil;
    NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    [_webView loadHTMLString:htmlStr baseURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
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
