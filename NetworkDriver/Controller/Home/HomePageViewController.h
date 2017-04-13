//
//  HomePageViewController.h
//  NetworkDriver
//
//  Created by szl on 16/9/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "TableViewController.h"
#import "LocationManager.h"
#import "OrderImmediatelyController.h"

@interface HomePageViewController : TableViewController

@property (nonatomic,strong)LocationManager *locationManager;
@property (nonatomic,strong)GrabOrderInfo *grabOrder;

@end
