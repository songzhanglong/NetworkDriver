//
//  Target_Order.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "Target_Order.h"
#import "OrderCancelController.h"
#import "OrderDoneController.h"
#import "OrderWaitPassengerController.h"
#import "OrderReceivingController.h"
#import "OrderBillingController.h"
#import "OrderDetailInfo.h"
#import "OrderInformation.h"

@implementation Target_Order

- (UIViewController *)Action_Immediately:(NSDictionary *)params
{
    OrderInformation *info = params[@"info"];
    NSNumber *number = info.status;
    //订单状态,0订单没人抢已到期 -1司机未接单 1抢单中 2取消叫车 3抢单完成(已接单) 4乘客取消行程 5未计费前司机取消 51 接乘客 6计费中 9计费完成 11付款已完成 12付款已完成且评价
    if (number.integerValue == 0 || number.integerValue == 12 || number.integerValue == 11){
        OrderDoneController *doneCon = [[OrderDoneController alloc] init];
        doneCon.orderInfo = info;
        return doneCon;
    }
    else if (number.integerValue == 2 || number.integerValue == 4){
        OrderCancelController *cancel = [[OrderCancelController alloc] init];
        cancel.orderInfo = info;
        return cancel;
    }
    else if (number.integerValue == 3){
        OrderReceivingController *receive = [[OrderReceivingController alloc] init];
        receive.orderInfo = info;
        return receive;
    }
    else if (number.integerValue == 51){
        OrderWaitPassengerController *wait = [[OrderWaitPassengerController alloc] init];
        wait.orderInfo = info;
        return wait;
    }
    if (number.integerValue == 6 || number.integerValue == 9)
    {
        OrderBillingController *billing = [[OrderBillingController alloc] init];
        billing.orderInfo = info;
        return billing;
    }
    
    return nil;
}

@end
