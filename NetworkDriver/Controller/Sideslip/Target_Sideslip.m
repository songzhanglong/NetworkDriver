//
//  Target_Sideslip.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "Target_Sideslip.h"

@implementation Target_Sideslip

- (UIViewController *)Action_Sideslip:(NSDictionary *)params
{
    NSString *className = params[@"className"];
    Class targetClass = NSClassFromString(className);
    return [[targetClass alloc] init];
}

@end
