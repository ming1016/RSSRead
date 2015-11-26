//
//  SMSubscribeCellViewModel.m
//  RSSRead
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import "SMSubscribeCellViewModel.h"

@implementation SMSubscribeCellViewModel

- (instancetype)initWithSubscribe:(Subscribes *)subscribe {
    self = [super init];
    if (self) {
        [self givePropertyWithValue:subscribe];
    }
    return self;
}

- (void)givePropertyWithValue:(Subscribes *)subscribe {
    self.title = subscribe.title;
    self.unReadCount = [subscribe.total stringValue];
}

@end
