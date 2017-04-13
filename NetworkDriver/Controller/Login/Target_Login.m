
//
//  Target_Login.m
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "Target_Login.h"
#import "LoginViewController.h"
#import "HomePageViewController.h"
#import "YQSlideMenuController.h"
#import "SideslipViewController.h"
#import "ForgetPassController.h"
#import "LaunchViewController.h"

@implementation Target_Login

- (id)Action_Login:(NSDictionary *)params
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    BOOL animation = [params[@"animation"] boolValue];
    if (animation) {
        //pop
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromLeft;
        [window.layer addAnimation:transition forKey:nil];
    }
    UINavigationController *loginNav = [[UINavigationController alloc] initWithRootViewController:[LoginViewController new]];
    
    window.rootViewController = loginNav;
    return nil;
}

- (id)Action_Slide:(NSDictionary *)params
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    BOOL animation = [params[@"animation"] boolValue];
    if (animation) {
        //push
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        [window.layer addAnimation:transition forKey:nil];
    }
    HomePageViewController * home = [[HomePageViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:home];
    SideslipViewController *left = [[SideslipViewController alloc] init];
    YQSlideMenuController *deckController = [[YQSlideMenuController alloc] initWithContentViewController:nav leftMenuViewController:left];
    window.rootViewController = deckController;
    return nil;
}

- (id)Action_Launch:(NSDictionary *)params
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UINavigationController *launchNav = [[UINavigationController alloc] initWithRootViewController:[LaunchViewController new]];
    window.rootViewController = launchNav;
    return nil;
}

- (UIViewController *)Action_Forget:(NSDictionary *)params
{
    return [ForgetPassController new];
}

@end
