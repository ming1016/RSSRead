//
//  SMSubscribeCellViewModel.h
//  RSSRead
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Subscribes.h"

@interface SMSubscribeCellViewModel : NSObject

@property (nonatomic, copy) NSString *title;        //标题
@property (nonatomic, copy) NSString *unReadCount;  //未读数

- (instancetype)initWithSubscribe:(Subscribes *)subscribe;

@end
