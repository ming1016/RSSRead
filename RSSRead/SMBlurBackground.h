//
//  SMBlurBackground.h
//  RSSRead
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QBlurView.h"
@interface SMBlurBackground : NSObject

/**
 *  仅在初始化作一次调用,将背景图片做模糊处理,快照该处理后的图片,写入沙盒.
 */
+ (void)SMRSSbackgroundImage: (UIImage*)image;

/**
 *  读取沙盒图片,返回UIImageView
 */
+ (UIImageView *)SMbackgroundView;
@end
