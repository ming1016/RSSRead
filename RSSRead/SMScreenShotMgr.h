//
//  SMScreenShotMgr.h
//  RSSRead
//
//  Created by zhou on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMScreenShotMgr : NSObject

+ (instancetype)sharedInstance;
- (void)takeScreenShot;

@end
