//
//  SMAddRssSourceModel.m
//  RSSRead
//
//  Created by ftxbird on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAddRssSourceModel.h"

@implementation SMAddRssSourceModel
+ (instancetype)rssWithDict:(NSDictionary *)dict
{
    return [[self alloc] initWithDict:dict];
}

- (instancetype)initWithDict:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
