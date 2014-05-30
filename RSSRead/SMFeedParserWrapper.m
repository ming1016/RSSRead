//
//  SMFeedParserWrapper.m
//  RSSRead
//
//  Created by John Zhang on 5/15/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import "SMFeedParserWrapper.h"
#import "SMRSSFetchOperation.h"

#define MAX_NUM_OF_QUEUES 5

@interface SMFeedParserWrapper()

@property (copy, nonatomic) void (^completionHandler)(NSArray *);

@property (strong, nonatomic) NSMutableArray *feedItemArr;

@property (strong, nonatomic) dispatch_source_t timer;
@property (strong, nonatomic) dispatch_queue_t timerQueue;

@property (assign, nonatomic) BOOL isTimeout;

@property (strong, nonatomic) NSMutableArray *queueArr;//队列池

@end

static SMFeedParserWrapper *sharedInstance;

@implementation SMFeedParserWrapper

- (instancetype)init{
    if(self = [super init]){
        _feedItemArr = [NSMutableArray new];
        _timeoutInterval = 10.0;//默认超时时间10秒
        _isTimeout = NO;
        
        _queueArr = [[NSMutableArray alloc] initWithCapacity:MAX_NUM_OF_QUEUES];
        for(int i=0;i<MAX_NUM_OF_QUEUES;++i){
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [_queueArr addObject:queue];
        }
    }
    return self;
}

//- (void)dealloc
//{
//    self.timer = nil;
//    self.timerQueue = nil;
//}

//- (void)parseUrl:(NSURL *)url completion:(void (^)(NSArray *items))completionHandler
//{
//    self.completionHandler = completionHandler;
//    
//    _timerQueue = dispatch_queue_create("parser_timer_queue", NULL);
//    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
//    dispatch_time_t time = dispatch_time(
//                                  DISPATCH_TIME_NOW,
//                                  _timeoutInterval * NSEC_PER_SEC);
//    dispatch_source_set_timer(_timer, time, _timeoutInterval * NSEC_PER_SEC, 30 * NSEC_PER_SEC);
//    __strong SMFeedParserWrapper *strongSelf = self;
//    dispatch_source_set_event_handler(_timer, ^{
//        [strongSelf parserTimeout:url];
//    });
//    dispatch_resume(_timer);
//    
//    //TODO：采用线程池或者并行队列
//    dispatch_async(_timerQueue, ^{
//        MWFeedParser *feedParser = [[MWFeedParser alloc]initWithFeedURL:url];
//        feedParser.delegate = self;
//        feedParser.feedParseType = ParseTypeFull;
//        feedParser.connectionType = ConnectionTypeSynchronously;//采用同步方式发送请求
//        [feedParser parse];
//    });
//}

//#pragma mark - MWFeedParser Delegate
//-(void)feedParserDidStart:(MWFeedParser *)parser {
//
//}

//-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//    self.feedInfo = info;
//}

//- (void)parserTimeout:(NSURL *)url{
//    dispatch_suspend(_timer);
//    _isTimeout = YES;
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.completionHandler(self.feedItemArr);
//    });
//}
//
//- (void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
//    [self.feedItemArr addObject:item];
//}
//
//- (void)feedParserDidFinish:(MWFeedParser *)parser {
//    if(!_isTimeout){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.completionHandler(self.feedItemArr);
//        });
//        if(_timer){
//        dispatch_suspend(_timer);
//        }
//    }
//}

+ (void)parseUrl:(NSURL *)url timeout:(NSTimeInterval)timeout completion:(void (^)(NSArray *items))completionHandler
{
    SMRSSFetchOperation *operation = [[SMRSSFetchOperation alloc] initWithURL:url timeout:timeout completionHandler:completionHandler];
    NSOperationQueue *queue = [[[self sharedInstance] queueArr] objectAtIndex:rand()%MAX_NUM_OF_QUEUES];
    [queue addOperation:operation];
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SMFeedParserWrapper alloc] init];
    });
    return sharedInstance;
}
@end
