//
//  SMSubscribeCellView.h
//  RSSRead
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMSubscribeCellViewModel;

@interface SMSubscribeCellView : UIView

- (instancetype)initWithSubscribeViewModel:(SMSubscribeCellViewModel *)subscribeViewModel;

+ (CGFloat)heightForSubscribeCellView;
@end
