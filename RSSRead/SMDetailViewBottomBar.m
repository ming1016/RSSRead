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
#import "SMPreferences.h"

@interface SMDetailViewBottomBar ()

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *flatShadowSepia;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIButton *themeButton;

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
    [self.backButton setImage:[self.backButton.currentImage imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    [self.favButton setImage:[self.favButton.currentImage imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    [self.themeButton setImage:[self.themeButton.currentImage imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    [self setupSubviews];
}

- (void)fillWithRSS:(RSS *)rss;
{
    if([rss.isFav isEqual:@1]) {
        [self.favButton setImage:[UIImage imageNamed:@"toolbar_favorite"] forState:UIControlStateNormal];
    } else {
        [self.favButton setImage:[[UIImage imageNamed:@"toolbar_favorite"] imageWithTintColor:[UIColor colorFromRGB:0xcccccc]] forState:UIControlStateNormal];
    }
}

- (void)setupSubviews
{
    
    if([[SMPreferences sharedInstance] theme] == eAppThemeWhite) {
        // 白色。。。
        self.backgroundColor = [UIColor whiteColor];
        [self.flatShadowSepia setImage:[self.flatShadowSepia.image imageWithTintColor:[UIColor colorFromRGB:0x999999]]];
    } else {
        // 黑色
        self.backgroundColor = [UIColor blackColor];
        [self.flatShadowSepia setImage:[self.flatShadowSepia.image imageWithTintColor:[UIColor colorFromRGB:0xcccccc]]];
    }
    
}

- (IBAction)themeButtonTouched:(id)sender {
    if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
        [[SMPreferences sharedInstance] setTheme:eAppThemeWhite];
    } else {
        [[SMPreferences sharedInstance] setTheme:eAppThemeBlack];
    }
    [self setupSubviews];
    if([self.delegate respondsToSelector:@selector(bottomBarThemeButtonTouched:)]){
        [self.delegate performSelector:@selector(bottomBarThemeButtonTouched:) withObject:self];
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
