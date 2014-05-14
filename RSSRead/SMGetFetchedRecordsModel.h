//
//  SMGetFetchedRecordsModel.h
//  RSSRead
//
//  Created by ming on 14-3-20.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMGetFetchedRecordsModel : NSObject

@property(nonatomic,strong)NSString *entityName;
@property(nonatomic,strong)NSString *sortName;

@property(nonatomic)NSUInteger limit;
@property(nonatomic)NSUInteger offset;

@property(nonatomic,strong)NSPredicate *predicate;

@end
