//
//  CTMediator+ModuleLogin.h
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator.h"

@interface CTMediator (ModuleLogin)

- (void)CTMediator_rootviewControllerForLogin:(BOOL)animation;
- (void)CTMediator_rootviewControllerForSlide:(BOOL)animation;
- (void)CTMediator_rootviewControllerForLaunch;
- (UIViewController *)CTMediator_viewControllerForForget;

@end
