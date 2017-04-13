//
//  OrderPriceViewCell.m
//  NetworkDriver
//
//  Created by szl on 16/10/14.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPriceViewCell.h"
#import "UIColor+Hex.h"
#import <Masonry.h>

@interface OrderPriceViewCell ()

@property (nonatomic,strong)UILabel *leftLab;
@property (nonatomic,strong)UILabel *rightLab;
@property (nonatomic,strong)UIImageView *imgView;

@end

@implementation OrderPriceViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.rightLab];
        [self.contentView addSubview:self.imgView];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private Methods
- (void)initialConstraint{
    //duration
    [self.leftLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.equalTo(@35);
    }];
    [self.rightLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-35);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.left.greaterThanOrEqualTo(self.leftLab.mas_right).with.offset(5);
        make.right.lessThanOrEqualTo(self.rightLab.mas_left).with.offset(-5);
        make.height.equalTo(@1);
    }];
}

- (void)resetLeftTip:(NSString *)tip Price:(NSString *)price
{
    [self.leftLab setText:tip];
    [self.rightLab setText:price];
}

#pragma mark - lazy load
- (UILabel *)leftLab
{
    if (!_leftLab) {
        _leftLab = [[UILabel alloc] init];
        [_leftLab setFont:MiddleFont];
        [_leftLab setTextColor:[UIColor darkGrayColor]];
        [_leftLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _leftLab;
}

- (UILabel *)rightLab
{
    if (!_rightLab) {
        _rightLab = [[UILabel alloc] init];
        [_rightLab setFont:MiddleFont];
        [_rightLab setTextColor:[UIColor darkGrayColor]];
        [_rightLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _rightLab;
}

- (UIImageView *)imgView
{
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_imgView setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_imgView setClipsToBounds:YES];
        [_imgView setContentMode:UIViewContentModeScaleAspectFill];
    }
    return _imgView;
}

@end
