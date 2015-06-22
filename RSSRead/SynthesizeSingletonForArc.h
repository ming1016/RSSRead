//
//  SynthesizeSingletonForArc.h
//  RSSRead
//
//  Created by ming on 15/6/22.
//  Copyright (c) 2015年 starming. All rights reserved.
//

// @header
#define ARC_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SS_CLASSNAME)	\
+ (SS_CLASSNAME *)sharedInstance;

// @implementation
#define ARC_SYNTHESIZE_SINGLETON_FOR_CLASS(SS_CLASSNAME) \
+ (SS_CLASSNAME *)sharedInstance { \
static SS_CLASSNAME *_##SS_CLASSNAME##_sharedInstance = nil; \
static dispatch_once_t onceToken; \
dispatch_once(&onceToken, ^{ \
_##SS_CLASSNAME##_sharedInstance = [[self alloc] init]; \
}); \
return _##SS_CLASSNAME##_sharedInstance; \
}

