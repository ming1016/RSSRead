//
//  SMDetailViewBottomBar.m
//  RSSRead
//
//  Created by zhou on 14-5-22.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMDetailViewBottomBar.h"
#import "UIImage+Tint.h"
#import <ViewUtils.h>
#import "UIColor+TBExt.h"
#import "RSS.h"

@interface SMDetailViewBottomBar ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *flatShadowSepia;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@end

@implementation SMDetailViewBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.backButton setImage:[[UIImage imageNamed:@"toolbar_back"] imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    [self.favButton setImage:[[UIImage imageNamed:@"toolbar_favorite"] imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
}

- (void)fillWithRSS:(RSS *)rss;
{
    if(rss.isFav) {
        [self.favButton setImage:[UIImage imageNamed:@"toolbar_favorite"] forState:UIControlStateNormal];
    } else {
        [self.favButton setImage:[[UIImage imageNamed:@"toolbar_favorite"] imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    }
}

- (IBAction)backButtonTouched:(id)sender
{
    if([self.delegate respondsToSelector:@selector(bottomBarBackButtonTouched:)]){
        [self.delegate performSelector:@selector(bottomBarBackButtonTouched:) withObject:self];
    }
}

- (IBAction)favButtonTouched:(id)sender
{
    if([self.delegate respondsToSelector:@selector(bottomBarFavButtonTouched:)]){
        [self.delegate performSelector:@selector(bottomBarFavButtonTouched:) withObject:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
