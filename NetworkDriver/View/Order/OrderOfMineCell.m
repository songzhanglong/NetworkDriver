//
//  OrderOfMineCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderOfMineCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"
#import "OrderInformation.h"

@interface OrderOfMineCell ()

@property (nonatomic,strong)UILabel *orderLab;
@property (nonatomic,strong)UIImageView *veriticalLine;
@property (nonatomic,strong)UILabel *priceLab;
@property (nonatomic,strong)UILabel *stateLab;
@property (nonatomic,strong)UIImageView *horizontalLine;
@property (nonatomic,strong)UIImageView *startImg;
@property (nonatomic,strong)UILabel *startLab;
@property (nonatomic,strong)UIImageView *endImg;
@property (nonatomic,strong)UILabel *endLab;
@property (nonatomic,strong)UIImageView *bottomImg;
@property (nonatomic,strong)MASConstraint *heightConstraint;

@end

@implementation OrderOfMineCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.orderLab];
        [self.contentView addSubview:self.veriticalLine];
        [self.contentView addSubview:self.priceLab];
        [self.contentView addSubview:self.stateLab];
        [self.contentView addSubview:self.horizontalLine];
        [self.contentView addSubview:self.startImg];
        [self.contentView addSubview:self.startLab];
        [self.contentView addSubview:self.endImg];
        [self.contentView addSubview:self.endLab];
        [self.contentView addSubview:self.bottomImg];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.orderLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@25);
        make.top.equalTo(@15);
    }];
    [self.veriticalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.orderLab.mas_right).with.offset(5);
        make.centerY.equalTo(self.orderLab.mas_centerY);
    }];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.veriticalLine.mas_right).with.offset(5);
        make.centerY.equalTo(self.veriticalLine.mas_centerY);
    }];
    [self.stateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-25);
        make.centerY.equalTo(self.orderLab.mas_centerY);
    }];
    [self.horizontalLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.orderLab.mas_left);
        make.right.equalTo(self.stateLab.mas_right);
        make.height.equalTo(@1);
        make.top.equalTo(self.orderLab.mas_bottom).with.offset(15);
    }];
    [self.startImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.horizontalLine.mas_bottom).with.offset(15);
        make.left.equalTo(self.horizontalLine.mas_left).with.offset(2);
    }];
    [self.startLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startImg.mas_right).with.offset(20);
        make.centerY.equalTo(self.startImg.mas_centerY);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-25);
    }];
    [self.endImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startImg.mas_left);
        make.top.equalTo(self.startImg.mas_bottom).with.offset(8);
    }];
    [self.endLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startLab.mas_left);
        make.centerY.equalTo(self.endImg.mas_centerY);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-25);
    }];
    [self.bottomImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.contentView);
        make.top.equalTo(self.endImg.mas_bottom).with.offset(15);
        self.heightConstraint = make.height.equalTo(@12);
        make.bottom.equalTo(self.contentView.mas_bottom);
    }];
}

#pragma mark - Public
- (void)setupData:(id)data Last:(BOOL)lastRow
{
    OrderInformation *orderInfo = (OrderInformation *)data;
    //[_orderLab setText:[[orderInfo.applyTime componentsSeparatedByString:@" "] lastObject]];
    NSString *orderNo = orderInfo.orderNo ?: @"";
    if (orderNo.length > 8) {
        orderNo = [orderNo substringFromIndex:orderNo.length - 8];
    }
    
    [_orderLab setText:[@"订单号:" stringByAppendingString:orderNo]];
    if (orderInfo.cost.floatValue > 0) {
        NSString *price = [[orderInfo.cost stringValue] stringByAppendingString:@"元"];
        [_priceLab setText:price];
        self.veriticalLine.hidden = NO;
        self.priceLab.hidden = NO;
    }
    else{
        self.veriticalLine.hidden = YES;
        self.priceLab.hidden = YES;
    }

    //订单状态,0订单没人抢已到期 -1司机未接单 1抢单中 2取消叫车 3抢单完成(已接单) 4乘客取消行程 5未计费前司机取消 51 接乘客 6计费中 9计费完成 11付款已完成 12付款已完成且评价
    NSString *str = nil;
    NSInteger status = [orderInfo.status integerValue];
    if (status == 0) {
        str = @"已过期";
    }
    else if (status == -1)
    {
        str = @"未接单";
    }
    else if (status == 1)
    {
        str = @"抢单中";
    }
    else if (status == 2 || status == 4)
    {
        str = @"取消叫车";
    }
    else if (status == 3)
    {
        str = @"已接单";
    }
    else if (status == 5)
    {
        str = @"申请改派";
    }
    else if (status == 51)
    {
        str = @"接乘客";
    }
    else if (status == 6)
    {
        str = @"计费中";
    }
    else if (status == 9)
    {
        str = @"计费完成";
    }
    else if (status == 11 || status == 12)
    {
        str = @"已完成";
    }
    [_stateLab setText:str];
    
    NSString *fromAddr = (orderInfo.startTime.length > 0) ? [[[orderInfo.startTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:orderInfo.fromAddr]] : orderInfo.fromAddr;
    NSString *toAddr = (orderInfo.arriveTime.length > 0) ? [[[orderInfo.arriveTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:orderInfo.toAddr]] : orderInfo.toAddr;
    [_startLab setText:fromAddr];
    [_endLab setText:toAddr];
    self.heightConstraint.equalTo(@(lastRow ? 0 : 12));
    
}

#pragma mark - lazy load
- (UILabel *)orderLab
{
    if (!_orderLab) {
        _orderLab = [[UILabel alloc] init];
        [_orderLab setFont:MiddleFont];
        [_orderLab setTextColor:[UIColor darkGrayColor]];
        [_orderLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _orderLab;
}

- (UIImageView *)veriticalLine
{
    if (!_veriticalLine) {
        _veriticalLine = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(1, 14)]];
        [_veriticalLine setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(1, 14)]];
    }
    return _veriticalLine;
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

- (UILabel *)stateLab
{
    if (!_stateLab) {
        _stateLab = [[UILabel alloc] init];
        [_stateLab setFont:MiddleFont];
        [_stateLab setTextColor:BASELINE_COLOR];
        [_stateLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _stateLab;
}

- (UIImageView *)horizontalLine
{
    if (!_horizontalLine) {
        _horizontalLine = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH - 50, 1)]];
        [_horizontalLine setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH - 50, 1)]];
        _horizontalLine.clipsToBounds = YES;
        _horizontalLine.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _horizontalLine;
}

- (UIImageView *)startImg
{
    if (!_startImg) {
        _startImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_up.png"]];
    }
    return _startImg;
}

- (UILabel *)startLab
{
    if (!_startLab) {
        _startLab = [[UILabel alloc] init];
        [_startLab setFont:MiddleFont];
        [_startLab setTextColor:[UIColor darkGrayColor]];
        [_startLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _startLab;
}

- (UIImageView *)endImg
{
    if (!_endImg) {
        _endImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_down.png"]];
    }
    return _endImg;
}

- (UILabel *)endLab
{
    if (!_endLab) {
        _endLab = [[UILabel alloc] init];
        [_endLab setFont:MiddleFont];
        [_endLab setTextColor:[UIColor darkGrayColor]];
        [_endLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _endLab;
}

- (UIImageView *)bottomImg
{
    if (!_bottomImg) {
        _bottomImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:rgba(236, 236, 236, 1) Size:CGSizeMake(SCREEN_WIDTH, 12)]];
        //[_bottomImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 12)]];
        _bottomImg.clipsToBounds = YES;
        _bottomImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _bottomImg;
}

@end
