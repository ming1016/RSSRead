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
#import "SMRSSListCellMgr.h"
#import "SMPreferences.h"

@interface SMRSSListCell ()
@property (nonatomic, strong) UILabel *deleteGreyImageView;
@end

@implementation SMRSSListCell {
    NSDateFormatter *_formatter;
    UILabel *_lbTitle;
    UILabel *_lbSummary;
    UILabel *_lbDate;
    NSString *_darkcolor;
    NSString *_lightColor;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"MM.dd HH:mm"];
        
        //背景颜色
        _darkcolor = nil;
        _lightColor = nil;
        if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
            self.contentView.backgroundColor = [SMUIKitHelper colorWithHexString:@"#252525"];
            _darkcolor = @"#cccccc";
            _lightColor = @"#404040";
        } else {
            self.contentView.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
            _darkcolor = LIST_DARK_COLOR;
            _lightColor = LIST_LIGHT_COLOR;
        }
        
        _lbTitle = [SMUIKitHelper labelWithRect:CGRectZero text:nil textColor:_darkcolor fontSize:LIST_BIG_FONT];
        _lbTitle.numberOfLines = 99;
        _lbTitle.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:_lbTitle];
        
        _lbSummary = [SMUIKitHelper labelWithRect:CGRectZero text:nil textColor:_lightColor fontSize:LIST_SMALL_FONT];
        [self.contentView addSubview:_lbSummary];
        
        _lbDate = [SMUIKitHelper labelWithRect:CGRectZero text:nil textColor:_lightColor fontSize:LIST_SMALL_FONT];
        _lbDate.left = kRSSListCellMarginLeft;
        [self.contentView addSubview:_lbDate];
//        [self setupSeperateLine];
    }
    return self;
}

- (void)setupSeperateLine
{
    int leftMargin = 10;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(leftMargin, 0, self.contentView.width - leftMargin * 2, 1)];
    view.backgroundColor = [UIColor colorFromRGB:0xeeeeee];
    [self.contentView addSubview:view];
}

-(void)setRss:(RSS *)rss {
    [_lbTitle setText:rss.title];
    [_lbDate setText:[NSString stringWithFormat:@"[%@]",[_formatter stringFromDate:rss.date]]];
    if ([rss.isFav isEqual:@1]) {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:LIST_YELLOW_COLOR];
    } else if([rss.isRead  isEqual: @1]) {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:_lightColor];
    } else {
        _lbTitle.textColor = [SMUIKitHelper colorWithHexString:_darkcolor];
    }
    [_lbSummary setText:[rss.summary stringByConvertingHTMLToPlainText]];
    [self setNeedsDisplay];
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGRect rect = CGRectZero;
    rect.origin.x = kRSSListCellMarginLeft;
    rect.origin.y = kRSSListCellPaddingTop;
    rect.size = _cellMgr.titleLabelSize;
    
    _lbTitle.frame = rect;
    
    //时间
    [_lbDate sizeToFit];
    _lbDate.top = kRSSListCellDateMarginTop + _lbTitle.bottom;
    
    int summaryMarginLeft = 10;
    _lbSummary.top = kRSSListCellDateMarginTop + _lbTitle.bottom;
    _lbSummary.left = _lbDate.right + summaryMarginLeft;
    [_lbSummary sizeToFit];
    _lbSummary.width = self.contentView.width - kRSSListCellMarginLeft * 2 - _lbDate.width;
    
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
