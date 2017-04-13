//
//  AcceptCarCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AcceptCarCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"
#import "GlobalManager.h"

@interface AcceptCarCell ()

@property (nonatomic,strong)UIImageView *boundaryLine;

@end

@implementation AcceptCarCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.contentView addSubview:self.orderNum];
        [self.contentView addSubview:self.boundaryLine];
        [self.contentView addSubview:self.closeRate];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.orderNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.centerY.equalTo(self.contentView);
    }];
    [self.boundaryLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.orderNum.mas_right);
        make.top.equalTo(@(8));
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-8);
        make.width.equalTo(@(1));
    }];
    [self.closeRate mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.boundaryLine.mas_right);
        make.centerY.and.width.equalTo(self.orderNum);
        make.right.equalTo(self.contentView.mas_right);
    }];
}

#pragma mark - Public
- (void)resetDriverOrderCount
{
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    
    //currentOrders
    NSInteger number = [detailInfo.orderCount.currentOrders integerValue];
    NSString *tmpStr = (number == 0) ? @"－－" : [[NSNumber numberWithInteger:number] stringValue];
    NSString *numStr = [tmpStr stringByAppendingString:@"\n今日接单数"];
    NSRange range = NSMakeRange(0, tmpStr.length);
    NSMutableAttributedString *attrNum = [[NSMutableAttributedString alloc] initWithString:numStr];
    [attrNum addAttribute:NSForegroundColorAttributeName value:BASELINE_COLOR range:range];
    [attrNum addAttribute:NSFontAttributeName value:BigFont range:range];
    
    //rate
    NSString *rate = detailInfo.orderCount.currentFinishRate ?: @"－－";
    NSString *rateStr = [rate stringByAppendingString:@"\n今日成交率"];
    range = NSMakeRange(0, rate.length);
    NSMutableAttributedString *attrRate = [[NSMutableAttributedString alloc] initWithString:rateStr];
    [attrRate addAttribute:NSForegroundColorAttributeName value:BASELINE_COLOR range:range];
    [attrRate addAttribute:NSFontAttributeName value:BigFont range:range];
    
    [self.orderNum setAttributedText:attrNum];
    [self.closeRate setAttributedText:attrRate];
}

#pragma mark - lazy load
- (UIImageView *)boundaryLine
{
    if (!_boundaryLine) {
        _boundaryLine = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(1, 100)]];
        [_boundaryLine setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(1, 100)]];
        _boundaryLine.clipsToBounds = YES;
        _boundaryLine.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _boundaryLine;
}

- (UILabel *)orderNum
{
    if (!_orderNum) {
        _orderNum = [[UILabel alloc] init];
        [_orderNum setTextColor:[UIColor darkGrayColor]];
        [_orderNum setNumberOfLines:0];
        [_orderNum setTextAlignment:NSTextAlignmentCenter];
        [_orderNum setFont:MiddleFont];
    }
    return _orderNum;
}

- (UILabel *)closeRate
{
    if (!_closeRate) {
        _closeRate = [[UILabel alloc] init];
        [_closeRate setTextColor:[UIColor darkGrayColor]];
        [_closeRate setNumberOfLines:0];
        [_closeRate setTextAlignment:NSTextAlignmentCenter];
        [_closeRate setFont:MiddleFont];
    }
    return _closeRate;
}

@end
