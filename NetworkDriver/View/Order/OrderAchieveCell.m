//
//  OrderAchieveCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderAchieveCell.h"
#import <Masonry.h>

@interface OrderAchieveCell ()

@property (nonatomic,strong)UILabel *unitLab;

@end

@implementation OrderAchieveCell

#pragma mark - Public Methods
- (void)initialSubViews
{
    [super initialSubViews];
    
    [self.contentView addSubview:self.totalPrice];
    [self.contentView addSubview:self.unitLab];
}

- (void)initialConstraint
{
    [super initialConstraint];
    
    [self.totalPrice sizeToFit];
    CGFloat totalHei = self.totalPrice.frameHeight;
    [self.totalPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.top.equalTo(self.marginLine.mas_bottom).with.offset(15);
        make.height.equalTo(@(totalHei));
    }];
    [self.unitLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.totalPrice.mas_right);
        make.bottom.equalTo(self.totalPrice.mas_bottom).with.offset(-7);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-15);
    }];
}

#pragma mark - lazy load
- (UILabel *)totalPrice
{
    if (!_totalPrice) {
        _totalPrice = [[UILabel alloc] init];
        [_totalPrice setFont:[UIFont systemFontOfSize:30]];
        [_totalPrice setText:@"0"];
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

@end
