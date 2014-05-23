//
//  SMUIKitHelper.h
//  QM
//
//  Created by cyol 005 on 13-4-9.
//  Copyright (c) 2013年 mars.tsang. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NAVBARHEIGHT 64

#define SCREEN_BOUNDS [[UIScreen mainScreen] bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define STATUS_BAR_HEIGHT   [[UIApplication sharedApplication] statusBarFrame].size.height

#define QM_TABLEVIEW_BACKGROUND_COLOR [UIColor clearColor]
#define QM_TABLEVIEW_SEPARATOR_COLOR [UIColor clearColor]
#define QM_TABLEVIEW_SHOWS_VERTICAL_SCROLL_INDICATOR YES
#define QM_TABLEVIEW_ROWHEIGHT 56

#define COLOR_BACKGROUND @"#FFFFFF"

#define LIST_BIG_FONT 13
#define LIST_SMALL_FONT 10
#define LIST_DARK_COLOR @"#2e2e2e"
#define LIST_LIGHT_COLOR @"#999999"
#define LIST_YELLOW_COLOR @"#CD8500"

#define LINK_COLOR [UIColor purpleColor]

#define APP_DELEGATE ((SMAppDelegate *)([[UIApplication sharedApplication] delegate]))

#define SERVER_URL @""
#define SERVER_OF_CHECKNETWORKING @"http://www.starming.com/index.php?v=api&m=check"
@interface SMUIKitHelper : NSObject
//label
+(UILabel *)labelWithRect:(CGRect)rect text:(NSString *)text textColor:(NSString *)color fontSize:(CGFloat)size;
+(UILabel *)labelShadowWithRect:(CGRect)rect text:(NSString *)text textColor:(NSString *)color fontSize:(CGFloat)size;

//imageView
+(UIImageView *)imageViewWithRect:(CGRect)rect imageName:(NSString *)name;

//tableView
+(UITableView *)tableViewWithRect:(CGRect)rect delegateAndDataSource:(id)sender;
+(UITableView *)tableViewWithRect:(CGRect)rect separatorColor:(UIColor *)spColor backgroundColor:(UIColor *)bgColor showsVerticalScrollIndicator:(BOOL)isShowScroll rowHeight:(CGFloat)rowHeight delegateAndDataSource:(id)sender;

+(UIColor *)colorWithHexString:(NSString *)stringToConvert;
+(UIColor *)colorWithHexString:(NSString *)stringToConvert withAlpha:(CGFloat)alpha;
+ (dispatch_queue_t)getGlobalDispatchQueue;
+ (dispatch_queue_t)getMainQueue;
@end
