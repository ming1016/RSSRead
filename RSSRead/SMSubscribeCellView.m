//
//  SMSubscribeCellView.m
//  RSSRead
//
//  Created by DaiMing on 15/11/25.
//  Copyright © 2015年 starming. All rights reserved.
//

#import "SMSubscribeCellView.h"
#import "Subscribes.h"
#import "UIColor-Expanded.h"
#import "SMSubscribeCellViewModel.h"
#import "Masonry.h"

@interface SMSubscribeCellView()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *countLabel;

@end

@implementation SMSubscribeCellView

#pragma mark - Life cycle
- (instancetype)initWithSubscribeViewModel:(SMSubscribeCellViewModel *)subscribeViewModel {
    self = [super init];
    if (self) {
        //
        [self buildLayout];
        [self giveViewValueWithViewModel:subscribeViewModel];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

#pragma mark - Interface
+ (CGFloat)heightForSubscribeCellView {
    return 70;
}

#pragma mark - Private
- (void)buildLayout {
    [self addSubview:self.titleLabel];
    [self addSubview:self.countLabel];
    [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-10);
        make.centerY.equalTo(self);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.centerY.equalTo(self);
        make.right.equalTo(self.countLabel.mas_left).offset(-10);
    }];
}

- (void)giveViewValueWithViewModel:(SMSubscribeCellViewModel *)subscribeViewModel {
    [self.titleLabel setText:subscribeViewModel.title];
    self.countLabel.hidden = YES;
    NSInteger count = [subscribeViewModel.unReadCount integerValue];
    if (count > 0) {
        [self.countLabel setText:[NSString stringWithFormat:@"%ld",(long)count]];
        self.countLabel.hidden = NO;
    }
}

#pragma mark - Getter
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    }
    return _titleLabel;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] init];
        _countLabel.font = [UIFont systemFontOfSize:12];
        _countLabel.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    }
    return _countLabel;
}

@end
