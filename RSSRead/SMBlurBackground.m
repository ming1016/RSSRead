//
//  SMBlurBackground.m
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMBlurBackground.h"

@implementation SMBlurBackground

+(void)SMBluerViewWithImage:(UIImage *)image
{
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:image];
    QBlurView *QB = [[QBlurView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    QB.synchronized = YES;
    [backgroundImageView addSubview:QB];
    UIGraphicsBeginImageContextWithOptions(backgroundImageView.bounds.size, YES, 0);
    [backgroundImageView drawViewHierarchyInRect:backgroundImageView.bounds afterScreenUpdates:YES];
    UIImage *endImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
   
    //将endImage写入沙盒
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).lastObject;
    NSString *filePath = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"SMRSSBackground.png"]];   // 保存文件的名称
    BOOL result = [UIImagePNGRepresentation(endImage) writeToFile: filePath atomically:YES]; // 保存成功会返回YES
    NSLog(@"%d",result);
}


+ (void)SMRSSbackgroundImage: (UIImage*)image
{
    UIImage *backimage = nil;
    
    if (image) {
        
        backimage = image;
        
    }
    else{
        NSDate *date = [NSDate date];
        NSDateComponents *comps = [[NSDateComponents alloc]init];
        NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        comps = [calendar components:unitFlags fromDate:date];
        NSInteger week = [comps weekday];
        backimage = [UIImage imageNamed:[NSString stringWithFormat:@"bg%ld",(long)week]];
    }
    
    [self SMBluerViewWithImage:backimage];;
    
}

// 读取沙盒图片
+ (UIImageView *)SMbackgroundView
{
    UIImage *image = nil;
    NSString *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES).lastObject;
    NSString *filePath = [document stringByAppendingPathComponent:[NSString stringWithFormat:@"SMRSSBackground.png"]];
    image = [[UIImage alloc]initWithContentsOfFile:filePath];
    if (image==nil) {
        [self SMRSSbackgroundImage: nil];
        image =[[UIImage alloc]initWithContentsOfFile:filePath];
    }
    return [[UIImageView alloc]initWithImage:image];
}
@end
