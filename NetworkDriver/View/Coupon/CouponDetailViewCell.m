//
//  CouponDetailViewCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponDetailViewCell.h"
#import <Masonry.h>

@interface CouponDetailViewCell ()

@property (nonatomic,strong)UIView *leftBackView;
@property (nonatomic,strong)UIImageView *rightArrowImg;
@property (nonatomic,strong)UIView *bottomLineView;

@end

@implementation CouponDetailViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.leftBackView];
        [self.leftBackView addSubview:self.numberLab];
        [self.leftBackView addSubview:self.timeLab];
        [self.contentView addSubview:self.priceLab];
        [self.contentView addSubview:self.rightArrowImg];
        [self.contentView addSubview:self.bottomLineView];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.leftBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.numberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.equalTo(self.leftBackView.mas_right);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.numberLab.mas_left);
        make.top.equalTo(self.numberLab.mas_bottom).with.offset(2);
        make.bottom.equalTo(self.leftBackView.mas_bottom);
    }];
    [self.rightArrowImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.rightArrowImg.mas_left).with.offset(-2);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.leftBackView.mas_left);
        make.right.equalTo(self.rightArrowImg.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
    }];
}

#pragma mark - lazy load
- (UIView *)leftBackView
{
    if (!_leftBackView) {
        _leftBackView = [UIView new];
    }
    return _leftBackView;
}

- (UILabel *)numberLab
{
    if (!_numberLab) {
        _numberLab = [[UILabel alloc] init];
        [_numberLab setFont:SmallFont];
        [_numberLab setTextColor:[UIColor darkGrayColor]];
        [_numberLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _numberLab;
}

- (UILabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        [_timeLab setFont:MiddleFont];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _timeLab;
}

- (UILabel *)priceLab
{
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        [_priceLab setFont:MiddleFont];
        [_priceLab setTextColor:BASELINE_COLOR];
        [_priceLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _priceLab;
}

- (UIImageView *)rightArrowImg
{
    if (!_rightArrowImg) {
        _rightArrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_right.png"]];
    }
    return _rightArrowImg;
}

- (UIView *)bottomLineView
{
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] init];
        [_bottomLineView setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _bottomLineView;
}

@end
