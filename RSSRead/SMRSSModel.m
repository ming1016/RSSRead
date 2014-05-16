//
//  SMRSSModel.m
//  RSSRead
//
//  Created by ming on 14-3-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMRSSModel.h"
#import "Subscribes.h"
#import "SMAppDelegate.h"

@implementation SMRSSModel {
    SMAppDelegate *_appDelegate;
    NSManagedObjectContext *_managedObjectContext;
    SMGetFetchedRecordsModel *_getModel;
    NSArray *_fetchedRecorders;
//    RSS *_rss;
    
}

-(id)init {
    if (self = [super init]) {
        _appDelegate = [UIApplication sharedApplication].delegate;
        _managedObjectContext = _appDelegate.managedObjectContext;
        _getModel = [[SMGetFetchedRecordsModel alloc]init];
        _fetchedRecorders = [NSArray array];
    }
    return self;
}

-(void)unFavRSS:(RSS *)rss {
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"identifier=%@",rss.identifier];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (RSS *aRSS in _fetchedRecorders) {
            aRSS.isFav = @0;
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
}

-(void)favRSS:(RSS *)rss {
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"identifier=%@",rss.identifier];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (RSS *aRSS in _fetchedRecorders) {
            aRSS.isFav = @1;
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
}

-(void)markAsRead:(RSS *)rss {
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"identifier=%@",rss.identifier];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (RSS *aRSS in _fetchedRecorders) {
            aRSS.isRead = @1;
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
    [self recountSubscribeUnRead:rss.subscribeUrl];
}

-(void)markAllAsRead:(NSString *)url {
    _getModel.entityName = @"RSS";
    _getModel.sortName = @"createDate";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@",url];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        int countNum = 0;
        BOOL isOver = NO;
        if (_fetchedRecorders.count > 100) {
            isOver = YES;
        }
        for (RSS *aRSS in _fetchedRecorders) {
            aRSS.isRead = @1;
            if (isOver) {
                if (countNum > 100 && [aRSS.isFav isEqual:@0]) {
                    [_managedObjectContext deleteObject:aRSS];
                }
            }
            countNum += 1;
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
    
    //重新统计订阅未读数
    [self recountSubscribeUnRead:url];
}

-(void)deleteSubscrib:(NSString *)url {
    _getModel.entityName = @"Subscribes";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"url=%@",url];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (NSManagedObject *obj in _fetchedRecorders) {
            [_managedObjectContext deleteObject:obj];
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@",url];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (NSManagedObject *obj in _fetchedRecorders) {
            [_managedObjectContext deleteObject:obj];
        }
    }
    [_managedObjectContext save:&error];
    
    [self recountSubscribeUnRead:url];
}

-(void)deleteAllRSS:(NSString *)url {
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@ AND isFav=0 AND isRead=1",url];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (NSManagedObject *obj in _fetchedRecorders) {
            [_managedObjectContext deleteObject:obj];
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
    
    //重新统计订阅未读数
    [self recountSubscribeUnRead:url];
}

-(void)deleteReadRSS:(NSString *)url {
    _getModel.entityName = @"RSS";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"isRead=%@ AND isFav=0",@1];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    if (_fetchedRecorders && [_fetchedRecorders count]) {
        for (NSManagedObject *obj in _fetchedRecorders) {
            [_managedObjectContext deleteObject:obj];
        }
    }
    NSError *error;
    [_managedObjectContext save:&error];
    
    //重新统计订阅未读数
    [self recountSubscribeUnRead:url];
}

-(void)insertRSSFeedItems:(NSArray *)items ofFeedUrlStr:(NSString *)feedUrlStr
{
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self insertRSSFeedItem:obj withFeedUrlStr:feedUrlStr];
    }];
}


-(void)insertRSSFeedItem:(MWFeedItem *)item withFeedUrlStr:(NSString *)feedUrlStr{
    _getModel.entityName = @"RSS";
    NSError *error;
//    for (MWFeedItem *item in items) {
        _getModel.predicate = [NSPredicate predicateWithFormat:@"identifier=%@",item.identifier];
        _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
        if (_fetchedRecorders.count == 0) {
            RSS *rss = [NSEntityDescription insertNewObjectForEntityForName:@"RSS" inManagedObjectContext:_managedObjectContext];
            rss.author = item.author ? item.author : @"未知作者";
            rss.content = item.content ? item.content : @"无内容";
            rss.createDate = [NSDate date];
            rss.date = item.date;
            rss.identifier = item.identifier;
            rss.isFav = @0;
            rss.isRead = @0;
            rss.link = item.link ? item.link : @"无连接";
            rss.subscribeUrl = feedUrlStr;
            rss.summary = item.summary ? item.summary : @"无描述";
            rss.title = item.title ? item.title : @"无标题";
            rss.updated = item.updated;
//            if (rss.title) {
                [_managedObjectContext save:&error];
//            }
        }
//    }
    [self recountSubscribeUnRead:feedUrlStr];
    
    if([(NSObject *)_smRSSModelDelegate respondsToSelector:@selector(rssInserted)]){
        [_smRSSModelDelegate rssInserted];
    }
}

-(void)recountSubscribeUnRead:(NSString *)url {
    NSError *error;
    _getModel.predicate = [NSPredicate predicateWithFormat:@"subscribeUrl=%@ AND isFav=0 AND isRead=0",url];
    _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
    _getModel.entityName = @"Subscribes";
    _getModel.predicate = [NSPredicate predicateWithFormat:@"url=%@",url];
    NSArray *fetchSubscribes = [_appDelegate getFetchedRecords:_getModel];
    for (Subscribes *aSubscribe in fetchSubscribes) {
        aSubscribe.total = [NSNumber numberWithInteger:_fetchedRecorders.count];
    }
    [_managedObjectContext save:&error];
}
@end
