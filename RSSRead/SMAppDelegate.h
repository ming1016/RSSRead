//
//  SMAppDelegate.h
//  RSSRead
//
//  Created by ming on 14-3-3.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGetFetchedRecordsModel.h"

@interface SMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,readonly,retain)NSManagedObjectModel *managedObjectModel;
@property(nonatomic,readonly,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,readonly,retain)NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSString *)applicationDocumentsDirectory;
-(NSArray *)getFetchedRecords:(SMGetFetchedRecordsModel *)getModel;
@end
