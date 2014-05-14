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
    RSS *_rss;
    
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



-(void)insertRSS:(NSArray *)items withFeedInfo:(MWFeedInfo *)feedInfo{
    _getModel.entityName = @"RSS";
    NSError *error;
    for (MWFeedItem *item in items) {
        _getModel.predicate = [NSPredicate predicateWithFormat:@"identifier=%@",item.identifier];
        _fetchedRecorders = [_appDelegate getFetchedRecords:_getModel];
        if (_fetchedRecorders.count == 0) {
            _rss = [NSEntityDescription insertNewObjectForEntityForName:@"RSS" inManagedObjectContext:_managedObjectContext];
            _rss.author = item.author ? item.author : @"未知作者";
            _rss.content = item.content ? item.content : @"无内容";
            _rss.createDate = [NSDate date];
            _rss.date = item.date;
            _rss.identifier = item.identifier;
            _rss.isFav = @0;
            _rss.isRead = @0;
            _rss.link = item.link ? item.link : @"无连接";
            _rss.subscribeUrl = [feedInfo.url absoluteString];
            _rss.summary = item.summary ? item.summary : @"无描述";
            _rss.title = item.title ? item.title : @"无标题";
            _rss.updated = item.updated;
            if (_rss.title) {
                [_managedObjectContext save:&error];
            }
        }
    }
    [self recountSubscribeUnRead:[feedInfo.url absoluteString]];
    
    [_smRSSModelDelegate rssInserted];
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
