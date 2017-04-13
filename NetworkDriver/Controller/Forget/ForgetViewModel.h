//
//  ForgetViewModel.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ForgetInfo.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ForgetViewModel : NSObject

@property (nonatomic,strong)ForgetInfo *forgetInfo;

// 是否允许重置的信号
@property (nonatomic, strong, readonly) RACSignal *enableResetSignal;

@property (nonatomic, strong, readonly) RACSignal *resetSignal;
@property (nonatomic, strong, readonly) RACSignal *autoCodeSignal;

@end
