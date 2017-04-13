//
//  OrderDetailBaseCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderDetailBaseCell.h"
#import <Masonry.h>
#import "LinkLocationView.h"
#import "UIColor+Hex.h"

@interface OrderDetailBaseCell ()

@property (nonatomic,strong)UIView *topContentView;
@property (nonatomic,strong)UIImageView *marginLine1;
@property (nonatomic,strong)UIImageView *getOnImg;
@property (nonatomic,strong)UIImageView *getOffImg;
@property (nonatomic,strong)LinkLocationView *linkView;

@end

@implementation OrderDetailBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self initialSubViews];
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Public
- (void)initialSubViews
{
    [self.contentView addSubview:self.topContentView];
    [self.topContentView addSubview:self.orderNumberLab];
    [self.topContentView addSubview:self.orderStateLab];
    [self.topContentView addSubview:self.marginLine1];
    [self.contentView addSubview:self.getOnImg];
    [self.contentView addSubview:self.getOnLab];
    [self.contentView addSubview:self.linkView];
    [self.contentView addSubview:self.getOffImg];
    [self.contentView addSubview:self.getOffLab];
    [self.contentView addSubview:self.marginLine];
}

- (void)initialConstraint
{
    [self.topContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(25);
        make.right.equalTo(self.contentView.mas_right).with.offset(-25);
        make.top.equalTo(@0);
        make.height.equalTo(@44);
    }];
    [self.orderNumberLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.centerY.equalTo(self.topContentView.mas_centerY);
        make.width.lessThanOrEqualTo(self.topContentView.mas_width).with.offset(-60);
    }];
    [self.orderStateLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.topContentView.mas_right);
        make.centerY.equalTo(self.topContentView.mas_centerY);
    }];
    [self.marginLine1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.left.and.bottom.equalTo(self.topContentView);
        make.height.equalTo(@1);
    }];
    [self.getOnImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topContentView.mas_left).with.offset(5);
        make.top.equalTo(self.topContentView.mas_bottom).with.offset(20);
    }];
    [self.getOnLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.getOnImg.mas_right).with.offset(20);
        make.centerY.equalTo(self.getOnImg.mas_centerY);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-25);
    }];
    [self.linkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.getOnImg.mas_bottom).with.offset(5);
        make.centerX.equalTo(self.getOnImg.mas_centerX);
    }];
    [self.getOffImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.getOnImg.mas_left);
        make.top.equalTo(self.linkView.mas_bottom).with.offset(5);
    }];
    [self.getOffLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.getOnLab.mas_left);
        make.centerY.equalTo(self.getOffImg.mas_centerY);
        make.right.lessThanOrEqualTo(self.contentView.mas_right).with.offset(-25);
    }];
    [self.marginLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.topContentView);
        make.top.equalTo(self.getOffImg.mas_bottom).with.offset(20);
        make.height.equalTo(@1);
    }];
}

#pragma mark - lazy load
- (UIView *)topContentView
{
    if (!_topContentView) {
        _topContentView = [UIView new];
    }
    return _topContentView;
}

- (UILabel *)orderNumberLab
{
    if (!_orderNumberLab) {
        _orderNumberLab = [[UILabel alloc] init];
        [_orderNumberLab setFont:MiddleFont];
        [_orderNumberLab setTextColor:[UIColor darkGrayColor]];
        [_orderNumberLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _orderNumberLab;
}

- (UILabel *)orderStateLab
{
    if (!_orderStateLab) {
        _orderStateLab = [[UILabel alloc] init];
        [_orderStateLab setFont:MiddleFont];
        [_orderStateLab setTextColor:BASELINE_COLOR];
        [_orderStateLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _orderStateLab;
}

- (UIImageView *)marginLine1
{
    if (!_marginLine1) {
        _marginLine1 = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_marginLine1 setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        _marginLine1.clipsToBounds = YES;
        _marginLine1.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _marginLine1;
}

- (UIImageView *)getOnImg
{
    if (!_getOnImg) {
        _getOnImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_up.png"]];
    }
    return _getOnImg;
}

- (UILabel *)getOnLab
{
    if (!_getOnLab) {
        _getOnLab = [[UILabel alloc] init];
        [_getOnLab setFont:MiddleFont];
        [_getOnLab setTextColor:[UIColor darkGrayColor]];
        [_getOnLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _getOnLab;
}

- (LinkLocationView *)linkView
{
    if (!_linkView) {
        _linkView = [[LinkLocationView alloc] init];
    }
    return _linkView;
}

- (UIImageView *)getOffImg
{
    if (!_getOffImg) {
        _getOffImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_down.png"]];
    }
    return _getOffImg;
}

- (UILabel *)getOffLab
{
    if (!_getOffLab) {
        _getOffLab = [[UILabel alloc] init];
        [_getOffLab setFont:MiddleFont];
        [_getOffLab setTextColor:[UIColor darkGrayColor]];
        [_getOffLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _getOffLab;
}

- (UIImageView *)marginLine
{
    if (!_marginLine) {
        _marginLine = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_marginLine setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        _marginLine.clipsToBounds = YES;
        _marginLine.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _marginLine;
}

@end
