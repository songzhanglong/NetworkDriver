//
//  OrderPayCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPayCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface OrderPayCell ()

@property (nonatomic,strong)UILabel *unitLab;
@property (nonatomic,strong)UILabel *kilometreTip;
@property (nonatomic,strong)UILabel *durationTip;
@property (nonatomic,strong)UILabel *otherTip;
@property (nonatomic,strong)UILabel *couponTip;
@property (nonatomic,strong)UIImageView *kilometreImg;
@property (nonatomic,strong)UIImageView *durationImg;
@property (nonatomic,strong)UIImageView *otherImg;
@property (nonatomic,strong)UIImageView *couponImg;

@end

@implementation OrderPayCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.totalPrice];
        [self.contentView addSubview:self.unitLab];
        [self.contentView addSubview:self.kilometreTip];
        [self.contentView addSubview:self.kilometreImg];
        [self.contentView addSubview:self.kilometrePrice];
        
        [self.contentView addSubview:self.durationTip];
        [self.contentView addSubview:self.durationImg];
        [self.contentView addSubview:self.durationPrice];
        
        [self.contentView addSubview:self.otherTip];
        [self.contentView addSubview:self.otherImg];
        [self.contentView addSubview:self.otherPrice];
        
        [self.contentView addSubview:self.couponTip];
        [self.contentView addSubview:self.couponImg];
        [self.contentView addSubview:self.couponPrice];
        
        [self initialConstraint];
    }
    return self;
}

- (void)initialConstraint
{
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(@30);
    }];
    [self.unitLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.totalPrice.mas_right);
        make.bottom.equalTo(self.totalPrice.mas_bottom).with.offset(-7);
    }];

    //kilometre
    [self.kilometreTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.totalPrice.mas_bottom).with.offset(30);
        make.left.equalTo(@40);
    }];
    [self.kilometrePrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-40);
        make.centerY.equalTo(self.kilometreTip.mas_centerY);
    }];
    [self.kilometreImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.kilometreTip.mas_centerY);
        make.left.equalTo(self.kilometreTip.mas_right).with.offset(5);
        make.right.equalTo(self.kilometrePrice.mas_left).with.offset(-5);
        make.height.equalTo(@1);
    }];
    
    //duration
    [self.durationTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.kilometreTip.mas_bottom).with.offset(20);
        make.left.equalTo(self.kilometreTip.mas_left);
        make.width.and.height.equalTo(self.kilometreTip);
    }];
    [self.durationPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.kilometrePrice.mas_right);
        make.centerY.equalTo(self.durationTip.mas_centerY);
    }];
    [self.durationImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.durationTip.mas_centerY);
        make.left.equalTo(self.durationTip.mas_right).with.offset(5);
        make.right.lessThanOrEqualTo(self.durationPrice.mas_left).with.offset(-5);
    }];
    
    
    //other
    [self.otherTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.durationTip.mas_bottom).with.offset(20);
        make.left.equalTo(self.durationTip.mas_left);
        make.width.and.height.equalTo(self.kilometreTip);
    }];
    [self.otherPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.durationPrice.mas_right);
        make.centerY.equalTo(self.otherTip.mas_centerY);
    }];
    [self.otherImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.otherTip.mas_centerY);
        make.left.equalTo(self.otherTip.mas_right).with.offset(5);
        make.right.lessThanOrEqualTo(self.otherPrice.mas_left).with.offset(-5);
    }];
    
    //coupon
    [self.couponTip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.otherTip.mas_bottom).with.offset(20);
        make.left.equalTo(self.otherTip.mas_left);
        make.width.and.height.equalTo(self.kilometreTip);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-20);
    }];
    [self.couponPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.otherPrice.mas_right);
        make.centerY.equalTo(self.couponTip.mas_centerY);
    }];
    [self.couponImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.couponTip.mas_centerY);
        make.left.equalTo(self.couponTip.mas_right).with.offset(5);
        make.right.lessThanOrEqualTo(self.couponPrice.mas_left).with.offset(-5);
    }];
}

