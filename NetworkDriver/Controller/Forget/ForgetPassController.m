//
//  ForgetPassController.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ForgetPassController.h"
#import <Masonry.h>
#import "ForgetViewModel.h"
#import "IdentifierValidator.h"
#import "CTMediator+ModuleLogin.h"
#import "GlobalManager.h"
#import "NSString+Common.h"

@interface ForgetPassController()

@property (nonatomic,strong)ForgetViewModel *forgetViewModel;
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,assign)NSInteger maxSeconds;

@end

@implementation ForgetPassController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"忘记密码";
    
    [self.view addSubview:self.accountField];
    [self.view addSubview:self.velifyCodeField];
    [self.view addSubview:self.pwdField];
    [self.view addSubview:self.accountTipImg];
    [self.view addSubview:self.velifyCodeTipImg];
    [self.view addSubview:self.pwdTipImg];
    [self.view addSubview:self.accountLine];
    [self.view addSubview:self.velifyCodeLine];
    [self.view addSubview:self.pwdLine];
    [self.view addSubview:self.resetBtn];

    //initial
    [self initialConstraintsOfSubviews];
    [self initialReactiveSignal];
}

#pragma mark - apperar
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self clearTimer];
}

#pragma mark - Private methods
- (void)initialConstraintsOfSubviews
{
    //account
    [self.accountTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_right).with.multipliedBy(100.0 / 750);
        make.top.equalTo(self.view.mas_top).with.offset(80.0 * SCREEN_HEIGHT / 1334);
    }];
    [self.accountTipImg setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.accountTipImg setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountTipImg.mas_right).with.offset(32.0 * SCREEN_WIDTH / 750);
        make.right.equalTo(self.view.mas_right).with.offset(-(100.0 * SCREEN_WIDTH / 750));
        make.centerY.equalTo(self.accountTipImg.mas_centerY);
        make.height.equalTo(self.accountTipImg.mas_height);
    }];
    [self.accountLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountTipImg.mas_left).with.offset(-(8.0 * SCREEN_WIDTH / 750));
        make.top.equalTo(self.accountTipImg.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
        make.height.equalTo(@(1));
        make.right.equalTo(self.accountField.mas_right).with.offset(8.0 * SCREEN_WIDTH / 750);
    }];

    //velify code
    [self.velifyCodeTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountTipImg.mas_left);
        make.top.equalTo(self.accountLine.mas_bottom).with.offset(60.0 * SCREEN_HEIGHT / 1334);
    }];
    [self.velifyCodeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.accountField);
        make.centerY.and.height.equalTo(self.velifyCodeTipImg);
    }];
    [self.velifyCodeLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.accountLine);
        make.top.equalTo(self.velifyCodeTipImg.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
        make.height.equalTo(@(1));
    }];

    //password
    [self.pwdTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountTipImg.mas_left);
        make.top.equalTo(self.velifyCodeLine.mas_bottom).with.offset(60.0 * SCREEN_HEIGHT / 1334);
    }];
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.accountField);
        make.centerY.and.height.equalTo(self.pwdTipImg);
    }];
    [self.pwdLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.accountLine);
        make.top.equalTo(self.pwdTipImg.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
        make.height.equalTo(@(1));
    }];
    
    //login
    [self.resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.pwdLine);
        make.height.equalTo(@(96.0 * SCREEN_HEIGHT / 1334));
        make.top.equalTo(self.pwdLine.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
    }];
}

