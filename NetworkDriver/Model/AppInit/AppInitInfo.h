//
//  AppInitInfo.h
//  CallCar
//
//  Created by szl on 16/6/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface AppInitInfo : JSONModel

//e车易行
@property (nonatomic,strong)NSNumber *coinsForCoupon;           //优惠券
@property (nonatomic,strong)NSString *ecex_dclc;                //分时租赁订车流程
@property (nonatomic,strong)NSString *ecex_lxwm;                //e车易行联系我们
@property (nonatomic,strong)NSString *ecex_share_android;       //e车易行android分享
@property (nonatomic,strong)NSString *ecex_share_ios;           //e车易行ios分享
@property (nonatomic,strong)NSString *ecex_yhxy;                //e车易行用户协议

@property (nonatomic,strong)NSArray *passengerCancelList;       //乘客取消原因列表
@property (nonatomic,strong)NSArray *reassignmentList;          //改派原因列表
@property (nonatomic,strong)NSString *platformCustomerPhone;    //平台客服电话
@property (nonatomic,strong)NSString *rescuePhone;              //
@property (nonatomic,strong)NSArray *serviceComments;           //服务评价语
@property (nonatomic,strong)NSNumber *touringCarAdvancePayment; //房车预约保证金

//房车租赁
@property (nonatomic,strong)NSString *wlcx_dclc;                //房车租赁订车流程
@property (nonatomic,strong)NSString *wlcx_lxwm;                //蜗旅出行联系我们
@property (nonatomic,strong)NSString *wlcx_share_android;       //蜗旅出行android分享
@property (nonatomic,strong)NSString *wlcx_share_ios;           //蜗旅出行ios分享
@property (nonatomic,strong)NSString *wlcx_yhxy;                //蜗旅出行用户协议
@property (nonatomic,strong)NSString *wlcx_yybzjtkxz;           //蜗旅出行预约保证金退款须知
@property (nonatomic,strong)NSString *driverShareApp;           //分享内容

@end
