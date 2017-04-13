//
//  MapViewController.h
//  NetworkDriver
//
//  Created by szl on 16/10/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"

@class OrderInformation;

@interface MapViewController : BaseViewController

@property (nonatomic,strong)OrderInformation *orderInfo;
@property (nonatomic,assign)BOOL getOff;

@end
