//
//  Target_Web.m
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "Target_Web.h"
#import "WebViewController.h"

@implementation Target_Web

- (UIViewController *)Action_nativeFetchWebViewController:(NSDictionary *)params
{
    WebViewController *web = [WebViewController new];
    web.url = params[@"url"];
    return web;
}

- (id)Action_nativePresentWebViewController:(NSDictionary *)params
{
    WebViewController *web = [WebViewController new];
    web.url = params[@"url"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:web];
    [[[[[UIApplication sharedApplication] delegate] window] rootViewController] presentViewController:nav animated:YES completion:nil];
    return nil;
}

@end
