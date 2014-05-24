//
//  SMSettingViewController.m
//  RSSRead
//
//  Created by ming on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMSettingViewController.h"
#import "SMPreferences.h"

@interface SMSettingViewController ()
@property(nonatomic,strong)RETableViewManager *manager;
@property(nonatomic,strong)RETableViewSection *generalSection;
@property(nonatomic,strong)RETableViewSection *backgroundImageSection;

@property(nonatomic,strong)REBoolItem *isInitWithFetchRSS;
@property(nonatomic,strong)REBoolItem *isUseYourOwnBackgroundImage;
@property(nonatomic,strong)REBoolItem *isUseBlurForYourBackgroundImage;
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
    
    _manager = [[RETableViewManager alloc]initWithTableView:self.tableView delegate:self];
    _generalSection = [self addGeneralSection];
    _backgroundImageSection = [self addBackgroundImageSection];
    
    //TODO:可调节模糊值
}

-(RETableViewSection *)addGeneralSection{
//    __typeof (&*self) __weak weakSelf = self;
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"通用"];
    [self.manager addSection:section];
    _isInitWithFetchRSS = [REBoolItem itemWithTitle:@"启动时是否自动同步" value:[[SMPreferences sharedInstance] isInitWithFetchRSS] switchValueChangeHandler:^(REBoolItem *item){
        [[SMPreferences sharedInstance] setIsInitWithFetchRSS:item.value];
        [[SMPreferences sharedInstance] synchronize];
    }];
    
    [section addItem:_isInitWithFetchRSS];
    
    return section;
}

-(RETableViewSection *)addBackgroundImageSection{
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"背景"];
    [self.manager addSection:section];
    _isUseYourOwnBackgroundImage = [REBoolItem itemWithTitle:@"是否启用自己的背景" value:[[SMPreferences sharedInstance] isUseYourOwnBackgroundImage] switchValueChangeHandler:^(REBoolItem *item){
        [[SMPreferences sharedInstance] setIsUseYourOwnBackgroundImage:item.value];
        [[SMPreferences sharedInstance] synchronize];
    }];
    [section addItem:_isUseYourOwnBackgroundImage];
    
    _isUseBlurForYourBackgroundImage = [REBoolItem itemWithTitle:@"是否启用模糊效果" value:[[SMPreferences sharedInstance] isUseBlurForYourBackgroundImage] switchValueChangeHandler:^(REBoolItem *item){
        [[SMPreferences sharedInstance] setIsUseBlurForYourBackgroundImage:item.value];
        [[SMPreferences sharedInstance] synchronize];
    }];
    [section addItem:_isUseBlurForYourBackgroundImage];
    
    //调节模糊值
    
    _backgroundImageSelect = [RETableViewItem itemWithTitle:@"选择一张自己的背景" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        //TODO:选择相册一张背景
    }];
    _backgroundImageSelect.image = [UIImage imageNamed:@"bg3"];
    
    
    [section addItem:_backgroundImageSelect];
    
    return section;
}

//TODO:外观定制


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