#pragma mark - lazy load
- (UILabel *)totalPrice
{
    if (!_totalPrice) {
        _totalPrice = [[UILabel alloc] init];
        [_totalPrice setFont:[UIFont systemFontOfSize:30]];
        [_totalPrice setTextColor:[UIColor blackColor]];
        [_totalPrice setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _totalPrice;
}

- (UILabel *)unitLab
{
    if (!_unitLab) {
        _unitLab = [[UILabel alloc] init];
        [_unitLab setFont:MiddleFont];
        [_unitLab setText:@"元"];
        [_unitLab setTextColor:[UIColor blackColor]];
        [_unitLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _unitLab;
}

- (UILabel *)kilometreTip
{
    if (!_kilometreTip) {
        _kilometreTip = [[UILabel alloc] init];
        [_kilometreTip setFont:MiddleFont];
        [_kilometreTip setText:@"公里费"];
        [_kilometreTip setTextColor:[UIColor darkGrayColor]];
        [_kilometreTip setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _kilometreTip;
}

- (UIImageView *)kilometreImg
{
    if (!_kilometreImg) {
        _kilometreImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_kilometreImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_kilometreImg setClipsToBounds:YES];
        [_kilometreImg setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _kilometreImg;
}

- (UILabel *)kilometrePrice
{
    if (!_kilometrePrice) {
        _kilometrePrice = [[UILabel alloc] init];
        [_kilometrePrice setFont:MiddleFont];
        [_kilometrePrice setTextColor:[UIColor darkGrayColor]];
        [_kilometrePrice setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _kilometrePrice;
}

- (UILabel *)durationTip
{
    if (!_durationTip) {
        _durationTip = [[UILabel alloc] init];
        [_durationTip setFont:MiddleFont];
        [_durationTip setText:@"时长费"];
        [_durationTip setTextColor:[UIColor darkGrayColor]];
        [_durationTip setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _durationTip;
}

- (UIImageView *)durationImg
{
    if (!_durationImg) {
        _durationImg = [[UIImageView alloc] initWithImage:self.kilometreImg.image];
        [_durationImg setHighlightedImage:self.kilometreImg.highlightedImage];
        [_durationImg setClipsToBounds:YES];
        [_durationImg setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _durationImg;
}

- (UILabel *)durationPrice
{
    if (!_durationPrice) {
        _durationPrice = [[UILabel alloc] init];
        [_durationPrice setFont:MiddleFont];
        [_durationPrice setTextColor:[UIColor darkGrayColor]];
        [_durationPrice setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _durationPrice;
}

- (UILabel *)otherTip
{
    if (!_otherTip) {
        _otherTip = [[UILabel alloc] init];
        [_otherTip setFont:MiddleFont];
        [_otherTip setText:@"其他费"];
        [_otherTip setTextColor:[UIColor darkGrayColor]];
        [_otherTip setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _otherTip;
}

- (UIImageView *)otherImg
{
    if (!_otherImg) {
        _otherImg = [[UIImageView alloc] initWithImage:self.kilometreImg.image];
        [_otherImg setHighlightedImage:self.kilometreImg.highlightedImage];
        [_otherImg setClipsToBounds:YES];
        [_otherImg setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _otherImg;
}

- (UILabel *)otherPrice
{
    if (!_otherPrice) {
        _otherPrice = [[UILabel alloc] init];
        [_otherPrice setFont:MiddleFont];
        [_otherPrice setTextColor:[UIColor darkGrayColor]];
        [_otherPrice setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _otherPrice;
}

- (UILabel *)couponTip
{
    if (!_couponTip) {
        _couponTip = [[UILabel alloc] init];
        [_couponTip setFont:MiddleFont];
        [_couponTip setText:@"优惠券"];
        [_couponTip setTextColor:[UIColor darkGrayColor]];
        [_couponTip setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _couponTip;
}

- (UIImageView *)couponImg
{
    if (!_couponImg) {
        _couponImg = [[UIImageView alloc] initWithImage:self.kilometreImg.image];
        [_couponImg setHighlightedImage:self.kilometreImg.highlightedImage];
        [_couponImg setClipsToBounds:YES];
        [_couponImg setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _couponImg;
}

- (UILabel *)couponPrice
{
    if (!_couponPrice) {
        _couponPrice = [[UILabel alloc] init];
        [_couponPrice setFont:MiddleFont];
        [_couponPrice setTextColor:[UIColor darkGrayColor]];
        [_couponPrice setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _couponPrice;
}

@end
