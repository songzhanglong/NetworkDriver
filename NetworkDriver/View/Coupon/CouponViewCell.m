//
//  CouponViewCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponViewCell.h"
#import <Masonry.h>

@interface CouponViewCell ()

@property (nonatomic,strong)UIImageView *rightArrowImg;
@property (nonatomic,strong)UIView *bottomLineView;

@end

@implementation CouponViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.priceLab];
        [self.contentView addSubview:self.dateLab];
        [self.contentView addSubview:self.rightArrowImg];
        [self.contentView addSubview:self.bottomLineView];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.dateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.centerY.equalTo(self.contentView.mas_centerY);
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
        make.left.equalTo(self.dateLab.mas_left);
        make.right.equalTo(self.rightArrowImg.mas_right);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
    }];
}

#pragma mark - lazy load
- (UILabel *)dateLab
{
    if (!_dateLab) {
        _dateLab = [[UILabel alloc] init];
        [_dateLab setFont:MiddleFont];
        [_dateLab setTextColor:[UIColor darkGrayColor]];
        [_dateLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _dateLab;
}

- (UILabel *)priceLab
{
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        [_priceLab setFont:MiddleFont];
        [_priceLab setTextColor:[UIColor darkGrayColor]];
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
