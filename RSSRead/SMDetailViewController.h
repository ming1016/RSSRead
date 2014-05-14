//
//  SMDetailViewController.h
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSS.h"

@protocol SMDetailViewControllerDelegate

@optional
-(void)unFav;
-(void)faved;

@end

@interface SMDetailViewController : UIViewController
@property(nonatomic,strong)RSS *rss;
@property(nonatomic,assign)id<SMDetailViewControllerDelegate>delegate;

@end
