//
//  SMFeedParserWrapper.h
//  RSSRead
//
//  Created by John Zhang on 5/15/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MWFeedParser/MWFeedParser.h>
#import "SMRSSModel.h"

@interface SMFeedParserWrapper : NSObject<MWFeedParserDelegate>
@property (assign) NSTimeInterval timeoutInterval;//请求超时时间（秒）
- (void)parseUrl:(NSURL *)url completion:(void (^)(NSArray *items))completionHandler;
@end
