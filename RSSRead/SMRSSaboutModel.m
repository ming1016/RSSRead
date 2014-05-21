//
//  SMRSSaboutModel.m
//  about
//
//  Created by ftxbird on 14-5-21.
//  Copyright (c) 2014年 ftxbird. All rights reserved.
//

#import "SMRSSaboutModel.h"

@implementation SMRSSaboutModel
+ (instancetype)aboutWithDict:(NSDictionary *)dict
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
