//
//  OrderDoneController.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"

@class OrderInformation;
@class OrderDetailInfo;

@interface OrderDoneController : TableViewController

@property (nonatomic,strong)OrderInformation *orderInfo;
@property (nonatomic,strong)OrderDetailInfo *detailInfo;

@end
