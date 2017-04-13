//
//  OrderRefuseCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderRefuseCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface OrderRefuseCell ()

@property (nonatomic,strong)UIImageView *marginImg;

@end

@implementation OrderRefuseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.reasonLab];
        [self.contentView addSubview:self.checkBtn];
        [self.contentView addSubview:self.marginImg];
        
        [self initialConstraint];
    }
    return self;
}

- (void)initialConstraint
{
    [self.reasonLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).with.offset(15);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
    }];
    [self.marginImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@1);
        make.left.equalTo(self.reasonLab.mas_left);
        make.right.equalTo(self.checkBtn.mas_right);
    }];
}

#pragma mark - lazy load
- (UILabel *)reasonLab
{
    if (!_reasonLab) {
        _reasonLab = [[UILabel alloc] init];
        [_reasonLab setFont:MiddleFont];
        [_reasonLab setTextColor:[UIColor darkGrayColor]];
        [_reasonLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _reasonLab;
}

- (UIButton *)checkBtn
{
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:[UIImage imageNamed:@"unCheckbox.png"] forState:UIControlStateNormal];
        [_checkBtn setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateSelected];
    }
    return _checkBtn;
}

- (UIImageView *)marginImg
{
    if (!_marginImg) {
        _marginImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:rgba(236, 236, 236, 1) Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_marginImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        _marginImg.clipsToBounds = YES;
        _marginImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _marginImg;
}

@end
