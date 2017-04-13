//
//  CTMediator+Sideslip.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator+Sideslip.h"

NSString *const kCTMediatorTargetSideslip = @"Sideslip";
NSString *const kCTMediatorTargetActionSideslip = @"Sideslip";

@implementation CTMediator (Sideslip)

- (UIViewController *)CTMediator_viewControllerForSideslip:(NSString *)className
{
    return [self performTarget:kCTMediatorTargetSideslip action:kCTMediatorTargetActionSideslip params:@{@"className":className}];
}

@end
