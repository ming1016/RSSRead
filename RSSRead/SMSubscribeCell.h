//
//  SMSubscribeCell.h
//  RSSRead
//
//  Created by ming on 14-3-19.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Subscribes.h"

@interface SMSubscribeCell : UITableViewCell
@property(nonatomic,strong)Subscribes *subscribe;

+(float)heightForSubscribe;
@end
