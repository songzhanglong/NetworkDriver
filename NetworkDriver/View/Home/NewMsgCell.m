//
//  NewMsgCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "NewMsgCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface NewMsgCell ()

@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UIImageView *dotImg;
@property (nonatomic,strong)UIView *containerView;

@end

@implementation NewMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.containerView];
        [self.containerView addSubview:self.contentLab];
        [self.containerView addSubview:self.timeLab];
        [self.containerView addSubview:self.dotImg];
        [self.containerView addSubview:self.tipLab];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(25));
        make.right.equalTo(self.contentView.mas_right).with.offset(-25);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.dotImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.containerView);
        make.width.equalTo(@(6));
        make.height.equalTo(@(6));
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dotImg.mas_right);
        make.top.equalTo(self.dotImg.mas_bottom);
    }];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.containerView.mas_right);
        make.centerY.equalTo(self.tipLab.mas_centerY);
    }];
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).with.offset(12);
        make.left.equalTo(self.tipLab.mas_left);
        make.right.equalTo(self.containerView.mas_right).with.offset(-60);
        make.bottom.equalTo(self.containerView.mas_bottom);
    }];
}

#pragma mark - Public
- (void)resetNewMessage:(NSString *)timer Content:(NSString *)content
{
    [self.timeLab setText:timer];
    [self.contentLab setText:content];
}

#pragma mark - lazy load
- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [UIView new];
    }
    return _containerView;
}

- (UIImageView *)dotImg
{
    if (!_dotImg) {
        _dotImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor redColor] Size:CGSizeMake(6, 6)]];
        [_dotImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(6, 6)]];
        [_dotImg setBackgroundColor:[UIColor redColor]];
        _dotImg.layer.masksToBounds = YES;
        _dotImg.layer.cornerRadius = 3;
    }
    return _dotImg;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setTextColor:[UIColor blackColor]];
        [_tipLab setHighlightedTextColor:[UIColor whiteColor]];
        [_tipLab setText:@"消息提醒"];
        [_tipLab setFont:MiddleFont];
    }
    return _tipLab;
}

- (UILabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setHighlightedTextColor:[UIColor whiteColor]];
        [_timeLab setFont:MiddleFont];
    }
    return _timeLab;
}

- (UILabel *)contentLab
{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        [_contentLab setTextColor:[UIColor darkGrayColor]];
        [_contentLab setHighlightedTextColor:[UIColor whiteColor]];
        [_contentLab setFont:SmallFont];
    }
    return _contentLab;
}

@end
