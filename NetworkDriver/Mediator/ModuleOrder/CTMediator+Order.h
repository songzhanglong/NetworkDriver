//
//  CTMediator+Order.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CTMediator.h"

@class OrderDetailInfo;
@class OrderInformation;

@interface CTMediator (Order)

- (UIViewController *)CTMediator_viewControllerForOrder:(OrderInformation *)info;

@end
