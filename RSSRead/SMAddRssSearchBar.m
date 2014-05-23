//
//  FXSearchBar.m
//
//  Created by ftxbird on 14-5-7.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import "SMAddRssSearchBar.h"

@interface SMAddRssSearchBar ()
@end

@implementation SMAddRssSearchBar

+ (instancetype)searchBar
{
    return [[self alloc]init];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 背景
        
        UIImage *image =[UIImage imageNamed:@"searchbar_textfield_background"];
     self.background = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        // 左边的放大镜图标
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
        iconView.contentMode = UIViewContentModeCenter;
        self.leftView = iconView;
        
        self.leftViewMode = UITextFieldViewModeAlways;
        self.font = [UIFont systemFontOfSize:18];
        self.textColor = [UIColor colorWithRed:0.119 green:0.730 blue:0.598 alpha:1.000];
        self.clearButtonMode = UITextFieldViewModeAlways;
        
        // 设置提醒文字
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSForegroundColorAttributeName] = [UIColor grayColor];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索/输入源URL" attributes:attrs];
        
        // 设置键盘右下角按钮的样式
        self.returnKeyType = UIReturnKeySearch;
        self.enablesReturnKeyAutomatically = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 设置左边图标的frame
    self.leftView.frame = CGRectMake(0, 0, 30, self.frame.size.height);
}

@end
