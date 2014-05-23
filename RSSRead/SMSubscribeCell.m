//
//  SMSubscribeCell.m
//  RSSRead
//
//  Created by ming on 14-3-19.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMSubscribeCell.h"
#import "SMUIKitHelper.h"

@implementation SMSubscribeCell {
    UILabel *_lbtitle;
    UIView *_sepView;
    UIButton *_btCount;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        _lbtitle = [SMUIKitHelper labelWithRect:CGRectZero text:nil textColor:@"#FFFFFF" fontSize:18];
        [self.contentView addSubview:_lbtitle];
        
        _btCount = [UIButton buttonWithType:UIButtonTypeCustom];
        _btCount.titleLabel.font = [UIFont systemFontOfSize:12];
        [_btCount setUserInteractionEnabled:NO];
        [self.contentView addSubview:_btCount];
    }
    return self;
}

-(void)setSubscribe:(Subscribes *)subscribe {
    _btCount.hidden = YES;
    NSInteger count = [subscribe.total integerValue];
    if (count > 0) {
        [_btCount setTitle:[NSString stringWithFormat:@"%ld",(long)count] forState:UIControlStateNormal];
        _btCount.hidden = NO;
    }
    
    [_lbtitle setText:subscribe.title];
    [self setNeedsDisplay];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGRect rect = CGRectZero;
    rect.origin.x = 30;
    rect.origin.y = 14;
    CGSize fitSize = [_lbtitle.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    rect.size = fitSize;
    rect.size.width = SCREEN_WIDTH - 56;
    _lbtitle.frame = rect;
    
    //记总数
    [_btCount setFrame:CGRectMake(SCREEN_WIDTH - 50, 18, 28, 18)];
}

+(float)heightForSubscribe {
    return 70;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
