//
//  Subscribes.h
//  RSSRead
//
//  Created by ming on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Subscribes : NSManagedObject

@property (nonatomic, copy) NSDate * createDate;
@property (nonatomic, copy) NSData * favicon;
@property (nonatomic, copy) NSString * link;
@property (nonatomic, copy) NSString * summary;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) NSNumber * total;
@property (nonatomic, copy) NSString * url;

//上一次更新发生的时间
@property (nonatomic, copy) NSDate *lastUpdateTime;

//该RSS源的更新间隔，对于那些更新比较频繁的RSS，可以设定一个较小的值
@property (nonatomic, assign) NSTimeInterval updateTimeInterval;
@end
