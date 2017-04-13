//
//  LoginVC.m
//  CallCar
//
//  Created by 闫坑坑 on 16/8/31.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LoginViewController.h"
#import <Masonry.h>
#import "LoginViewModel.h"
#import "CTMediator+ModuleLogin.h"
#import "CTMediator+ModuleWeb.h"
#import "GlobalManager.h"
#import "NSString+Common.h"

@interface LoginViewController ()

@property (nonatomic,strong)LoginViewModel *loginViewModel;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"登录";
    [self.view addSubview:self.accountField];
    [self.view addSubview:self.pwdField];
    [self.view addSubview:self.accountTipImg];
    [self.view addSubview:self.pwdTipImg];
    [self.view addSubview:self.forgetBtn];
    [self.view addSubview:self.loginBtn];
    [self.view addSubview:self.accountLine];
    [self.view addSubview:self.pwdLine];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.checkBtn];
    [self.bottomView addSubview:self.agreeLab];
    [self.bottomView addSubview:self.agreeBtn];
    
    //initial
    [self initialConstraintsOfSubviews];
    [self initialReactiveSignal];
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
    //password
    [self.pwdTipImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountTipImg.mas_left);
        make.top.equalTo(self.accountLine.mas_bottom).with.offset(60.0 * SCREEN_HEIGHT / 1334);
    }];
    [self.pwdTipImg setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.pwdTipImg setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.pwdField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountField.mas_left);
        make.right.equalTo(self.accountField.mas_right);
        make.centerY.equalTo(self.pwdTipImg.mas_centerY);
        make.height.equalTo(self.pwdTipImg.mas_height);
    }];
    [self.pwdLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.accountLine.mas_left);
        make.top.equalTo(self.pwdTipImg.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
        make.height.equalTo(@(1));
        make.right.equalTo(self.accountLine.mas_right);
    }];
    //forget
    [self.forgetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.pwdLine.mas_right);
        make.top.equalTo(self.pwdLine.mas_bottom).with.offset(28.0 * SCREEN_HEIGHT / 1334);
    }];

    //login
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pwdLine.mas_left);
        make.right.equalTo(self.pwdLine.mas_right);
        make.height.equalTo(@(96.0 * SCREEN_HEIGHT / 1334));
        make.top.equalTo(self.forgetBtn.mas_bottom).with.offset(40.0 * SCREEN_HEIGHT / 1334);
    }];
    //bottom
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-10);
    }];
    [self.checkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bottomView.mas_bottom);
        make.left.equalTo(self.bottomView.mas_left);
        make.top.equalTo(self.bottomView.mas_top);
    }];
    [self.agreeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.checkBtn.mas_right).with.offset(2);
        make.centerY.equalTo(self.checkBtn.mas_centerY);
    }];
    [self.agreeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.checkBtn.mas_centerY);
        make.left.equalTo(self.agreeLab.mas_right);
        make.right.equalTo(self.bottomView.mas_right);
    }];
}

- (void)initialReactiveSignal
{
    // 给模型的属性绑定信号
    // 只要账号文本框一改变，就会给account赋值
    RAC(self.loginViewModel.account,account) = self.accountField.rac_textSignal;
    RAC(self.loginViewModel.account,pwd) = self.pwdField.rac_textSignal;
    RAC(self.loginViewModel.account,selected) = RACObserve(self.checkBtn, selected);
    
    // 绑定登录按钮
    RAC(self.loginBtn,enabled) = self.loginViewModel.enableLoginSignal;
    
    // 监听登录按钮点击
    @weakify(self);
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.loginViewModel.loginSignal subscribeNext:^(id x) {
            RACTupleUnpack(NSError *err,id data) = x;
            //NSLog(@"%@,%@",err.domain,data);
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
    [[_forgetBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForForget];
        [self.navigationController pushViewController:controller animated:YES];
    }];
    //agreement
    [[_checkBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        _checkBtn.selected = !_checkBtn.selected;
    }];
    //Cooperation
    [[_agreeBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        NSString *driver_yhxy = [GlobalManager shareInstance].appInit.ecex_yhxy;
        if ([driver_yhxy length] == 0) {
            [self.view makeToast:@"应用初始化失败，请稍后再试" duration:1.0 position:@"center"];
        }
        else{
            UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForWeb:driver_yhxy];
            [self.navigationController pushViewController:controller animated:YES];
        }
        
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    
    [self.loginBtn.layer setCornerRadius:self.loginBtn.frameHeight / 2];
    //ios7需要这一句话
    [self.view layoutIfNeeded];
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
        _accountField.text = [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_PHONE];
        UIImage *clearImg = [UIImage imageNamed:@"clearText.png"];
        UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearBtn setFrame:CGRectMake(0, 0, clearImg.size.width + 5, clearImg.size.height)];
        [clearBtn setImage:clearImg forState:UIControlStateNormal];
        [clearBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        _accountField.rightView = clearBtn;
        [[clearBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            if (_accountField.text.length > 0) {
                [_accountField setText:@""];
                self.loginViewModel.account.account = @"";  //让self.loginViewModel.account.account的观察者能坚挺到这个变化
                _accountField.rightViewMode = UITextFieldViewModeNever;
            }
        }];
        [_accountField.rac_textSignal subscribeNext:^(id x) {
            _accountField.rightViewMode = (_accountField.text.length > 0) ? UITextFieldViewModeWhileEditing : UITextFieldViewModeNever;
        }];
    }
    return _accountField;
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

- (UIImageView *)pwdTipImg
{
    if (!_pwdTipImg) {
        _pwdTipImg = [[UIImageView alloc] init];
        [_pwdTipImg setImage:[UIImage imageNamed:@"passwordTip.png"]];
    }
    return _pwdTipImg;
}

- (UIButton *)forgetBtn
{
    if (!_forgetBtn) {
        _forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgetBtn setTitle:@"忘记密码" forState:UIControlStateNormal];
        [_forgetBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_forgetBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [_forgetBtn.titleLabel setFont:MiddleFont];
        [_forgetBtn setHidden:YES];
    }
    return _forgetBtn;
}

- (UIButton *)loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"登录" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_loginBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_loginBtn setBackgroundColor:BASELINE_COLOR];
        [_loginBtn.layer setMasksToBounds:YES];
        [_loginBtn.titleLabel setFont:MiddleFont];
    }
    return _loginBtn;
}

- (LoginViewModel *)loginViewModel
{
    if (!_loginViewModel) {
        _loginViewModel = [[LoginViewModel alloc] init];
    }
    return _loginViewModel;
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

- (UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UIButton *)checkBtn
{
    if (!_checkBtn) {
        _checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn setImage:[UIImage imageNamed:@"unCheckbox.png"] forState:UIControlStateNormal];
        [_checkBtn setImage:[UIImage imageNamed:@"checkbox.png"] forState:UIControlStateSelected];
        _checkBtn.selected = YES;
    }
    return _checkBtn;
}

- (UILabel *)agreeLab
{
    if (!_agreeLab) {
        _agreeLab = [[UILabel alloc] init];
        [_agreeLab setFont:MiddleFont];
        [_agreeLab setText:@"我已阅读并同意"];
    }
    return _agreeLab;
}

- (UIButton *)agreeBtn
{
    if (!_agreeBtn) {
        _agreeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeBtn setTitle:@"e车易行服务条款" forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:BASELINE_COLOR forState:UIControlStateNormal];
        [_agreeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [_agreeBtn.titleLabel setFont:MiddleFont];
    }
    return _agreeBtn;
}

@end
