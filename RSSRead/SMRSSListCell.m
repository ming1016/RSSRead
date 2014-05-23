//
//  SMRSSListCell.m
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMRSSListCell.h"
#import "SMUIKitHelper.h"
#import "NSString+HTML.h"

@interface SMRSSListCell ()
@property (nonatomic, strong) UILabel *deleteGreyImageView;
@end

@implementation SMRSSListCell {
    NSDateFormatter *_formatter;
    UILabel *_lbTitle;
    UILabel *_lbSummary;
    UILabel *_lbSource;
    UILabel *_lbDate;
}

static const NSInteger kRSSListCellMarginLeft = 21;
static const NSInteger kRSSListCellPaddingTop = 12;
static const NSInteger kRSSListCellDateMarginTop = 6;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MM.dd HH:mm"];
        
        self.contentView.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
        _lbTitle = [SMUIKitHelper labelShadowWithRect:CGRectZero text:nil textColor:LIST_DARK_COLOR fontSize:LIST_BIG_FONT];
        _lbTitle.numberOfLines = 99;
        _lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:_lbTitle];
        
        _lbSummary = [SMUIKitHelper labelShadowWithRect:CGRectZero text:nil textColor:LIST_LIGHT_COLOR fontSize:LIST_SMALL_FONT];
        [self.contentView addSubview:_lbSummary];
        
        _lbSource = [SMUIKitHelper labelShadowWithRect:CGRectZero text:nil textColor:LIST_LIGHT_COLOR fontSize:LIST_SMALL_FONT];
        [self.contentView addSubview:_lbSource];
        
        _lbDate = [SMUIKitHelper labelShadowWithRect:CGRectZero text:nil textColor:LIST_LIGHT_COLOR fontSize:LIST_SMALL_FONT];
        [self.contentView addSubview:_lbDate];
        
    }
    return self;
}

-(void)setRss:(RSS *)rss {
    [_lbTitle setText:rss.title];
    [_lbSource setText:_subscribeTitle];
    [_lbDate setText:[NSString stringWithFormat:@"[%@]",[_formatter stringFromDate:rss.date]]];
    if ([rss.isFav isEqual:@1]) {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:LIST_YELLOW_COLOR];
    } else if([rss.isRead  isEqual: @1]) {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:LIST_LIGHT_COLOR];
    } else {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:LIST_DARK_COLOR];
    }
    [_lbSummary setText:[rss.summary stringByConvertingHTMLToPlainText]];
    [self setNeedsDisplay];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGRect rect = CGRectZero;
    rect.origin.x = kRSSListCellMarginLeft;
    rect.origin.y = kRSSListCellPaddingTop;
    
    //来源
//    CGSize fitSize = [_lbSource.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:LIST_SMALL_FONT]}];
//    rect.size = fitSize;
//    _lbSource.frame = rect;
    
    //标题
//    rect.origin.x = _lbSource.frame.origin.x;
//    rect.origin.y += fitSize.height + 2;
    CGSize fitSize = [_lbTitle.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - kRSSListCellMarginLeft * 2, 99) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_BIG_FONT]} context:nil].size;
    rect.size = fitSize;
    _lbTitle.frame = rect;
    
    //时间
    rect.origin.y += fitSize.height + kRSSListCellDateMarginTop;
    if (_lbDate.text) {
        fitSize = [_lbDate.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_SMALL_FONT]}];
        rect.size = fitSize;
//        rect.origin.x = SCREEN_WIDTH - fitSize.width - 11;
        _lbDate.frame = rect;
    }
    
    int summaryMarginLeft = 2;
    //简介
    rect.origin.x += fitSize.width + summaryMarginLeft;
    fitSize = [_lbSummary.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_SMALL_FONT]}];
    fitSize.width = SCREEN_WIDTH - kRSSListCellMarginLeft*2 - _lbDate.frame.size.width;
    rect.size = fitSize;
    _lbSummary.frame = rect;
}

+(float)heightForRSSList:(RSS *)rss {
    float countHeight = kRSSListCellPaddingTop;
    
//    CGSize fitSize = [rss.author sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_SMALL_FONT]}];
//    countHeight += fitSize.height + 2;
    
    CGSize fitSize = [rss.title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - kRSSListCellMarginLeft*2, 999) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_BIG_FONT]} context:nil].size;
    countHeight += fitSize.height + kRSSListCellDateMarginTop;
    
    fitSize = [rss.summary sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:LIST_SMALL_FONT]}];
    countHeight += fitSize.height;
    
    countHeight += kRSSListCellPaddingTop;
    return countHeight;
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

#pragma mark - 


-(void)animateContentViewForPoint:(CGPoint)point velocity:(CGPoint)velocity {
    [super animateContentViewForPoint:point velocity:velocity];
    if (point.x < 0) {
        [self.deleteGreyImageView setFrame:CGRectMake(MAX(CGRectGetMaxX(self.frame) - CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetMaxX(self.contentView.frame)), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
    }
}

-(void)resetCellFromPoint:(CGPoint)point velocity:(CGPoint)velocity {
    [super resetCellFromPoint:point velocity:velocity];
    if (point.x < 0) {
        if (-point.x <= CGRectGetHeight(self.frame)) {
            // user did not swipe far enough, animate the grey X back with the contentView animation
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView setFrame:CGRectMake(CGRectGetMaxX(self.frame), CGRectGetMinY(self.deleteGreyImageView.frame), CGRectGetWidth(self.deleteGreyImageView.frame), CGRectGetHeight(self.deleteGreyImageView.frame))];
                             }];
        } else {
            // user did swipe far enough to meet the delete action requirement, animate the Xs to show selection
            [UIView animateWithDuration:self.animationDuration
                             animations:^{
                                 [self.deleteGreyImageView.layer setTransform:CATransform3DMakeScale(2, 2, 2)];
                                 [self.deleteGreyImageView setAlpha:0];
                             }];
        }
    }
}

-(void)prepareForReuse {
	[super prepareForReuse];
	self.textLabel.textColor = [UIColor blackColor];
	self.detailTextLabel.text = nil;
	self.detailTextLabel.textColor = [UIColor grayColor];
	[self setUserInteractionEnabled:YES];
	self.imageView.alpha = 1;
	self.accessoryView = nil;
	self.accessoryType = UITableViewCellAccessoryNone;
    [self.contentView setHidden:NO];
     [self cleanupBackView];
}


-(void)cleanupBackView {
    [super cleanupBackView];
    [_deleteGreyImageView removeFromSuperview];
    _deleteGreyImageView = nil;
}


-(UILabel *)deleteGreyImageView {
    if (!_deleteGreyImageView) {
        
        UILabel *introLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.contentView.frame), 0, CGRectGetHeight(self.frame), CGRectGetHeight(self.frame))];
        [introLabel setFont:[UIFont systemFontOfSize:10]];
        [introLabel setBackgroundColor:[UIColor clearColor]];
        introLabel.textColor = [UIColor lightGrayColor];
        [introLabel setText:@"不感兴趣"];
        [introLabel setNumberOfLines:0];
        [introLabel sizeToFit];
        
        introLabel.top = (self.contentView.height - introLabel.height)/2;
        _deleteGreyImageView = introLabel;

        [_deleteGreyImageView setContentMode:UIViewContentModeCenter];
        [self.backView addSubview:_deleteGreyImageView];
    }
    return _deleteGreyImageView;
}


@end
