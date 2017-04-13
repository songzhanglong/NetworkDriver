//
//  OrderWaitPassengerCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderWaitPassengerCell.h"
#import <Masonry.h>

@implementation OrderWaitPassengerCell

#pragma mark - Public
- (void)initialSubViews
{
    [super initialSubViews];
    [self.contentView addSubview:self.routeLab];
}

- (void)initialConstraint
{
    [super initialConstraint];
    [self.routeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.marginLine.mas_bottom).with.offset(20);
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-20);
    }];
}

#pragma mark - lazy load
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

@end
