//
//  OrderPersonCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPersonCell.h"
#import <Masonry.h>

@implementation OrderPersonCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.headImg];
        [self.contentView addSubview:self.nameLab];
        [self.contentView addSubview:self.phoneBtn];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.headImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.width.and.height.equalTo(@52);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headImg.mas_right).with.offset(3);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.phoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-10);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
}

#pragma mark - lazy load
- (UIImageView *)headImg
{
    if (!_headImg) {
        _headImg = [[UIImageView alloc] init];
        _headImg.contentMode = UIViewContentModeScaleAspectFill;
        _headImg.layer.masksToBounds = YES;
        _headImg.layer.cornerRadius = 26;
    }
    return _headImg;
}

- (UILabel *)nameLab
{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        [_nameLab setFont:MiddleFont];
        [_nameLab setTextColor:[UIColor blackColor]];
        [_nameLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _nameLab;
}

- (UIButton *)phoneBtn
{
    if (!_phoneBtn) {
        _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneBtn setImage:[UIImage imageNamed:@"order_phone.png"] forState:UIControlStateNormal];
    }
    return _phoneBtn;
}

@end
