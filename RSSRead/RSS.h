//
//  RSS.h
//  RSSRead
//
//  Created by ming on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RSS : NSManagedObject

@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createDate;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSNumber * isFav;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * subscribeUrl;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSNumber * isDislike;

@end
