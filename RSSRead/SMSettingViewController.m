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
    
    //未完成
}

-(RETableViewSection *)addGeneralSection{
    __typeof (&*self) __weak weakSelf = self;
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"通用"];
    [self.manager addSection:section];
    
    
    return section;
}

-(void)valuesButtonPressed:(id)sender {
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}



@end
