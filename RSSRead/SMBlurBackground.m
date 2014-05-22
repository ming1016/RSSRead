//
//  SMBlurBackground.m
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMBlurBackground.h"

@implementation SMBlurBackground
/**
 *  使用QBlur模糊效果，按周，每天换图片。需要找些合适的图片
 *
 *  @return UIImageView
 */
+(UIImageView *)QBluerView
{
    UIImage * backgroundImage = [self QBNoneBluerImage];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:backgroundImage];
    QBlurView *QB = [[QBlurView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    //QB.synchronized = YES;
    [backgroundImageView addSubview:QB];
    return backgroundImageView;
}
/**
 *  仅返回尺寸为屏幕大小的image,不带模糊效果
 *  @return UIImage
 */
+ (UIImage *)QBNoneBluerImage;
{
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    return [UIImage imageNamed:[NSString stringWithFormat:@"bg%ld",(long)week]];

}
@end
