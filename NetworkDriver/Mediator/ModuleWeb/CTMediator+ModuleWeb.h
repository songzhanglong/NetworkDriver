//
//  CTMediator+ModuleWeb.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator.h"

@interface CTMediator (ModuleWeb)

- (UIViewController *)CTMediator_viewControllerForWeb:(NSString *)url;
- (void)CTMediator_presentWebViewController:(NSString *)url;

@end
