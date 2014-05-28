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
#import "MBProgressHUD.h"
#import "SMBlurBackground.h"
#import "SMAboutWebViewController.h"
#define  krowHeight 44

@interface SMAboutViewController () <UIWebViewDelegate>
@property(nonatomic,weak)UIWebView *webView;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, weak) UIImageView *bgIcon;
@property (nonatomic,weak) MBProgressHUD *HUD;
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
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[self setupBackground];
}
/**
 *  设置背景图
 */
- (void)setupBackground
{
   
    UIImageView *imageView =  [SMBlurBackground SMbackgroundView];;
    self.bgIcon = imageView;
    [self.tableView insertSubview:imageView atIndex:0];

}
/**
 *  拖拽时背景变化
 */
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if (offsetY > 0) return;
//    CGFloat upFactor = 0.6;
//    CGFloat value = 10;
//    CGFloat upMin = - (_bgIcon.frame.size.height / value) / (1 - upFactor);
//    if (offsetY >= upMin) {
//        _bgIcon.transform = CGAffineTransformMakeTranslation(0, offsetY * upFactor);
//    } else {
//        CGAffineTransform transform = CGAffineTransformMakeTranslation(0, offsetY - upMin * (1 - upFactor));
//        CGFloat s = 1 + (upMin - offsetY) * 0.005;
//        _bgIcon.transform = CGAffineTransformScale(transform, s, s);
//    }
//}


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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    SMRSSaboutgroup *group = self.groups[indexPath.section];
    SMRSSaboutModel *about = group.abouts[indexPath.row];
    
    cell.imageView.image = [UIImage imageNamed:about.icon];
    cell.imageView.layer.cornerRadius = 22;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.frame = CGRectMake(0, 0, 40, 40);
    cell.textLabel.text = about.title;
    cell.detailTextLabel.text = about.link;
    
    //添加cell分割线
//    CGFloat lineViewX = 65;
//    CGFloat lineViewY = krowHeight-1;
//    CGFloat lineViewW = self.view.bounds.size.width - lineViewX -5;
//    CGFloat lineViewH = 1;
//    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(lineViewX, lineViewY, lineViewW , lineViewH)];
//    lineView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
//    [cell.contentView addSubview:lineView];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMRSSaboutgroup *group = self.groups[indexPath.section];
    SMRSSaboutModel *about = group.abouts[indexPath.row];
    
    SMAboutWebViewController *webVC = [[SMAboutWebViewController alloc]initWithNibName:nil bundle:nil];
    webVC.url = about.link;
    webVC.title = about.title;
    [self.navigationController pushViewController:webVC animated:YES];
    
    
//    //加载webview
//    UIWebView *webView = [[UIWebView alloc]init];
//    webView.frame = self.view.bounds;
//    webView.delegate =self;
//    [self.view addSubview:webView];
//    
//    //加载指定页面
//    NSString * str = about.link;
//    NSURL *url = [NSURL URLWithString:str];
//    NSURLRequest * request = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:request];
    
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

