//
//  QBlurView.h
//  QBlurView
//
//  Created by brightshen on 13-11-5.
//  Copyright (c) 2013年 brightshen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QBlurView : UIView

/**
 *  高斯模糊半径，默认10px。
 */
@property(nonatomic) CGFloat blurRadius;

/**
 *  饱和度调节，默认1.0为饱和度不变。小于1.0色彩更加灰暗，大于1.0色彩更加艳丽。
 */
@property(nonatomic) CGFloat saturationDeltaFactor;

/**
 *  模糊处理是否是同步的。默认为NO，UI会更加顺畅。设置为YES的话模糊将更加实时。
 */
@property(nonatomic,getter = isSynchronized) BOOL synchronized;


/**
 *  刷新模糊视图。如果QBlurView的内存没有自动更新，请手动调用。
 */
- (void)setNeedsRefresh;

@end
