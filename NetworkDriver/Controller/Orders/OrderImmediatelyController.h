//
//  OrderImmediatelyController.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "GrabOrderInfo.h"

@interface OrderImmediatelyController : TableViewController

@property (nonatomic,strong)GrabOrderInfo *grabOrder;
@property (nonatomic,assign)NSInteger maxSeconds;

@end
