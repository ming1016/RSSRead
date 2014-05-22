//
//  SMAddRSSToolbar.m
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAddRSSToolbar.h"
#import "SMUIKitHelper.h"

@implementation SMAddRSSToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat toolbarX = 0;
        CGFloat toolbarH = 44;
        CGFloat toolbarY = [UIScreen mainScreen].bounds.size.height;
        CGFloat toolbarW = [UIScreen mainScreen].bounds.size.width;
        self.frame = CGRectMake(toolbarX, toolbarY, toolbarW, toolbarH);
        // 1.设置toobar背景
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"addRSS_toolbar_background"]];
        
        // 2.添加按钮
        [self addButtonWithIcon:@"addRSS_toolbar_background"
                       highIcon:@"addRSS_toolbar_background"
                           text:@"http://"];
        
        [self addButtonWithIcon:@"addRSS_toolbar_background"
                       highIcon:@"addRSS_toolbar_background"
                           text:@"www."];
        
        [self addButtonWithIcon:@"addRSS_toolbar_background"
                       highIcon:@"addRSS_toolbar_background"
                           text:@".xml"];
        
        [self addButtonWithIcon:@"addRSS_toolbar_background"
                       highIcon:@"addRSS_toolbar_background"
                           text:@".feed"];
        
        [self addButtonWithIcon:@"addRSS_toolbar_background"
                       highIcon:@"addRSS_toolbar_background"
                           text:@"clear"];
    }
    return self;
}


- (void)addButtonWithIcon:(NSString *)icon highIcon:(NSString *)highIcon text:(NSString *)text
{
    UIButton *button = [[UIButton alloc] init];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:LINK_COLOR forState:UIControlStateNormal];
    [self addSubview:button];
}

/**
 *  监听按钮点击
 */
- (void)buttonClick:(UIButton *)button
{
    if ([self.delegate respondsToSelector:@selector(Toolbar:didClickedButtonWithString:)])
    {
        [self.delegate Toolbar:self didClickedButtonWithString:button.titleLabel.text];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat buttonW = self.frame.size.width / self.subviews.count;
    CGFloat buttonH = self.frame.size.height;
    for (int i = 0; i<self.subviews.count; i++) {
        UIButton *button = self.subviews[i];
        CGFloat buttonX = buttonW * i;
        button.frame = CGRectMake(buttonX, 0, buttonW, buttonH);
    }
}



@end
