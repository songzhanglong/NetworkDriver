//
//  ForgetPassController.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@interface ForgetPassController : BaseViewController

@property (nonatomic,strong)UITextField *accountField;
@property (nonatomic,strong)UITextField *velifyCodeField;
@property (nonatomic,strong)UITextField *pwdField;
@property (nonatomic,strong)UIImageView *accountTipImg;
@property (nonatomic,strong)UIImageView *velifyCodeTipImg;
@property (nonatomic,strong)UIImageView *pwdTipImg;
@property (nonatomic,strong)UIView *accountLine;
@property (nonatomic,strong)UIView *pwdLine;
@property (nonatomic,strong)UIView *velifyCodeLine;
@property (nonatomic,strong)UIButton *resetBtn;

@end
