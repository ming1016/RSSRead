//
//  SMAddRssSoucesCell.m
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAddRssSoucesCell.h"
#import "SMAddRssSourceModel.h"
@implementation SMAddRssSoucesCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addBtn];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)addBtn
{
    #warning 待美化图片.
    UIButton *btn = [[UIButton alloc] init];
    CGFloat btnX = self.contentView.frame.size.width - 60;
    CGFloat btnY =  5;
    CGFloat btnW =  45;
    CGFloat btnH =  28;
    btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    btn.backgroundColor = [UIColor colorWithRed:0.153 green:0.956 blue:0.585 alpha:1.000];
    [btn setTitle:@"添加" forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    btn.layer.cornerRadius = 10;
    btn.layer.masksToBounds = YES;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];
    self.btn = btn;
    
}

- (void)btnClick:(UIButton *)btn
{
    [self.delegate btnClickAddRssUsingTag:btn];
}


- (void)setSearchRss:(SMAddRssSourceModel *)searchRss
{
    //对标题做特殊处理 删除<b></b>
    NSString * str = searchRss.title;
    str =[str stringByReplacingOccurrencesOfString:@"<b>" withString:@" "];
    str =[str stringByReplacingOccurrencesOfString:@"</b>" withString:@" "];
   // searchRss.title
    searchRss.title = str;
    self.textLabel.text = searchRss.title;
    [self.textLabel setFont:[UIFont systemFontOfSize:12]];
    self.detailTextLabel.text = searchRss.url;
}

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"search";
    SMAddRssSoucesCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[SMAddRssSoucesCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return cell;
}

@end
