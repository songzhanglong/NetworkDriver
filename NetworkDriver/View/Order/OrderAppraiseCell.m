//
//  OrderAppraiseCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderAppraiseCell.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface OrderAppraiseCell ()

@property (nonatomic,strong)UIView *upBackView;
@property (nonatomic,strong)UIView *downBackView;

@end

@implementation OrderAppraiseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.upBackView];
        [self.upBackView addSubview:self.tipLab];
        [self.upBackView addSubview:self.markScore];
//        [self.contentView addSubview:self.downBackView];
//        [self.downBackView addSubview:self.marginLineImg];
//        [self.downBackView addSubview:self.contentLab];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private
- (void)initialConstraint
{
//    [self.downBackView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.contentView.mas_bottom);
//        make.height.equalTo(@44);
//        make.left.equalTo(@25);
//        make.right.equalTo(self.contentView.mas_right).with.offset(-25);
//    }];
//    [self.marginLineImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.and.top.and.right.equalTo(self.downBackView);
//        make.height.equalTo(@1);
//    }];
//    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.and.centerY.equalTo(self.downBackView);
//    }];
    [self.upBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        //make.centerY.equalTo(self.contentView.mas_centerY).with.offset(-22);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
    }];
    [self.markScore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).with.offset(5);
        make.left.equalTo(@0);
        make.centerX.equalTo(self.tipLab.mas_centerX);
        make.right.equalTo(self.upBackView.mas_right);
        make.bottom.equalTo(self.upBackView.mas_bottom);
    }];
}

#pragma mark - lazy load
- (UIView *)upBackView
{
    if (!_upBackView) {
        _upBackView = [UIView new];
    }
    return _upBackView;
}

- (UIView *)downBackView
{
    if (!_downBackView) {
        _downBackView = [UIView new];
    }
    return _downBackView;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setFont:SmallFont];
        [_tipLab setText:@"对我的评价"];
        [_tipLab setTextColor:[UIColor darkGrayColor]];
        [_tipLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _tipLab;
}

- (MarkScore *)markScore
{
    if (!_markScore) {
        _markScore = [[MarkScore alloc] initWithMargin:5 Name:@"gradeStarN.png" Hli:@"gradeStarH.png"];
        _markScore.userInteractionEnabled = NO;
    }
    return _markScore;
}

- (UIImageView *)marginLineImg
{
    if (!_marginLineImg) {
        _marginLineImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_marginLineImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        _marginLineImg.clipsToBounds = YES;
        _marginLineImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _marginLineImg;
}

- (UILabel *)contentLab
{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        [_contentLab setFont:MiddleFont];
        [_contentLab setText:@"司机师傅很不错，赞一个"];
        [_contentLab setTextColor:[UIColor darkGrayColor]];
        [_contentLab setHighlightedTextColor:[UIColor whiteColor]];
    }
    return _contentLab;
}

@end
