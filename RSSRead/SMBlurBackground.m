//
//  SMBlurBackground.m
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMBlurBackground.h"

@implementation SMBlurBackground

+(UIImageView *)QBluerView
{
    NSDate *date = [NSDate date];
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    NSInteger unitFlags = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    comps = [calendar components:unitFlags fromDate:date];
    NSInteger week = [comps weekday];
    UIImageView *backgroundImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"bg%ld",(long)week]]];
    backgroundImage.frame = [UIScreen mainScreen].bounds;
    QBlurView *QB = [[QBlurView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    QB.synchronized = YES;
    [backgroundImage addSubview:QB];
    return backgroundImage;
}
@end
