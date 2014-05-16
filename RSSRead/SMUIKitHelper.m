//
//  SMUIKitHelper.m
//  QM
//
//  Created by cyol 005 on 13-4-9.
//  Copyright (c) 2013年 mars.tsang. All rights reserved.
//

#import "SMUIKitHelper.h"

@implementation SMUIKitHelper

/*--------简化控件------*/
+(UILabel *)labelShadowWithRect:(CGRect)rect text:(NSString *)text textColor:(NSString *)color fontSize:(CGFloat)size {
    UILabel *label = [SMUIKitHelper labelWithRect:rect text:text textColor:color fontSize:size];
    label.shadowColor = [UIColor whiteColor];
    label.shadowOffset = CGSizeMake(0, 1);
    return label;
}

+(UILabel *)labelWithRect:(CGRect)rect text:(NSString *)text textColor:(NSString *)color fontSize:(CGFloat)size {
    UILabel *label = [[UILabel alloc]initWithFrame:rect];
    label.text = text;
    label.textColor = [SMUIKitHelper colorWithHexString:color];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:size];
    return label;
}

+(UIImageView *)imageViewWithRect:(CGRect)rect imageName:(NSString *)name {
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:name]];
    imageView.frame = rect;
    return imageView;
}

+(UITableView *)tableViewWithRect:(CGRect)rect delegateAndDataSource:(id)sender{
    return [SMUIKitHelper tableViewWithRect:rect separatorColor:QM_TABLEVIEW_SEPARATOR_COLOR backgroundColor:QM_TABLEVIEW_BACKGROUND_COLOR showsVerticalScrollIndicator:QM_TABLEVIEW_SHOWS_VERTICAL_SCROLL_INDICATOR rowHeight:QM_TABLEVIEW_ROWHEIGHT delegateAndDataSource:sender];
}

+(UITableView *)tableViewWithRect:(CGRect)rect separatorColor:(UIColor *)spColor backgroundColor:(UIColor *)bgColor showsVerticalScrollIndicator:(BOOL)isShowScroll rowHeight:(CGFloat)rowHeight delegateAndDataSource:(id)sender{
    UITableView *tableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    tableView.backgroundColor = bgColor;
    tableView.separatorColor = spColor;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.showsVerticalScrollIndicator = isShowScroll;
    tableView.rowHeight = rowHeight;
    tableView.dataSource = sender;
    tableView.delegate = sender;
    return tableView;
    
}

/*---------简化页面生成----------*/


/*---------小功能--------*/

+(UIColor *)colorWithHexString:(NSString *)stringToConvert{
    return [SMUIKitHelper colorWithHexString:stringToConvert withAlpha:1.0f];
}

+(UIColor *)colorWithHexString:(NSString *)stringToConvert withAlpha:(CGFloat)alpha{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6)
        return [UIColor whiteColor];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor whiteColor];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:alpha];
}

+ (dispatch_queue_t)getGlobalDispatchQueue{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

+ (dispatch_queue_t)getMainQueue{
    return dispatch_get_main_queue();
}
@end
