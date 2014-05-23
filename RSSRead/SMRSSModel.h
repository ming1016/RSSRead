//
//  SMRSSModel.h
//  RSSRead
//
//  Created by ming on 14-3-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWFeedParser.h"
#import "RSS.h"

@protocol SMRSSModelDelegate
@optional
-(void)rssInserted;
@end


@interface SMRSSModel : NSObject
-(void)unFavRSS:(RSS *)rss;
-(void)favRSS:(RSS *)rss;
-(void)insertRSSFeedItem:(MWFeedItem *)item withFeedUrlStr:(NSString *)feedUrlStr;
-(RSS *)insertRSSWithFeedItem:(MWFeedItem *)item withFeedUrlStr:(NSString *)feedUrlStr;
//-(void)insertRSSFeedItem:(MWFeedItem *)item withFeedInfo:(MWFeedInfo *)info;
-(void)insertRSSFeedItems:(NSArray *)items ofFeedUrlStr:(NSString *)feedUrlStr;

-(void)markAsRead:(RSS *)rss;
-(void)markAllAsRead:(NSString *)url;

- (void)dislikeRSS:(RSS *)rss;
-(void)deleteSubscrib:(NSString *)url;
-(void)deleteAllRSS:(NSString *)url;
-(void)deleteReadRSS:(NSString *)url;

-(void)recountSubscribeUnRead:(NSString *)url;

@property(nonatomic,assign)id<SMRSSModelDelegate>smRSSModelDelegate;
@end
