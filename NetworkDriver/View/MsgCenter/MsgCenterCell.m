//
//  MsgCenterCell.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MsgCenterCell.h"
#import "MsgItem.h"
#import <Masonry.h>
#import "UIColor+Hex.h"

@interface MsgCenterCell ()

@property (nonatomic,strong)UIImageView *tipImg;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *timeLab;
@property (nonatomic,strong)UIImageView *seperateImg;
@property (nonatomic,strong)UILabel *contentLab;

@end

@implementation MsgCenterCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.tipImg];
        [self.contentView addSubview:self.tipLab];
        [self.contentView addSubview:self.timeLab];
        [self.contentView addSubview:self.seperateImg];
        [self.contentView addSubview:self.contentLab];
        
        [self initialConstraint];
    }
    return self;
}

#pragma mark - Private methods
- (void)initialConstraint
{
    [self.tipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(25));
        make.top.equalTo(@(20));
    }];
    
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.tipImg.mas_centerY);
        make.left.equalTo(self.tipImg.mas_right).with.offset(2);
    }];
    
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-25);
        make.centerY.equalTo(self.tipLab.mas_centerY);
    }];
    
    [self.seperateImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tipLab.mas_bottom).with.offset(10);
        make.left.equalTo(self.tipImg.mas_left);
        make.right.equalTo(self.timeLab.mas_right);
        make.height.equalTo(@1);
    }];
    
    [self.contentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.seperateImg);
        make.top.equalTo(self.seperateImg.mas_bottom).with.offset(10);
        make.bottom.equalTo(self.contentView.mas_bottom).with.offset(-20);
    }];
}

#pragma mark - Public methods
- (void)resetMsgItem:(MsgItem *)item
{
    [_timeLab setText:item.time];
    [_contentLab setText:item.msg];
}

#pragma mark - lazy load
- (UIImageView *)tipImg
{
    if (!_tipImg) {
        _tipImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"msgCenterTip.png"]];
    }
    return _tipImg;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setTextColor:[UIColor darkGrayColor]];
        [_tipLab setHighlightedTextColor:[UIColor whiteColor]];
        [_tipLab setText:@"消息提醒"];
        [_tipLab setFont:SmallFont];
    }
    return _tipLab;
}

- (UILabel *)timeLab
{
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        [_timeLab setTextColor:[UIColor darkGrayColor]];
        [_timeLab setHighlightedTextColor:[UIColor whiteColor]];
        [_timeLab setFont:SmallFont];
    }
    return _timeLab;
}

- (UIImageView *)seperateImg
{
    if (!_seperateImg) {
        _seperateImg = [[UIImageView alloc] initWithImage:[UIColor createImageWithColor:[UIColor lightGrayColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        [_seperateImg setHighlightedImage:[UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(SCREEN_WIDTH, 1)]];
        _seperateImg.clipsToBounds = YES;
        _seperateImg.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _seperateImg;
}

- (UILabel *)contentLab
{
    if (!_contentLab) {
        _contentLab = [[UILabel alloc] init];
        [_contentLab setTextColor:[UIColor darkGrayColor]];
        [_contentLab setHighlightedTextColor:[UIColor whiteColor]];
        [_contentLab setNumberOfLines:0];
        [_contentLab setFont:MiddleFont];
        // 计算UILabel的preferredMaxLayoutWidth值，多行时必须设置这个值，否则系统无法决定Label的宽度
        CGFloat preferredMaxWidth = [UIScreen mainScreen].bounds.size.width - 50; // 44 = avatar宽度，4 * 3为padding
        _contentLab.preferredMaxLayoutWidth = preferredMaxWidth;    // 多行时必须设置
    }
    return _contentLab;
}

@end
