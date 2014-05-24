//
//  SMSettingViewController.m
//  RSSRead
//
//  Created by ming on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMSettingViewController.h"

@interface SMSettingViewController ()
@property(nonatomic,strong)RETableViewManager *manager;
@property(nonatomic,strong)RETableViewSection *generalSection;
@property(nonatomic,strong)RETableViewSection *backgroundImageSection;

@property(nonatomic,strong)REBoolItem *isInitWithFetchRSS;
@property(nonatomic,strong)REBoolItem *isUserYourOwnBackgroundImage;
@property(nonatomic,strong)RETableViewItem *backgroundImageSelect;
@end

@implementation SMSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(valuesButtonPressed:)];
    
    _manager = [[RETableViewManager alloc]initWithTableView:self.tableView delegate:self];
    _generalSection = [self addGeneralSection];
    _backgroundImageSection = [self addBackgroundImageSection];
    
    //TODO:完成功能
}

-(RETableViewSection *)addGeneralSection{
//    __typeof (&*self) __weak weakSelf = self;
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"通用"];
    [self.manager addSection:section];
    
    _isInitWithFetchRSS = [REBoolItem itemWithTitle:@"启动时是否自动同步RSS" value:YES switchValueChangeHandler:^(REBoolItem *item){
        NSLog(@"Value: %@", item.value ? @"YES" : @"NO");
    }];
    
    [section addItem:_isInitWithFetchRSS];
    
    return section;
}

-(RETableViewSection *)addBackgroundImageSection{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"背景"];
    [self.manager addSection:section];
    _isUserYourOwnBackgroundImage = [REBoolItem itemWithTitle:@"是否启用自己的背景" value:NO switchValueChangeHandler:^(REBoolItem *item){
        //
    }];
    
    
    _backgroundImageSelect = [RETableViewItem itemWithTitle:@"选择一张自己的背景" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        //选择相册一张背景
    }];
    _backgroundImageSelect.image = [UIImage imageNamed:@"bg3"];
    
    [section addItem:_isUserYourOwnBackgroundImage];
    [section addItem:_backgroundImageSelect];
    
    return section;
}

-(void)valuesButtonPressed:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}



@end
