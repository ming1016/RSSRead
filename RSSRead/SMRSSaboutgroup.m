//
//  SMRSSgroup.m
//  about
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import "SMRSSaboutgroup.h"
#import "SMRSSaboutModel.h"
@implementation SMRSSaboutgroup

+ (instancetype)groupWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        // 赋值标题
        self.title = dict[@"title"];
        
        // 取出原来的字典数组
        NSArray *dictArray = dict[@"abouts"];
        NSMutableArray *aboutArray = [NSMutableArray array];
        for (NSDictionary *dict in dictArray) {
            SMRSSaboutModel *about = [SMRSSaboutModel aboutWithDict:dict];
            [aboutArray addObject:about];
        }
        self.abouts = aboutArray;
    }
    return self;
}

@end
