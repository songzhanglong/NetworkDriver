//
//  OrderPriceEditCell.m
//  NetworkDriver
//
//  Created by szl on 16/10/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPriceEditCell.h"
#import <Masonry.h>

@interface OrderPriceEditCell ()

@property (nonatomic,strong)UILabel *tipLab;

@end

@implementation OrderPriceEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
        self.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        
        [self.contentView addSubview:self.leftLab];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.tipLab];
        
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
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-35);
        make.centerY.equalTo(self.contentView.mas_centerY);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.tipLab.mas_left).with.offset(-2);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.height.equalTo(@20);
        make.width.equalTo(@50);
    }];
    
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

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] init];
        [_textField setFont:MiddleFont];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.keyboardType = UIKeyboardTypeNumberPad;
        _textField.layer.masksToBounds = YES;
        _textField.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textField.layer.borderWidth = 1.0;
        //_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _textField;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setText:@"元"];
        [_tipLab setTextColor:[UIColor blackColor]];
        [_tipLab setFont:MiddleFont];
    }
    return _tipLab;
}

@end
