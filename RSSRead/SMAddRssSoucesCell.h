//
//  SMAddRssSoucesCell.h
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMAddRssSourceModel;

@protocol SMAddRssSoucesCellDelegate <NSObject>

- (void)btnClickAddRssUsingTag:(UIButton *) btn;

@end


@interface SMAddRssSoucesCell : UITableViewCell

@property (nonatomic,strong) SMAddRssSourceModel* searchRss;
@property (nonatomic,weak) id<SMAddRssSoucesCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
