//
//  SMFeedUpdateController.h
//  RSSRead
//
//  Created by John Zhang on 6/1/14.
//  Copyright (c) 2014 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMFeedUpdateController : NSObject

+(void)start;

+(void)setUpdateCheckTimeInterval:(NSTimeInterval)timeInterval;

+(void)stop;

+(void)invalidateRSSList;

@end
