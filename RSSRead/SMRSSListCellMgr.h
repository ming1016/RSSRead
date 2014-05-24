//
//  SMRSSListCellMgr.h
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSS;

extern const NSInteger kRSSListCellMarginLeft;
extern const NSInteger kRSSListCellPaddingTop;
extern const NSInteger kRSSListCellDateMarginTop;

@interface SMRSSListCellMgr : NSObject
+(float)heightForRSSList:(RSS *)rss;

@property (assign, nonatomic) CGSize       titleLabelSize;
@property (assign, nonatomic) CGFloat       cellHeight;
@property (strong, nonatomic) RSS       *rss;

@end
