//
//  SMPreferences.h
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "PAPreferences.h"
typedef NS_ENUM(NSInteger, EAppStatus) {
    eAppNewer = 0,
    eAppHasInitPreferences = 1
};

typedef NS_ENUM(NSInteger, EAppTheme) {
    eAppThemeWhite = 0,
    eAppThemeBlack
};

@interface SMPreferences : PAPreferences
ARC_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(PAPreferences)
@property (nonatomic, assign) EAppStatus status;
@property (nonatomic, assign) EAppTheme theme; //主题
@property (nonatomic, assign) BOOL isInitWithFetchRSS; //启动时是否自动同步
@property (nonatomic, assign) BOOL isUseYourOwnBackgroundImage; //是否启用自己的背景
@property (nonatomic, assign) BOOL isUseBlurForYourBackgroundImage; //是否启用模糊效果
@property (nonatomic, assign) float backgroundBlurRadius; //背景高斯模糊半径
@property (nonatomic,assign) UIImage * imageName;

@end
