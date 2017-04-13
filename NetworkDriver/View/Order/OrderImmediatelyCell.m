//
//  OrderImmediatelyCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderImmediatelyCell.h"
#import <Masonry.h>

@interface OrderImmediatelyCell ()

//@property (nonatomic,strong)UILabel *pricePreLab;
//@property (nonatomic,strong)UILabel *priceAfterLab;

@end

@implementation OrderImmediatelyCell

#pragma mark - Public
- (void)initialSubViews
{
    [super initialSubViews];
    [self.contentView addSubview:self.distanceLab];
    [self.contentView addSubview:self.routeLab];
    [self.contentView addSubview:self.bottomLineImg];
//    [self.contentView addSubview:self.priceLab];
//    [self.contentView addSubview:self.pricePreLab];
//    [self.contentView addSubview:self.priceAfterLab];
}

- (void)initialConstraint
{
    [super initialConstraint];
    [self.distanceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.marginLine.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    [self.routeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.distanceLab.mas_bottom).with.offset(10);
        make.centerX.equalTo(self.contentView.mas_centerX);
    }];
    [self.bottomLineImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.marginLine);
        make.top.equalTo(self.routeLab.mas_bottom).with.offset(20);
        //新增
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
//    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.bottomLineImg.mas_bottom).with.offset(20);
//        make.centerX.equalTo(self.contentView.mas_centerX);
//        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-20);
//    }];
//    [self.pricePreLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.priceLab.mas_bottom).with.offset(-7);
//        make.right.equalTo(self.priceLab.mas_left);
//    }];
//    [self.priceAfterLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.pricePreLab.mas_bottom);
//        make.left.equalTo(self.priceLab.mas_right);
//    }];
}

#pragma mark - lazy load
- (UILabel *)distanceLab
{
    if (!_distanceLab) {
        _distanceLab = [[UILabel alloc] init];
        [_distanceLab setFont:BigFont];
        [_distanceLab setTextColor:BASELINE_COLOR];
        [_distanceLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _distanceLab;
}

- (UILabel *)routeLab
{
    if (!_routeLab) {
        _routeLab = [[UILabel alloc] init];
        [_routeLab setFont:BigFont];
        [_routeLab setTextColor:BASELINE_COLOR];
        [_routeLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _routeLab;
}

- (UIImageView *)bottomLineImg
{
    if (!_bottomLineImg) {
        _bottomLineImg = [[UIImageView alloc] initWithImage:self.marginLine.image];
        [_bottomLineImg setHighlightedImage:self.marginLine.highlightedImage];
        _bottomLineImg.clipsToBounds = YES;
        _bottomLineImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bottomLineImg;
}

/*
- (UILabel *)priceLab
{
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        [_priceLab setFont:[UIFont systemFontOfSize:30]];
        [_priceLab setTextColor:BASELINE_COLOR];
        [_priceLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _priceLab;
}

- (UILabel *)pricePreLab
{
    if (!_pricePreLab) {
        _pricePreLab = [[UILabel alloc] init];
        [_pricePreLab setFont:MiddleFont];
        [_pricePreLab setText:@"约"];
        [_pricePreLab setTextColor:[UIColor blackColor]];
        [_pricePreLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _pricePreLab;
}

- (UILabel *)priceAfterLab
{
    if (!_priceAfterLab) {
        _priceAfterLab = [[UILabel alloc] init];
        [_priceAfterLab setFont:MiddleFont];
        [_priceAfterLab setText:@"元"];
        [_priceAfterLab setTextColor:[UIColor blackColor]];
        [_priceAfterLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _priceAfterLab;
}
*/
@end
