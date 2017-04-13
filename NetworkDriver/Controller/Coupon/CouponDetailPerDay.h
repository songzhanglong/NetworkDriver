//
//  CouponDetailPerDay.h
//  NetworkDriver
//
//  Created by szl on 16/10/9.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CouponDetailPerDay : JSONModel

@property (nonatomic,strong)NSString *orderNo;          //订单编号
@property (nonatomic,strong)NSString *time;             //时间
@property (nonatomic,strong)NSNumber *income;           //收入
@property (nonatomic,strong)NSNumber *coupons;          //优惠券金额

@end
