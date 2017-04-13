//
//  CTMediator+ModuleLogin.m
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator+ModuleLogin.h"

NSString *const kCTMediatorTargetLogin = @"Login";
NSString *const kCTMediatorTargetActionLogin = @"Login";
NSString *const kCTMediatorTargetActionSlide = @"Slide";
NSString *const kCTMediatorTargetActionForget = @"Forget";
NSString *const kCTMediatorTargetActionLaunch = @"Launch";

@implementation CTMediator (ModuleLogin)

- (void)CTMediator_rootviewControllerForLogin:(BOOL)animation
{
    [self performTarget:kCTMediatorTargetLogin action:kCTMediatorTargetActionLogin params:@{@"animation":@(animation)}];
}

- (void)CTMediator_rootviewControllerForSlide:(BOOL)animation
{
    [self performTarget:kCTMediatorTargetLogin action:kCTMediatorTargetActionSlide params:@{@"animation":@(animation)}];
}

- (void)CTMediator_rootviewControllerForLaunch
{
    [self performTarget:kCTMediatorTargetLogin action:kCTMediatorTargetActionLaunch params:nil];
}

- (UIViewController *)CTMediator_viewControllerForForget
{
    return [self performTarget:kCTMediatorTargetLogin action:kCTMediatorTargetActionForget params:nil];
}

@end
