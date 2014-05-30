//
//  SMRSSFetchOperation.h
//  RSSRead
//
//  Created by John Zhang on 5/30/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMRSSFetchOperation : NSOperation

@property (readonly, nonatomic) NSTimeInterval timeout;

@property (readonly,nonatomic) NSURL *url;

@property (copy, nonatomic) void (^completionHandler)(NSArray *items);

- (id) initWithURL:(NSURL *)url timeout:(NSTimeInterval)timeout completionHandler:(void (^)(NSArray *items))completionHandler;
@end