- (void)initialReactiveSignal
{
    // 给模型的属性绑定信号
    // 只要账号文本框一改变，就会给account赋值
    RAC(self.forgetViewModel.forgetInfo,account) = self.accountField.rac_textSignal;
    RAC(self.forgetViewModel.forgetInfo,pwd) = self.pwdField.rac_textSignal;
    RAC(self.forgetViewModel.forgetInfo,valifyCode) = self.velifyCodeField.rac_textSignal;
    
    @weakify(self);
    //定时监控
    [RACObserve(self.forgetViewModel.forgetInfo,account) subscribeNext:^(id x) {
        @strongify(self);
        [self resetVerilyCodeText];
    }];
    
    // 绑定登录按钮
    RAC(self.resetBtn,enabled) = self.forgetViewModel.enableResetSignal;
    
    // 验证码按钮点击
    [[(UIButton *)_velifyCodeField.rightView rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.forgetViewModel.autoCodeSignal subscribeNext:^(id x) {
            RACTupleUnpack(NSError *err,id data) = x;
            if (err) {
                [self.view makeToast:err.domain duration:1.0 position:@"center"];
            }
            else{
                NSLog(@"%@",data);
                UIButton *rightBtn = (UIButton *)self.velifyCodeField.rightView;
                rightBtn.enabled = !rightBtn.enabled;
                [rightBtn setTitle:@"请等待60s秒" forState:UIControlStateNormal];
                self.maxSeconds = 60;
                [self startTimerCreate];
            }
        }];
    }];
    
    // 监听重置按钮点击
    [[_resetBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
         @strongify(self);
         [self.forgetViewModel.resetSignal subscribeNext:^(id x) {
             RACTupleUnpack(NSError *err,id data) = x;
             if (err) {
                 [self.view makeToast:err.domain duration:1.0 position:@"center"];
             }
             else{
                 NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                 [userDefault setObject:self.accountField.text forKey:LOGIN_PHONE];
                 [userDefault setObject:[NSString md5:self.pwdField.text] forKey:LOGIN_PASS];
                 [userDefault synchronize];
                 
                 //用户信息
                 id detail = [data valueForKey:@"detail"];
                 UserDetailInfo *userDetail = [[UserDetailInfo alloc] initWithDictionary:detail error:nil];
                 [[GlobalManager shareInstance] setUserInfo:userDetail];
                [[CTMediator sharedInstance] CTMediator_rootviewControllerForSlide:YES];
             }
         }];
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
    [self.resetBtn.layer setCornerRadius:self.resetBtn.frameHeight / 2];
    //ios7需要这一句话
    [self.view layoutIfNeeded];
}

#pragma mark - timer
- (void)startTimer:(NSTimeInterval)time
{
    _maxSeconds--;
    if (_maxSeconds <= 0) {
        [self clearTimer];
    }
    [self resetVerilyCodeText];
}

- (void)resetVerilyCodeText
{
    UIButton *btn = (UIButton *)_velifyCodeField.rightView;
    [btn setTitle:((_maxSeconds >= 0) && _timer) ? [NSString stringWithFormat:@"请等待%ld秒",(long)_maxSeconds] : @"获取验证码" forState:UIControlStateNormal];
    BOOL enable = (_maxSeconds <= 0) && (_accountField.text.length && [IdentifierValidator isValidPhone:_accountField.text]);
    btn.enabled = enable;
}

- (void)clearTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)startTimerCreate
{
    [self clearTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
}

#pragma mark - lazy load
- (UITextField *)accountField
{
    if (!_accountField) {
        _accountField = [[UITextField alloc] init];
        [_accountField setFont:MiddleFont];
        _accountField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _accountField.autocorrectionType = UITextAutocorrectionTypeNo;
        _accountField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _accountField.keyboardType = UIKeyboardTypeNumberPad;
        _accountField.placeholder = @"请输入手机号码";
        UIImage *clearImg = [UIImage imageNamed:@"clearText.png"];
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setFrame:CGRectMake(0, 0, clearImg.size.width + 5, clearImg.size.height)];
        [clearBtn setImage:clearImg forState:UIControlStateNormal];
        [clearBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        _accountField.rightView = clearBtn;
        [[clearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (_accountField.text.length > 0) {
                [_accountField setText:@""];
                self.forgetViewModel.forgetInfo.account = @"";  //让self.forgetViewModel.account.account的观察者能坚挺到这个变化
                _accountField.rightViewMode = UITextFieldViewModeNever;
            }
        }];
        [_accountField.rac_textSignal subscribeNext:^(id x) {
            _accountField.rightViewMode = (_accountField.text.length > 0) ? UITextFieldViewModeWhileEditing : UITextFieldViewModeNever;
        }];
    }
    return _accountField;
}

- (UITextField *)velifyCodeField
{
    if (!_velifyCodeField) {
        _velifyCodeField = [[UITextField alloc] init];
        [_velifyCodeField setFont:MiddleFont];
        [_velifyCodeField setTranslatesAutoresizingMaskIntoConstraints:NO];
        _velifyCodeField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _velifyCodeField.autocorrectionType = UITextAutocorrectionTypeNo;
        _velifyCodeField.returnKeyType = UIReturnKeyDone;
        _velifyCodeField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _velifyCodeField.keyboardType = UIKeyboardTypeASCIICapable;
        _velifyCodeField.placeholder = @"请输入验证码";
        _velifyCodeField.rightViewMode = UITextFieldViewModeAlways;
        
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setBackgroundColor:BASELINE_COLOR];
        [rightBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [rightBtn.titleLabel setFont:MiddleFont];
        [rightBtn sizeToFit];
        CGSize size = rightBtn.frame.size;
        [rightBtn setFrame:CGRectMake(0, 0, size.width + 10, MIN(size.height + 10, self.velifyCodeTipImg.image.size.height))];
        rightBtn.layer.masksToBounds = YES;
        rightBtn.layer.cornerRadius = 5;
        _velifyCodeField.rightView = rightBtn;
    }
    return _velifyCodeField;
}

- (UITextField *)pwdField
{
    if (!_pwdField) {
        _pwdField = [[UITextField alloc] init];
        [_pwdField setFont:MiddleFont];
        [_pwdField setTranslatesAutoresizingMaskIntoConstraints:NO];
        _pwdField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _pwdField.autocorrectionType = UITextAutocorrectionTypeNo;
        _pwdField.returnKeyType = UIReturnKeyDone;
        _pwdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _pwdField.secureTextEntry = YES;
        _pwdField.keyboardType = UIKeyboardTypeASCIICapable;
        _pwdField.placeholder = @"请输入密码";
        _pwdField.rightViewMode = UITextFieldViewModeAlways;
        
        UIImage *onImg = [UIImage imageNamed:@"passOn.png"],*offImg = [UIImage imageNamed:@"passOff.png"];
        CGSize imgSize = onImg.size;
        UIButton *passBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [passBtn setFrame:CGRectMake(0, 0, imgSize.width + 5, imgSize.height)];
        [passBtn setImage:offImg forState:UIControlStateNormal];
        [passBtn setImage:onImg forState:UIControlStateSelected];
        [passBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        _pwdField.rightView = passBtn;
        [[passBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            passBtn.selected = !passBtn.selected;
            if (_pwdField.isFirstResponder) {
                NSString *tempStr = _pwdField.text;
                _pwdField.text = @"";
                _pwdField.secureTextEntry = !passBtn.selected;
                _pwdField.text = tempStr;
            }
            else{
                _pwdField.secureTextEntry = !passBtn.selected;
            }
        }];
    }
    return _pwdField;
}

- (UIImageView *)accountTipImg
{
    if (!_accountTipImg) {
        _accountTipImg = [[UIImageView alloc] init];
        [_accountTipImg setImage:[UIImage imageNamed:@"accountTip.png"]];
    }
    return _accountTipImg;
}

- (UIImageView *)velifyCodeTipImg
{
    if (!_velifyCodeTipImg) {
        _velifyCodeTipImg = [[UIImageView alloc] init];
        [_velifyCodeTipImg setImage:[UIImage imageNamed:@"unCheckbox.png"]];
    }
    return _velifyCodeTipImg;
}

- (UIImageView *)pwdTipImg
{
    if (!_pwdTipImg) {
        _pwdTipImg = [[UIImageView alloc] init];
        [_pwdTipImg setImage:[UIImage imageNamed:@"passwordTip.png"]];
    }
    return _pwdTipImg;
}

- (UIButton *)resetBtn
{
    if (!_resetBtn) {
        _resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        [_resetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_resetBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_resetBtn setBackgroundColor:BASELINE_COLOR];
        [_resetBtn.layer setMasksToBounds:YES];
        [_resetBtn.titleLabel setFont:MiddleFont];
    }
    return _resetBtn;
}

- (ForgetViewModel *)forgetViewModel
{
    if (!_forgetViewModel) {
        _forgetViewModel = [[ForgetViewModel alloc] init];
    }
    return _forgetViewModel;
}

- (UIView *)accountLine
{
    if (!_accountLine) {
        _accountLine = [[UIView alloc] init];
        [_accountLine setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _accountLine;
}

- (UIView *)pwdLine
{
    if (!_pwdLine) {
        _pwdLine = [[UIView alloc] init];
        [_pwdLine setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _pwdLine;
}

- (UIView *)velifyCodeLine
{
    if (!_velifyCodeLine) {
        _velifyCodeLine = [[UIView alloc] init];
        [_velifyCodeLine setBackgroundColor:[UIColor lightGrayColor]];
    }
    return _velifyCodeLine;
}

@end

