//
//  ForgetViewModel.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "ForgetViewModel.h"
#import "IdentifierValidator.h"
#import "HttpClient.h"
#import "NSString+Common.h"
#import <IQKeyboardManager.h>

@implementation ForgetViewModel

- (instancetype)init
{
    if (self = [super init]) {
        [self initialBind];
    }
    return self;
}

// 初始化绑定
- (void)initialBind{
    // 监听账号的属性值改变，把他们聚合成一个信号
    _enableResetSignal = [RACSignal combineLatest:@[RACObserve(self.forgetInfo, account),RACObserve(self.forgetInfo, pwd),RACObserve(self.forgetInfo, valifyCode)] reduce:^id(NSString *account,NSString *pwd,NSString *valifyCode){
        return @((valifyCode.length >= 4) && (pwd.length >= 6) && account.length && [IdentifierValidator isValidPhone:account]);
    }];
    
    //处理验证码业务逻辑
    _autoCodeSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        
        //弹出提示
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        // 加一层蒙版
        hud.dimBackground = YES;
        hud.labelText = @"正在获取...";
        
        //参数请求
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSDictionary *dic = @{@"cmd":@"queryAuthCode",@"token":@"",@"version":app_Version,@"params":@{@"mobile":self.forgetInfo.account,@"appName":@"driver"}};
        dic = [NSString convertDicToStr:dic];
        NSURLSessionDataTask *dataTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryAuthCode"] parameters:dic complateBlcok:^(NSError *error, id data) {
            [MBProgressHUD hideHUDForView:window animated:YES];
            [subscriber sendNext:RACTuplePack(error,data)];
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
    
    // 处理修改密码业务逻辑
    _resetSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        //弹出提示
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        // 加一层蒙版
        hud.dimBackground = YES;
        hud.labelText = @"正在重置...";
        
        //参数请求
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSDictionary *dic = @{@"cmd":@"forgetPassword",@"token":@"",@"version":app_Version,@"params":@{@"userName":self.forgetInfo.account,@"sysType":@"6",@"password":[NSString md5:self.forgetInfo.pwd],@"authCode":self.forgetInfo.valifyCode}};
        dic = [NSString convertDicToStr:dic];
        NSURLSessionDataTask *dataTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"forgetPassword"] parameters:dic complateBlcok:^(NSError *error, id data) {
            [MBProgressHUD hideHUDForView:window animated:YES];
            [subscriber sendNext:RACTuplePack(error,data)];
            [subscriber sendCompleted];
        }];
        return [RACDisposable disposableWithBlock:^{
            [dataTask cancel];
        }];
    }];
}

#pragma mark - lazy load
- (ForgetInfo *)forgetInfo
{
    if (!_forgetInfo) {
        _forgetInfo = [[ForgetInfo alloc] init];
    }
    return _forgetInfo;
}

@end
