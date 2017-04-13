//
//  OrderBillingController.h
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@class OrderDetailInfo;
@class OrderInformation;

@interface OrderBillingController : TableViewController

@property (nonatomic,strong)OrderInformation *orderInfo;
@property (nonatomic,strong)OrderDetailInfo *detailInfo;

@end
