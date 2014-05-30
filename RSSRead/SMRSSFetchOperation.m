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

@interface SMRSSFetchOperation()<MWFeedParserDelegate>

@property (assign) BOOL isTimeout;

@property (assign) BOOL fetchFinished;


@property (nonatomic, retain)MWFeedParser *feedParser;

@property (nonatomic, retain) NSMutableArray *fetchedFeeds;

@property (nonatomic, retain) NSTimer *timer;

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

- (void)start{
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    [super start];
}

- (void)main{
    [_feedParser parse];
}

- (void)parserTimeout{
    if(_fetchFinished){
        return;
    }
    
    _isTimeout = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(self.fetchedFeeds);
    });
}

#pragma mark - MWFeedParser Delegate
//-(void)feedParserDidStart:(MWFeedParser *)parser {
//
//}

//-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
//    self.feedInfo = info;
//}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    [self.fetchedFeeds addObject:item];
}

-(void)feedParserDidFinish:(MWFeedParser *)parser {

    if(_isTimeout){
        return;
    }
    _fetchFinished = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        self.completionHandler(self.fetchedFeeds);
    });
}
@end
