//
//  SMMoreCell.m
//  RSSRead
//
//  Created by ming on 14-3-4.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMMoreCell.h"
#import "SMUIKitHelper.h"

@implementation SMMoreCell {
    UILabel *_lbName;
    UIView *_sepView;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor clearColor];
        _lbName = [SMUIKitHelper labelWithRect:CGRectZero text:nil textColor:@"#FFFFFF" fontSize:18];
        [self.contentView addSubview:_lbName];
    }
    return self;
}

-(void)setOption:(NSDictionary *)option {
    _option = option;
    [_lbName setText:option[@"cn"]];
    [self setNeedsDisplay];
}

-(void)layoutSubviews {
    CGRect rect = CGRectZero;
    rect.origin.x = 40;
    rect.origin.y = 14;
    CGSize fitSize = [_lbName.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:18]}];
    rect.size = fitSize;
    [_lbName setFrame:rect];
}

+(float)heightForOption {
    return 45;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
