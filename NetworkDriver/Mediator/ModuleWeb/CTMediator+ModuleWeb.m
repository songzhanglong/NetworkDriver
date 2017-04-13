//
//  CTMediator+ModuleWeb.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator+ModuleWeb.h"

NSString *const kCTMediatorTargetWeb = @"Web";
NSString *const kCTMediatorTargetActionWeb = @"nativeFetchWebViewController";
NSString *const kCTMediatorTargetActionPresendWeb = @"nativePresentWebViewController";

@implementation CTMediator (ModuleWeb)

- (UIViewController *)CTMediator_viewControllerForWeb:(NSString *)url
{
    return [self performTarget:kCTMediatorTargetWeb action:kCTMediatorTargetActionWeb params:@{@"url":url}];
}

- (void)CTMediator_presentWebViewController:(NSString *)url
{
    [self performTarget:kCTMediatorTargetWeb action:kCTMediatorTargetActionPresendWeb params:@{@"url":url}];
}

@end
