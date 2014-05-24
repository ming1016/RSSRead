//
//  SMRSSListCellMgr.m
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMRSSListCellMgr.h"
#import "RSS.h"
#import "SMUIKitHelper.h"

const NSInteger kRSSListCellMarginLeft = 21;
const NSInteger kRSSListCellPaddingTop = 18;
const NSInteger kRSSListCellDateMarginTop = 6;

@implementation SMRSSListCellMgr{
}

//- (void)setRss:(RSS *)rss
//{
//    _rss = rss;
//}

+(float)heightForRSSList:(RSS *)rss {
    float countHeight = kRSSListCellPaddingTop;
    
    CGSize fitSize = [rss.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - kRSSListCellMarginLeft*2, 999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_BIG_FONT]} context:nil].size;
    countHeight += fitSize.height + kRSSListCellDateMarginTop;
    
    fitSize = [rss.summary sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_SMALL_FONT]}];
    countHeight += fitSize.height;
    
    countHeight += kRSSListCellPaddingTop;
    return countHeight;
}

- (CGFloat)cellHeight
{
    if(_cellHeight > 0) return _cellHeight;
    _cellHeight =
    [[self class] heightForRSSList:_rss];
    return _cellHeight;
}

- (CGSize)titleLabelSize;
{
    if(_titleLabelSize.width > 0 || _titleLabelSize.height > 0) {
        return _titleLabelSize;
    }
    //标题
    CGSize fitSize = [_rss.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - kRSSListCellMarginLeft * 2, 99) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_BIG_FONT]} context:nil].size;
    _titleLabelSize = fitSize;
    return _titleLabelSize;
}


@end
