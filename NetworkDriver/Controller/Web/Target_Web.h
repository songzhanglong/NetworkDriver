//
//  Target_Web.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_Web : NSObject

- (UIViewController *)Action_nativeFetchWebViewController:(NSDictionary *)params;
- (id)Action_nativePresentWebViewController:(NSDictionary *)params;

@end
