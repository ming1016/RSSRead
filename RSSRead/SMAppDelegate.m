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
#import "UIColor+RSS.h"
#import "SMBlurBackground.h"
#import "EvernoteSDK.h"
#import "EvernoteSession.h"
#import "ENConstants.h"
#import "SMShareViewController.h"
#import "SMPreferences.h"
#import "SMFeedUpdateController.h"
#import "SMBlurBackground.h"
#import "SMSettingViewController.h"

@implementation SMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //开启RSS源后台更新
    [SMFeedUpdateController start];
    
    
    //后台更新
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    //清零
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    
    //初始化设置项目
    if ([[SMPreferences sharedInstance] status] != eAppHasInitPreferences) {
        //设置各项的默认值
        [[SMPreferences sharedInstance] setTheme:eAppThemeWhite];
        [[SMPreferences sharedInstance] setStatus:eAppHasInitPreferences];
        [[SMPreferences sharedInstance] setIsInitWithFetchRSS:NO];
        [[SMPreferences sharedInstance] setIsUseBlurForYourBackgroundImage:YES];
        [[SMPreferences sharedInstance] setIsUseYourOwnBackgroundImage:NO];
        [[SMPreferences sharedInstance] synchronize];
    }
    if (![[SMPreferences sharedInstance] backgroundBlurRadius]) {
        [[SMPreferences sharedInstance] setBackgroundBlurRadius:0.8];
        [[SMPreferences sharedInstance] synchronize];
    }
    
    if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UINavigationBar appearance] setBarTintColor:[SMUIKitHelper colorWithHexString:@"#333333"]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0]}];
    } else {
//        _bgColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
//        _selectBgColor = [SMUIKitHelper colorWithHexString:@"#f2f2f2"];
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    
    
    
    //填写印象笔记相关key信息
    //BootstrapServerBaseURLStringSandbox
    //BootstrapServerBaseURLStringCN
    NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringSandbox;
    NSString *CONSUMER_KEY = @"66322510";
    NSString *CONSUMER_SECRET = @"404740e1e2b2f71d";
    
    [EvernoteSession setSharedSessionHost:EVERNOTE_HOST
                              consumerKey:CONSUMER_KEY
                           consumerSecret:CONSUMER_SECRET];
    //测试印象 OAUTH认证
    //SMShareViewController *shareVc = [[SMShareViewController alloc] init];
    //self.window.rootViewController = shareVc;
    
    //首页
    [[UINavigationBar appearance] setTintColor:[UIColor rss_cyanColor]];
    SMViewController *smViewController = [[SMViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *rootViewNav = [[UINavigationController alloc]initWithRootViewController:smViewController];
    rootViewNav.tabBarItem.title = @"首页";
    rootViewNav.tabBarItem.image = [UIImage imageNamed:@"icoHome"];
    
    //收藏
    SMRSSListViewController *favVC = [[SMRSSListViewController alloc]initWithNibName:nil bundle:nil];
    favVC.isFav = YES;
    favVC.isNewVC = YES;
    UINavigationController *navFavVC = [[UINavigationController alloc]initWithRootViewController:favVC];
    navFavVC.tabBarItem.title = @"收藏";
    navFavVC.tabBarItem.image = [UIImage imageNamed:@"icoFav"];
    
    //设置
    SMSettingViewController *smSettingVC = [[SMSettingViewController alloc]initWithNibName:nil bundle:nil];
    UINavigationController *navSettingVC = [[UINavigationController alloc]initWithRootViewController:smSettingVC];
    navSettingVC.tabBarItem.image = [UIImage imageNamed:@"icoSetting"];
    
    UITabBarController *tabBarC = [[UITabBarController alloc]initWithNibName:nil bundle:nil];
    tabBarC.viewControllers = @[rootViewNav,navFavVC,navSettingVC];
    self.window.rootViewController = tabBarC;
    
    self.window.rootViewController.view.alpha = 0;
    [self.window makeKeyAndVisible];
    //闪屏
    UIImageView *splashView = [SMBlurBackground SMbackgroundView];
    [self.window addSubview:splashView];
    [UIView animateWithDuration:0.7 animations:^{
        self.window.rootViewController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [splashView removeFromSuperview];
    }];
    
    //通知
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [UIApplication sharedApplication].applicationIconBadgeNumber =0;
    //印象笔记
    [[EvernoteSession sharedSession] handleDidBecomeActive];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

// Core Data
-(NSArray *)getFetchedRecords:(SMGetFetchedRecordsModel *)getModel {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:getModel.entityName inManagedObjectContext:self.managedObjectContext];
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
    //下面的options能够解决每次修改coredata数据结构的不删除app就crash的问题。要注意，改变coredata数据结构时需要添加一个新版本xcdatamodeldz，具体操作可以查看项目wiki
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
        
        [SMFeedParserWrapper parseUrl:feedUrl timeout:20 completion:^(NSArray *items) {
            SMRSSModel *rssModel = [[SMRSSModel alloc]init];
            [rssModel insertRSSFeedItems:items ofFeedUrlStr:feedUrl.absoluteString];
            
            dispatch_group_leave(group);
            
        }];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        completionHandler(UIBackgroundFetchResultNewData);
        
        //显示未读数
//        SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
//        getModel.entityName = @"RSS";
//        getModel.predicate = [NSPredicate predicateWithFormat:@"isRead=0"];
//        NSArray *allRss = [self getFetchedRecords:getModel];
//        NSInteger allRssCount = allRss.count;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = allRssCount;
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL canHandle = NO;
    if ([[NSString stringWithFormat:@"en-%@", [[EvernoteSession sharedSession] consumerKey]] isEqualToString:[url scheme]] == YES) {
        canHandle = [[EvernoteSession sharedSession] canHandleOpenURL:url];
    }
    return canHandle;
}

#pragma mark -
#pragma mark OpenDoorViewControllerDelegate
- (void)didFinishAnimation{
    //self.window.rootViewController = self.dynamicsDrawerViewController;
}

@end
