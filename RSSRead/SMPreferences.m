//
//  SMPreferences.m
//  RSSRead
//
//  Created by Zhuoqian Zhou on 14-5-24.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMPreferences.h"

@implementation SMPreferences
ARC_SYNTHESIZE_SINGLETON_FOR_CLASS(SMPreferences)
@dynamic status;
@dynamic theme;
@dynamic isInitWithFetchRSS;
@dynamic isUseBlurForYourBackgroundImage;
@dynamic isUseYourOwnBackgroundImage;
@dynamic backgroundBlurRadius;
@dynamic imageName;
@end
