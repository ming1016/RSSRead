//
//  SMPreferences.h
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "PAPreferences.h"

typedef NS_ENUM(NSInteger, EAppTheme) {
    eAppThemeWhite = 0,
    eAppThemeBlack
};

@interface SMPreferences : PAPreferences
@property (nonatomic, assign) EAppTheme theme;

@end
