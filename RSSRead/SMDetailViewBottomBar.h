//
//  SMDetailViewBottomBar.h
//  RSSRead
//
//  Created by zhou on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMDetailViewBottomBarDelegate <NSObject>

- (void)bottomBarBackButtonTouched:(id)sender;
- (void)bottomBarFavButtonTouched:(id)sender;
- (void)bottomBarThemeButtonTouched:(id)sender;

@end

@class RSS;
@interface SMDetailViewBottomBar : UIView

@property (weak, nonatomic) id<SMDetailViewBottomBarDelegate> delegate;
- (void)fillWithRSS:(RSS *)rss;

@end
