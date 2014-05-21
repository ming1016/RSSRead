//
//  SMAboutViewController.m
//  RSSRead
//
//  Created by ming on 14-5-14.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAboutViewController.h"
#import "SMRSSaboutgroup.h"
#import "SMRSSaboutModel.h"

@interface SMAboutViewController () <UIWebViewDelegate>
@property(nonatomic,strong)UIWebView *webView;
@property (nonatomic, strong) NSArray *groups;
@end

@implementation SMAboutViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于";
}

- (NSArray *)groups
{
    if (_groups == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"aboutRSS.plist" ofType:nil];
        NSArray *dictArray = [NSArray arrayWithContentsOfFile:path];
        NSMutableArray *groupArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            SMRSSaboutgroup *group = [SMRSSaboutgroup groupWithDict:dict];
            
            [groupArray addObject:group];
        }
        _groups = groupArray;
    }
    return _groups;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.groups.count;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SMRSSaboutgroup *group = self.groups[section];
    return group.abouts.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"about";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    SMRSSaboutgroup *group = self.groups[indexPath.section];
    SMRSSaboutModel *about = group.abouts[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:about.icon];
    cell.imageView.layer.cornerRadius = 22;
    cell.imageView.layer.masksToBounds = YES;
    cell.textLabel.text = about.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMRSSaboutgroup *group = self.groups[indexPath.section];
    SMRSSaboutModel *about = group.abouts[indexPath.row];
    //加载webview
    UIWebView *webView = [[UIWebView alloc]init];
    webView.frame = self.view.bounds;
    webView.delegate =self;
    [self.view addSubview:webView];
    
    //加载指定页面
    NSString * str = about.link;
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    
}


/**
 *  第section组显示的头部标题
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SMRSSaboutgroup *group = self.groups[section];
    return group.title;
}
@end

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}
//
//-(void)loadView {
//    [super loadView];
//    
//    CGRect rect = self.view.bounds;
//    rect.size.height = rect.size.height - 64;
//    rect.size.width = rect.size.width;
//    _webView = [[UIWebView alloc]initWithFrame:rect];
//    [_webView setBackgroundColor:[UIColor whiteColor]];
//    _webView.scalesPageToFit = NO;
//    _webView.scrollView.directionalLockEnabled = YES;
//    _webView.scrollView.showsHorizontalScrollIndicator = NO;
//    [self.view addSubview:_webView];
//}
//
//-(void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    NSString *filePath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"about.html"];
//    NSError *err = nil;
//    NSString *htmlStr = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
//    [_webView loadHTMLString:htmlStr baseURL:nil];
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    self.title = @"关于";
//}
//
//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}
//
///*
//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//}
//*/

