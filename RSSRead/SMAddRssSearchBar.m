//
//  FXSearchBar.m
//
//  Created by ftxbird on 14-5-7.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import "SMAddRssSearchBar.h"
#import "UIColor+TBExt.h"
#import <QuartzCore/QuartzCore.h>

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
        
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        // 左边的放大镜图标
        UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchbar_textfield_search_icon"]];
        iconView.contentMode = UIViewContentModeCenter;
        self.leftView = iconView;
        
        self.leftViewMode = UITextFieldViewModeAlways;
        self.font = [UIFont systemFontOfSize:12];
        self.textColor = [UIColor colorFromRGB:0x2e2e2e];
        self.clearButtonMode = UITextFieldViewModeAlways;
        
        // 设置提醒文字
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        attrs[NSForegroundColorAttributeName] = [UIColor colorFromRGB:0xb3b3b3];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"搜索/输入源URL" attributes:attrs];
        
        // 设置键盘右下角按钮的样式
        self.returnKeyType = UIReturnKeySearch;
        self.enablesReturnKeyAutomatically = YES;
        
        [self setBackgroundColor:[UIColor colorFromRGB:0xe6e6e6]];
        self.layer.cornerRadius = 3.0f;

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
