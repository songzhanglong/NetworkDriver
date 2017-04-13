//
//  CouponOfMonth.h
//  NetworkDriver
//
//  Created by szl on 16/10/9.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol CouponOfDay
@end
@interface CouponOfDay : JSONModel

@property (nonatomic,strong)NSString *day;              //天
@property (nonatomic,strong)NSNumber *income;           //天收入
@property (nonatomic,strong)NSNumber *coupons;          //优惠券金额

@end

@interface CouponOfMonth : JSONModel

@property (nonatomic,strong)NSNumber *income;           //本月现金收入
@property (nonatomic,strong)NSNumber *sumCoupons;       //优惠券总金额
@property (nonatomic,strong)NSMutableArray<CouponOfDay> *dataList;

@end
