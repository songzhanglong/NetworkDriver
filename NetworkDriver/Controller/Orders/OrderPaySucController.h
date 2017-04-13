//
//  OrderPaySucController.h
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "PayChargeInfo.h"

@class OrderInformation;

@interface OrderPaySucController : TableViewController

@property (nonatomic,strong)OrderInformation *orderInfo;
@property (nonatomic,strong)PayChargeInfo *payCharge;

@end
