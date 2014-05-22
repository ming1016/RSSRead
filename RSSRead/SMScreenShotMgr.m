//
//  SMScreenShotMgr.m
//  RSSRead
//
//  Created by zhou on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMScreenShotMgr.h"
#import <MMLayershots/MMLayershots.h>

@interface SMScreenShotMgr ()<MMLayershotsDelegate>

@end

@implementation SMScreenShotMgr

+ (instancetype)sharedInstance;
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[MMLayershots sharedInstance] setDelegate:self];
    }
    return self;
}

- (void)takeScreenShot;
{
#if TARGET_IPHONE_SIMULATOR
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationUserDidTakeScreenshotNotification object:nil];
#endif
}

#pragma mark - layer shots delegate

- (CGFloat)shouldCreatePSDDataAfterDelay {
    // set a delay, e.g. to show a notification before starting the capture.
    // During the capture, the screen currently doesn't support showing any
    // progress indication. Everything that is shown will just simply be rendered
    // as well.
    NSLog(@"Will start assembling psd in 3 seconds...");
    CGFloat delay = 3.0;
    return delay;
}

- (void)willCreatePSDDataForScreen:(UIScreen *)screen {
    //Creating psd now...
    NSLog(@"Creating psd now...");
}

+ (NSString *)__documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (void)didCreatePSDDataForScreen:(UIScreen *)screen data:(NSData *)data {
    NSString *dataPath = [[[self class] __documentsDirectory] stringByAppendingPathComponent:@"layershots.psd"];
    [data writeToFile:dataPath atomically:NO];
    NSLog(@"Saving psd to \n%@", dataPath);
    
}

@end
