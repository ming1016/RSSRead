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

@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSData * favicon;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total;
@property (nonatomic, retain) NSString * url;

@end
