//
//  CTMediator+Order.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator+Order.h"
#import "OrderDetailInfo.h"

NSString *const kCTMediatorTargetOrder = @"Order";
NSString *const kCTMediatorTargetActionImmediately = @"Immediately";

@implementation CTMediator (Order)

- (UIViewController *)CTMediator_viewControllerForOrder:(OrderInformation *)info
{
    return [self performTarget:kCTMediatorTargetOrder action:kCTMediatorTargetActionImmediately params:@{@"info":info}];
}

@end
