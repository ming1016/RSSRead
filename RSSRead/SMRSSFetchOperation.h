//
//  SMRSSFetchOperation.h
//  RSSRead
//
//  Created by John Zhang on 5/30/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MWFeedInfo;

@interface SMRSSFetchOperation : NSOperation



- (id) initWithURL:(NSURL *)url timeout:(NSTimeInterval)timeout completionHandler:(void (^)(NSArray *items))completionHandler;

- (id)initWithTryURL:(NSURL *)url timeout:(NSTimeInterval)timeout completionHandler:(void (^)(MWFeedInfo *items))completionHandler;

@end
