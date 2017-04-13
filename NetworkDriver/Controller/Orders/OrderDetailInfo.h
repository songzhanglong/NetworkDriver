//
//  OrderDetailInfo.h
//  CallCar
//
//  Created by szl on 16/6/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OrderDetailInfo : JSONModel

@property (nonatomic,strong)NSString *orderNo;          //订单号
@property (nonatomic,strong)NSString *applyTime;        //申请时间
@property (nonatomic,strong)NSString *applyName;        //申请人姓名
@property (nonatomic,strong)NSString *applyPhone;       //申请人电话
@property (nonatomic,strong)NSString *applyHeadImg;     //申请人头像
@property (nonatomic,strong)NSString *lpno;             //车牌号
@property (nonatomic,strong)NSString *brand;            //品牌
@property (nonatomic,strong)NSString *product;          //车型
@property (nonatomic,strong)NSString *color;            //颜色

//房车
@property (nonatomic,strong)NSString *planStartTime;    //房车预约用车开始日期：yyyy-mm-dd
@property (nonatomic,strong)NSString *planEndTime;      //房车预约用车结束日期：yyyy-mm-dd
@property (nonatomic,strong)NSNumber *pickUpType;       //取车方式：0自取 1送车
@property (nonatomic,strong)NSString *pickUpAddr;       //自取或送车地址
@property (nonatomic,strong)NSString *orderPerson;      //预订人姓名
@property (nonatomic,strong)NSString *orderPersonPhone; //预订人手机
@property (nonatomic,strong)NSString *note;             //备注

//分时租赁
@property (nonatomic,strong)NSString *formulaId;        //计价公式ID
@property (nonatomic,strong)NSString *formulaName;      //计价公式名称

@property (nonatomic,strong)NSNumber *orderType;        //订单类型（1专车  4分时租赁  5房车租赁）
@property (nonatomic,strong)NSString *startTime;        //订单开始时间
@property (nonatomic,strong)NSString *fromAddr;         //出发地地址
@property (nonatomic,strong)NSString *fromLon;          //出发地经度
@property (nonatomic,strong)NSString *fromLat;          //出发地纬度
@property (nonatomic,strong)NSString *arriveTime;       //抵达目的地时间
@property (nonatomic,strong)NSString *toAddr;           //目的地地址
@property (nonatomic,strong)NSString *toLon;            //目的地经度
@property (nonatomic,strong)NSString *toLat;            //目的地纬度
@property (nonatomic,strong)NSString *driverName;       //司机名称
@property (nonatomic,strong)NSString *driverPhone;      //司机电话
@property (nonatomic,strong)NSString *driverHeadImg;    //司机头像
@property (nonatomic,strong)NSString *driverStarClass;  //星级
@property (nonatomic,strong)NSString *rentCorpId;       //租赁公司ID
@property (nonatomic,strong)NSString *rentCorpName;     //租赁公司名称
@property (nonatomic,strong)NSString *corpCompPhone;    //租赁公司联系电话
@property (nonatomic,strong)NSString *arriveLocalMiles; //抵达目的地里程，单位M
@property (nonatomic,strong)NSString *arriveLocalTimes; //抵达目的地用时，单位分钟
@property (nonatomic,strong)NSNumber *status;           //订单状态,0订单没人抢已到期 -1司机未接单 1抢单中 2取消叫车 3抢单完成(已接单) 4乘客取消行程 5未计费前司机取消 51 接乘客 6计费中 9计费完成 11付款已完成 12付款已完成且评价
@property (nonatomic,strong)NSString *cost;             //订单总费用
@property (nonatomic,strong)NSString *waitCost;         //待支付费用,如果支付失败会有值，对应payId也有值。
@property (nonatomic,strong)NSString *estimateCost;     //预估车费
@property (nonatomic,strong)NSString *comment;          //订单评论
@property (nonatomic,strong)NSString *starClass;        //订单星级
@property (nonatomic,strong)NSString *payId;            //如果有待支付费用则支付时需要传入payId
@property (nonatomic,strong)NSArray *payDetail;         //[//支付明细：支付渠道：(1现金、2优惠券、3微信、4支付宝、5银联、6积分)，费用,关联ID(优惠券ID)，第三方支付流水号（支付宝、微信），第三方支付支付宝账号
@property (nonatomic,strong)NSMutableArray *costDetail; //计费费用明细：变量名、费用、里程（米）、时间、变量ID、单价、公式
@property (nonatomic,strong)NSNumber *sumMiles;        //最新一次上报的累计里程单位米

@end
