//
//  LaunchViewController.m
//  TYSociety
//
//  Created by szl on 16/8/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LaunchViewController.h"
#import <Masonry.h>
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "CTMediator+ModuleLogin.h"

@interface LaunchViewController ()

@property (nonatomic,strong)UIImageView *contentImg;

@end

@implementation LaunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.contentImg];
    [_contentImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.top.and.bottom.equalTo(self.view);
    }];
    
    [self autoLoginRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 登录完成
- (void)autoLoginRequest
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *account = [userDef valueForKey:LOGIN_PHONE],*password = [userDef valueForKey:LOGIN_PASS];
    NSDictionary *dic = @{@"cmd":@"login",@"token":@"",@"version":app_Version,@"params":@{@"userName":account,@"password":password,@"sysType":@"6",@"deviceProduct":[UIDevice currentDevice].model}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"login"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf autoLoginRequestFinish:error Data:data];
        });
    }];
}

- (void)autoLoginRequestFinish:(NSError *)error Data:(id)data
{
    self.sessionTask = nil;
    if (error == nil) {
        //用户信息
        id detail = [data valueForKey:@"detail"];
        UserDetailInfo *userDetail = [[UserDetailInfo alloc] initWithDictionary:detail error:nil];
        [[GlobalManager shareInstance] setUserInfo:userDetail];
        [[CTMediator sharedInstance] CTMediator_rootviewControllerForSlide:YES];
    }
    else{
        [[CTMediator sharedInstance] CTMediator_rootviewControllerForLogin:NO];
    }
}

#pragma mark - status
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - lazy load
- (UIImageView *)contentImg
{
    if (!_contentImg) {
        
        NSString *imgName = iPhone4 ? @"960" : (iPhone5 ? @"1136" : (iPhone6 ? @"1334" : @"2208"));
        _contentImg = [[UIImageView alloc] initWithImage:CREATE_IMG(imgName)];
    }
    return _contentImg;
}

@end
