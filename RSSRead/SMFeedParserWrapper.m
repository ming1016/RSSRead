//
//  SMFeedParserWrapper.m
//  RSSRead
//
//  Created by John Zhang on 5/15/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import "SMFeedParserWrapper.h"

@interface SMFeedParserWrapper()

@property (copy, nonatomic) void (^completionHandler)(NSArray *);

@property (strong, nonatomic) NSMutableArray *feedItemArr;

@property (strong, nonatomic) dispatch_source_t timer;
@property (strong, nonatomic) dispatch_queue_t timerQueue;

@property (assign, nonatomic) BOOL isTimeout;

@end

@implementation SMFeedParserWrapper

- (instancetype)init{
    if(self = [super init]){
        _feedItemArr = [NSMutableArray new];
        _timeoutInterval = .0;
        _isTimeout = NO;
    }
    return self;
}

//- (void)dealloc
//{
//    self.timer = nil;
//    self.timerQueue = nil;
//}

- (void)parseUrl:(NSURL *)url completion:(void (^)(NSArray *items))completionHandler
{
    self.completionHandler = completionHandler;
    
    if(_timeoutInterval>.0){
        _timerQueue = dispatch_queue_create("parser_timer_queue", NULL);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
        dispatch_time_t time = dispatch_time(
                                      DISPATCH_TIME_NOW,
                                      _timeoutInterval * NSEC_PER_SEC);
        dispatch_source_set_timer(_timer, time, _timeoutInterval * NSEC_PER_SEC, 30 * NSEC_PER_SEC);
        __strong SMFeedParserWrapper *strongSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            [strongSelf parserTimeout:url];
        });
        dispatch_resume(_timer);
    }
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MWFeedParser *feedParser = [[MWFeedParser alloc]initWithFeedURL:url];
        feedParser.delegate = self;
        feedParser.feedParseType = ParseTypeFull;
        feedParser.connectionType = ConnectionTypeSynchronously;//采用同步方式发送请求
        [feedParser parse];
//    });
}

#pragma mark - MWFeedParser Delegate
//-(void)feedParserDidStart:(MWFeedParser *)parser {
//
//}

//-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//    self.feedInfo = info;
//}

- (void)parserTimeout:(NSURL *)url{
    dispatch_suspend(_timer);
    _isTimeout = YES;
    self.completionHandler(self.feedItemArr);
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    [self.feedItemArr addObject:item];
}

-(void)feedParserDidFinish:(MWFeedParser *)parser {
    if(!_isTimeout){
        dispatch_async(dispatch_get_main_queue(), ^{
            self.completionHandler(self.feedItemArr);
        });
        if(_timer){
        dispatch_suspend(_timer);
        }
    }
}
@end
