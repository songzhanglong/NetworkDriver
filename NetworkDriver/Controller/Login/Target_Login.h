//
//  Target_Login.h
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Target_Login : NSObject

- (id)Action_Login:(NSDictionary *)params;
- (id)Action_Slide:(NSDictionary *)params;
- (id)Action_Launch:(NSDictionary *)params;
- (UIViewController *)Action_Forget:(NSDictionary *)params;

@end
