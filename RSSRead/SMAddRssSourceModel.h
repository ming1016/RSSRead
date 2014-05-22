//
//  SMAddRssSourceModel.h
//  RSSRead
//
//  Created by ftxbird on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  根据搜索得到的RSS源信息模型
 */
@interface SMAddRssSourceModel : NSObject
/**
 *  源简介
 */
@property (nonatomic ,copy) NSString *contentSnippet;
/**
 *  网站链接
 */
@property (nonatomic ,copy) NSString *link;
/**
 *  标题
 */
@property (nonatomic ,copy) NSString *title;
/**
 *  RSS地址
 */
@property (nonatomic ,copy) NSString *url;

+ (instancetype)rssWithDict:(NSDictionary *)dict;

- (instancetype)initWithDict:(NSDictionary *)dict;
@end
