//
//  LoginViewModel.h
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Account.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface LoginViewModel : NSObject

@property (nonatomic,strong)Account *account;

// 是否允许登录的信号
@property (nonatomic, strong, readonly) RACSignal *enableLoginSignal;

@property (nonatomic, strong, readonly) RACSignal *loginSignal;

@end
