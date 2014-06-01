//
//  SMRSSFetchOperation.m
//  RSSRead
//
//  Created by John Zhang on 5/30/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import "SMRSSFetchOperation.h"
#import <MWFeedParser/MWFeedParser.h>
#import "SMRSSModel.h"

//#ifndef PARSER_LOG
//#define PARSER_LOG 0
//#endif

#ifndef DEBUG
#undef PARSER_LOG
#endif

@interface SMRSSFetchOperation()<MWFeedParserDelegate>

@property (assign, nonatomic) NSTimeInterval timeout;

@property (copy, nonatomic) NSURL *url;

@property (copy, nonatomic) void (^completionHandler)(NSArray *items);

@property (assign) BOOL isTimeout;

@property (assign) BOOL fetchFinished;

@property (nonatomic, retain)MWFeedParser *feedParser;

@property (nonatomic, retain) NSMutableArray *fetchedFeeds;

@property (nonatomic, retain) NSTimer *timer;

@property (copy, nonatomic) void (^tryCompletionHandler)(MWFeedInfo *feedInfo);

@end

@implementation SMRSSFetchOperation
- (id) initWithURL:(NSURL *)url timeout:(NSTimeInterval)timeout completionHandler:(void (^)(NSArray *items))completionHandler
{
    if(self = [super init]){
        _completionHandler = completionHandler;
        
        _fetchedFeeds = [NSMutableArray array];
        
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:url];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;//采用同步方式发送请求
       
        _isTimeout = NO;
        
        _fetchFinished = NO;
        
        _url = url;
        
        _timeout = timeout;
        
        _timer = [NSTimer timerWithTimeInterval:timeout target:self selector:@selector(parserTimeout) userInfo:nil repeats:NO];
    }
    return self;
}

- (id)initWithTryURL:(NSURL *)url timeout:(NSTimeInterval)timeout completionHandler:(void (^)(MWFeedInfo *items))completionHandler
{
    if(self = [super init]){
        _tryCompletionHandler = completionHandler;
        
        _fetchedFeeds = [NSMutableArray array];
        
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:url];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;//采用同步方式发送请求
        
        _isTimeout = NO;
        
        _fetchFinished = NO;
        
        _url = url;
        
        _timeout = timeout;
        
        _timer = [NSTimer timerWithTimeInterval:timeout target:self selector:@selector(parserTimeout) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)dealloc
{
    self.timer = nil;
    self.feedParser = nil;
    self.fetchedFeeds = nil;
    self.completionHandler = nil;
    self.url = nil;
    self.tryCompletionHandler = nil;
    
#ifdef PARSER_LOG
    NSLog(@"queue dealloc");
#endif

}

- (void)start{
    
#ifdef PARSER_LOG
    NSLog(@"queue start");
#endif

    //必须添加到mainRunLoop中，否则不会其作用，因为线程被[_feedParser parse]阻塞（采用同步方式发送请求）
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [super start];
}

- (void)main{
    
#ifdef PARSER_LOG
    NSLog(@"queue main");
#endif
    
    [_feedParser parse];
}

- (BOOL)isFinished
{
    if(_isTimeout||_fetchFinished){
        return YES;
    }
    return NO;
}

- (void)parserTimeout{
    if(_fetchFinished){
        return;
    }
    
    //willChange和didChange必须配合使用
    [self willChangeValueForKey:@"isFinished"];
    
    _isTimeout = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.completionHandler){
            self.completionHandler(self.fetchedFeeds);
        }
    });
    
#ifdef PARSER_LOG
    NSLog(@"queue timeout");
#endif
   
    [self didChangeValueForKey:@"isFinished"];
}

#pragma mark - MWFeedParser Delegate
//-(void)feedParserDidStart:(MWFeedParser *)parser {
//
//}

-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    if(self.tryCompletionHandler){
        self.tryCompletionHandler(info);
        [self willChangeValueForKey:@"isFinished"];
        
        _fetchFinished = YES;
        
        [self didChangeValueForKey:@"isFinished"];
    }
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    [self.fetchedFeeds addObject:item];
}

-(void)feedParserDidFinish:(MWFeedParser *)parser {

    if(_isTimeout){
        return;
    }
    
    [self willChangeValueForKey:@"isFinished"];
    
    _fetchFinished = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.completionHandler){
            self.completionHandler(self.fetchedFeeds);
        }
        
        if(self.tryCompletionHandler){
            self.tryCompletionHandler(nil);
        }
        
    });
    
#ifdef PARSER_LOG
    NSLog(@"queue finish");
#endif
   
    [self didChangeValueForKey:@"isFinished"];
}
@end
