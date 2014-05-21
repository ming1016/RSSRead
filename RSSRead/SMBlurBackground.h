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
 *  使用QBlur模糊效果，按周，每天换图片。需要找些合适的图片
 *
 *  @return UIImageView
 */
+ (UIImageView *)QBluerView;
@end
