//
//  OrderTurnoverRateCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderTurnoverRateCell.h"
#import <Masonry.h>

@interface OrderTurnoverRateCell ()

@property (nonatomic,strong)UIView *sucContentView;
@property (nonatomic,strong)UILabel *upLab;
@property (nonatomic,strong)UILabel *tipLab;

@end

@implementation OrderTurnoverRateCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.sucContentView];
        [self.sucContentView addSubview:self.upLab];
        [self.sucContentView addSubview:self.tipLab];
        [self.sucContentView addSubview:self.rateLab];
        
        [self initialConstraint];
    }
    return self;
}

- (void)initialConstraint
{
    [self.sucContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.upLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.lessThanOrEqualTo(self.sucContentView.mas_right);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.upLab.mas_bottom).with.offset(15);
        make.centerX.equalTo(self.upLab.mas_centerX);
    }];
    [self.rateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.upLab.mas_centerX);
        make.bottom.equalTo(self.sucContentView.mas_bottom);
        make.right.lessThanOrEqualTo(self.sucContentView.mas_right);
    }];
}

#pragma mark - lazy load
- (UIView *)sucContentView
{
    if (!_sucContentView) {
        _sucContentView = [[UIView alloc] init];
    }
    return _sucContentView;
}

- (UILabel *)upLab
{
    if (!_upLab) {
        _upLab = [[UILabel alloc] init];
        [_upLab setFont:BigFont];
        [_upLab setText:@"订单已派送给其他司机"];
        [_upLab setTextColor:[UIColor blackColor]];
        [_upLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _upLab;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setFont:SmallFont];
        [_tipLab setText:@"您的成交率"];
        [_tipLab setTextColor:[UIColor darkGrayColor]];
        [_tipLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _tipLab;
}

- (UILabel *)rateLab
{
    if (!_rateLab) {
        _rateLab = [[UILabel alloc] init];
        [_rateLab setFont:[UIFont systemFontOfSize:30]];
        [_rateLab setTextColor:BASELINE_COLOR];
        [_rateLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _rateLab;
}

@end
