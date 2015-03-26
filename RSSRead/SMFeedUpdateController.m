//
//  SMFeedUpdateController.m
//  RSSRead
//
//  Created by John Zhang on 6/1/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import "SMFeedUpdateController.h"

#import "SMFeedParserWrapper.h"

#import "SMGetFetchedRecordsModel.h"

#import "Subscribes.h"

@interface SMFeedUpdateController()<SMRSSModelDelegate>

@property(assign, nonatomic) NSTimeInterval updateCheckTimeInterval;

@property (strong, nonatomic) dispatch_source_t dispatchSource;

@property (strong, nonatomic) dispatch_queue_t dispatchQueue;

//为了不用每次更新都要获取RSS源，我们把所有源先获取后载入进内存，但是这样
//会造成用户新添加源不能获得自动更新，因此在此提供了一个是内存中RSS源实效
//的类方法+(void)invalidateRSSList，用户手动添加RSS源后必须调用该方法
@property (copy, nonatomic) NSArray *sourceList;

@property (assign, nonatomic) BOOL stopped;
@property (assign, nonatomic) BOOL started;

@end

@implementation SMFeedUpdateController
static SMFeedUpdateController *sharedInstance;

- (instancetype)init{
    if(self = [super init]){
        //默认每60秒检查一次更新
        _updateCheckTimeInterval = 60;
        
        _dispatchQueue = dispatch_queue_create("SM parser queue", DISPATCH_QUEUE_SERIAL);
        _dispatchSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _dispatchQueue);
        dispatch_source_set_timer(_dispatchSource, DISPATCH_TIME_NOW, _updateCheckTimeInterval * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_dispatchSource, ^{
            [self doUpdateJob];
        });
        
    }
    return self;
}

- (void)dealloc{
    if(_started && !_stopped){
        dispatch_suspend(_dispatchSource);
    }
    
    self.dispatchSource = nil;
    self.dispatchQueue = nil;
}

- (void)doUpdateJob{
    @synchronized(_sourceList){
    //查看所有的订阅源
    if(!_sourceList){
        _sourceList = nil;
        SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc] init];
        getModel.entityName = @"Subscribes";
        getModel.sortName = @"total";
        _sourceList = [APP_DELEGATE getFetchedRecords:getModel];
    }
    
    if (![_sourceList count]){
        //从plist文件中读取推荐源
        NSMutableArray *allSurscribes = [NSMutableArray array];
        NSString *plistPath = [[NSBundle mainBundle]pathForResource:@"RecommendFeedList" ofType:@"plist"];
        NSArray *recommends = [[NSArray alloc]initWithContentsOfFile:plistPath];
        
        for (NSDictionary *aDict in recommends) {
            NSError *error;
            Subscribes *subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:APP_DELEGATE.managedObjectContext];
            subscribe.title = aDict[@"title"];
            subscribe.summary = aDict[@"summary"];
            subscribe.link = aDict[@"link"];
            subscribe.url = aDict[@"url"];
            subscribe.createDate = [NSDate date];
            subscribe.total = @0;
            subscribe.lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
            subscribe.updateTimeInterval = @60;//默认1分钟更新一次
            [APP_DELEGATE.managedObjectContext save:&error];
            if(!error){
                [allSurscribes addObject:subscribe];
            }else{
                NSLog(@"save subscribe data error");
            }
        }
        _sourceList = allSurscribes;
    }
        
    [_sourceList enumerateObjectsUsingBlock:^(Subscribes *subscribe, NSUInteger idx, BOOL *stop) {

        //检查上次更新间隔
        
        //注意：虽然我们已经指定一个全局的更新检查时间间隔（通常较短），但是对每个单独的RSS源，
        //我们需要读取其自身的更新间隔设置（通常较长），这也意味着，当全局更新检查时间比独立RSS
        //源更新间隔更长时，后者将会失去意义。
        NSDate *lastUpdateDate = subscribe.lastUpdateTime;
        NSNumber *sourceUpdatInterval = subscribe.updateTimeInterval;
        NSTimeInterval intUpdate = [sourceUpdatInterval doubleValue];
        
        if(-[lastUpdateDate timeIntervalSinceNow]>intUpdate){
            [SMFeedParserWrapper parseUrl:[NSURL URLWithString:subscribe.url] timeout:10 completion:^(NSArray *items) {
                if(items && items.count){
                    SMRSSModel *rssModel = [[SMRSSModel alloc]init];
                    rssModel.smRSSModelDelegate = self;
                    [rssModel insertRSSFeedItems:items ofFeedUrlStr:subscribe.url];
                }
            }];
            
            SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc] init];
            getModel.entityName = @"Subscribes";
            getModel.predicate = [NSPredicate predicateWithFormat:@"url=%@",subscribe.url];
            
            NSArray *fetchedResults = [APP_DELEGATE getFetchedRecords:getModel];
            if(fetchedResults.count>0){
                Subscribes *aSubscribe = fetchedResults[0];
                aSubscribe.lastUpdateTime = [NSDate date];
            }
            NSError *error;
            [APP_DELEGATE.managedObjectContext save:&error];
        }

    }];
    }
}

- (void)setUpdateCheckTimeInterval:(NSTimeInterval)updateCheckTimeInterval{
    if(_updateCheckTimeInterval != updateCheckTimeInterval){
        _updateCheckTimeInterval = updateCheckTimeInterval;
        dispatch_source_set_timer(_dispatchSource, DISPATCH_TIME_NOW, _updateCheckTimeInterval * NSEC_PER_SEC, 0);
    }
}
- (void)invalidateSourceList{
    @synchronized(_sourceList){
    _sourceList = nil;
    }
}

- (void)startUpdate{
    dispatch_resume(_dispatchSource);
    _started = YES;
}

- (void)stopUpdate{
    dispatch_suspend(_dispatchSource);
    _stopped = YES;
}
#pragma mark - class methods
+ (instancetype)sharedInstance{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

+ (void)start{
    [[[self class] sharedInstance] startUpdate];
}

+ (void)stop{
    [[[self class] sharedInstance] stopUpdate];
}

+ (void)setUpdateCheckTimeInterval:(NSTimeInterval)timeInterval{
    [[self sharedInstance] setUpdateCheckTimeInterval:timeInterval];
}

+ (void)invalidateRSSList{
    [[self sharedInstance] invalidateRSSList];
}
@end
