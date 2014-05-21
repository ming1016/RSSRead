//
//  SMRSSgroup.h
//  about
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMRSSaboutgroup : NSObject
/**
 *  组标题
 */
@property (nonatomic, copy) NSString *title;
/**
 *  存放所有模型
 */
@property (nonatomic, strong) NSArray *abouts;

+ (instancetype)groupWithDict:(NSDictionary *)dict;
- (instancetype)initWithDict:(NSDictionary *)dict;
@end
