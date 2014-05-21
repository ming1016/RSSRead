//
//  SMAddRSSToolbar.h
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//
/**
 *  添加源页面toolbar,辅助用户快捷输入
 */

#import <UIKit/UIKit.h>
@class SMAddRSSToolbar;

@protocol SMAddRSSToolbarDelegate <NSObject>

- (void)Toolbar:(SMAddRSSToolbar *)toolbar didClickedButtonWithString:(NSString *)str;

@end


@interface SMAddRSSToolbar : UIView

@property (nonatomic, weak) id <SMAddRSSToolbarDelegate> delegate;
        
@end
