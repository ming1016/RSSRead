//
//  SMMoreViewController.m
//  RSSRead
//
//  Created by ming on 14-3-4.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMMoreViewController.h"
#import "SMUIKitHelper.h"
#import "SMMoreCell.h"
#import "SMRSSListViewController.h"


@interface SMMoreViewController ()
@property(nonatomic,strong)NSArray *optionArr;
@end

@implementation SMMoreViewController

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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _optionArr = @[
                   @{
                       @"cn": @"添加新订阅",
                       @"en":@"addRSS"
                       },
                   @{
                       @"cn":@"收藏",
                       @"en":@"fav"
                       },
//                   @{
//                       @"cn": @"设置",
//                       @"en":@"setting"
//                       },
                   
                   ];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_optionArr count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [SMMoreCell heightForOption];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SMMoreCell";
    SMMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[SMMoreCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (_optionArr.count > 0) {
        NSDictionary *aOption = _optionArr[indexPath.row];
        [cell setOption:aOption];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *aOption = _optionArr[indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([aOption[@"en"]isEqualToString:@"addRSS"]) {
        //添加rss
        SMAddRSSViewController *addRSSVC = [[SMAddRSSViewController alloc]initWithNibName:nil bundle:nil];
        addRSSVC.smAddRSSViewControllerDelegate = self;
        [self.navigationController pushViewController:addRSSVC animated:YES];
    }
    if ([aOption[@"en"]isEqualToString:@"fav"]) {
        //收藏的
        SMRSSListViewController *rsslistVC = [[SMRSSListViewController alloc]initWithNibName:nil bundle:nil];
        rsslistVC.isFav = YES;
        [self.navigationController pushViewController:rsslistVC animated:YES];
    }
    if ([aOption[@"en"]isEqualToString:@"setting"]) {
        //设置
        
    }
}

#pragma mark addsubscribesdelegate
-(void)addedRSS:(Subscribes *)subscribe {
    NSLog(@"add subscribe1111111");
    [_smMoreViewControllerDelegate addSubscribeToMainViewController:subscribe];
}



@end
