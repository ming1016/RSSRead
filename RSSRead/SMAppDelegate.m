//
//  SMAppDelegate.m
//  RSSRead
//
//  Created by ming on 14-3-3.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAppDelegate.h"
#import "SMUIKitHelper.h"
#import "SMViewController.h"
#import "APService.h"
#import "SMFeedParserWrapper.h"
#import "MSDynamicsDrawerViewController.h"
#import "MSDynamicsDrawerStyler.h"
#import "SMMoreViewController.h"
#import "UIColor+RSS.h"
#import "SMBlurBackground.h"
@implementation SMAppDelegate
//{
//    SMViewController *_smViewController;
//}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //后台更新
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //清零
//    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //MSDynamicsDrawerViewController setting
    self.dynamicsDrawerViewController = [MSDynamicsDrawerViewController new];
    
    [self.dynamicsDrawerViewController addStylersFromArray:@[[MSDynamicsDrawerParallaxStyler styler]] forDirection:MSDynamicsDrawerDirectionLeft];

    [[UINavigationBar appearance] setTintColor:[UIColor rss_cyanColor]];
    SMViewController *smViewController = [[SMViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *rootViewNav = [[UINavigationController alloc]initWithRootViewController:smViewController];
    
    self.dynamicsDrawerViewController.paneViewController = rootViewNav;
    
    //Left drawer
    SMMoreViewController *moreVC = [[SMMoreViewController alloc]init];
    moreVC.dynamicsDrawerViewController = self.dynamicsDrawerViewController;
    [self.dynamicsDrawerViewController setDrawerViewController:moreVC forDirection:MSDynamicsDrawerDirectionLeft];
    
    self.window.rootViewController = self.dynamicsDrawerViewController;
    
    [self.window makeKeyAndVisible];
    
    //通知
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
    //模糊图片写入沙盒
    [SMBlurBackground SMRSSbackgroundImage:nil];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //显示未读数
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"RSS";
    getModel.predicate = [NSPredicate predicateWithFormat:@"isRead=0"];
    NSArray *allRss = [self getFetchedRecords:getModel];
    NSInteger allRssCount = allRss.count;
    [UIApplication sharedApplication].applicationIconBadgeNumber = allRssCount;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

// Core Data
-(NSArray *)getFetchedRecords:(SMGetFetchedRecordsModel *)getModel {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:getModel.entityName inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    if (getModel.sortName) {
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]initWithKey:getModel.sortName ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDescriptor, nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
    }
    if (getModel.limit) {
        [fetchRequest setFetchLimit:getModel.limit];
        [fetchRequest setFetchOffset:getModel.offset];
    }
    if (getModel.predicate) {
        [fetchRequest setPredicate:getModel.predicate];
    }
    
    NSError *error;
    NSArray *fetchedRecords = [_managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return fetchedRecords;
}

-(void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@,%@",error,[error userInfo]);
            abort();
        }
    }
}

- (NSManagedObjectContext *) managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
        
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
                                               stringByAppendingPathComponent: @"RSS.sqlite"]];
    NSError *error = nil;
    //下面的options能够解决每次修改coredata数据结构的不删除app就crash的问题。
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
                                   initWithManagedObjectModel:[self managedObjectModel]];
    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil URL:storeUrl options:options error:&error]) {
        /*Error for store creation should be handled in here*/
    }
    
    return _persistentStoreCoordinator;
}

- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark - background mode
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    //你有30秒的时间在这里从网络获取数据，完事后需要尽快调用completionHandler

    //取
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"Subscribes";
    NSArray *allSubscribes = [APP_DELEGATE getFetchedRecords:getModel];
    
    dispatch_group_t group = dispatch_group_create();
    
    [allSubscribes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        dispatch_group_enter(group);
        
        //解析rss
        NSURL *feedUrl = [NSURL URLWithString:((Subscribes *)obj).url];
        
        SMFeedParserWrapper *parserWrapper = [SMFeedParserWrapper new];
        parserWrapper.timeoutInterval = 20.0;
        [parserWrapper parseUrl:feedUrl completion:^(NSArray *items) {
            SMRSSModel *rssModel = [[SMRSSModel alloc]init];
            [rssModel insertRSSFeedItems:items ofFeedUrlStr:feedUrl.absoluteString];
            
            dispatch_group_leave(group);
            
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        completionHandler(UIBackgroundFetchResultNewData);
        
        //显示未读数
        SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
        getModel.entityName = @"RSS";
        getModel.predicate = [NSPredicate predicateWithFormat:@"isRead=0"];
        NSArray *allRss = [self getFetchedRecords:getModel];
        NSInteger allRssCount = allRss.count;
        [UIApplication sharedApplication].applicationIconBadgeNumber = allRssCount;
    });
}


#pragma mark - push
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

@end
