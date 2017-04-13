//
//  LoginVC.h
//  CallCar
//
//  Created by 闫坑坑 on 16/8/31.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (nonatomic,strong)UITextField *accountField;
@property (nonatomic,strong)UITextField *pwdField;
@property (nonatomic,strong)UIImageView *accountTipImg;
@property (nonatomic,strong)UIImageView *pwdTipImg;
@property (nonatomic,strong)UIButton *forgetBtn;
@property (nonatomic,strong)UIButton *loginBtn;
@property (nonatomic,strong)UIView *accountLine;
@property (nonatomic,strong)UIView *pwdLine;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIButton *checkBtn;
@property (nonatomic,strong)UILabel *agreeLab;
@property (nonatomic,strong)UIButton *agreeBtn;

@end
