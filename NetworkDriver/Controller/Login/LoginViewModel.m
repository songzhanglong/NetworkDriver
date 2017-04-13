//
//  LoginViewModel.m
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LoginViewModel.h"
#import "IdentifierValidator.h"
#import "HttpClient.h"
#import "NSString+Common.h"
#import <IQKeyboardManager.h>

@implementation LoginViewModel

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
    _enableLoginSignal = [RACSignal combineLatest:@[RACObserve(self.account, account),RACObserve(self.account, pwd),RACObserve(self.account, selected)] reduce:^id(NSString *account,NSString *pwd,NSNumber *selected){
        return @([selected boolValue] && (pwd.length >= 6) && account.length && [IdentifierValidator isValidPhone:account]);
    }];
    
    // 处理登录业务逻辑
    _loginSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        //弹出提示
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
        // 加一层蒙版
        hud.dimBackground = YES;
        hud.labelText = @"正在登录...";
        
        //参数请求
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSDictionary *dic = @{@"cmd":@"login",@"token":@"",@"version":app_Version,@"params":@{@"userName":self.account.account,@"password":[NSString md5:self.account.pwd],@"sysType":@"6",@"deviceProduct":[UIDevice currentDevice].model}};
        dic = [NSString convertDicToStr:dic];
        NSURLSessionDataTask *dataTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"login"] parameters:dic complateBlcok:^(NSError *error, id data) {
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
- (Account *)account
{
    if (!_account) {
        _account = [[Account alloc] init];
    }
    return _account;
}

@end
