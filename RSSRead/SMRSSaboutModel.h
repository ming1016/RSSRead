//
//  SMRSSaboutModel.h
//  about
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMRSSaboutModel : NSObject
/**
 *  图片
 */
@property (nonatomic, copy) NSString *icon;
/**
 *  标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  链接
 */
@property (nonatomic, copy) NSString *link;


+ (instancetype)aboutWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
