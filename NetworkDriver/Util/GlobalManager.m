//
//  DJTGlobalManager.m
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "GlobalManager.h"
#import "GlobalDefineKit.h"

@interface GlobalManager ()

@end

@implementation GlobalManager

+ (GlobalManager *)shareInstance
{
    static GlobalManager *globalManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        globalManager = [[GlobalManager alloc] init];
    });
    
    return globalManager;
}

+ (id)findViewFrom:(UIView *)view To:(Class)father
{
    if (!view) {
        return nil;
    }
    
    if ([view.nextResponder isKindOfClass:father])
    {
        return view.nextResponder;
    }
    return [GlobalManager findViewFrom:(UIView *)view.nextResponder To:father];
}

@end
