//
//  OrderInformation.h
//  CallCar
//
//  Created by szl on 16/6/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface OrderInformation : JSONModel

@property (nonatomic,strong)NSString *orderNo;          //订单号
@property (nonatomic,strong)NSString *lpno;             //车牌号码
@property (nonatomic,strong)NSNumber *orderType;        //订单类型（4分时租赁、5房车、1专车）
@property (nonatomic,strong)NSString *applyTime;        //申请时间
@property (nonatomic,strong)NSString *applyName;        //申请人姓名
@property (nonatomic,strong)NSString *applyHeadImg;     //申请人头像
@property (nonatomic,strong)NSString *applyPhone;       //申请人电话
@property (nonatomic,strong)NSNumber *status;           //订单状态,0订单没人抢已到期 -1司机未接单 1抢单中 2取消叫车 3抢单完成(已接单) 4乘客取消行程 5未计费前司机取消 51 接乘客 6计费中 9计费完成 11付款已完成 12付款已完成且评价
@property (nonatomic,strong)NSNumber *cost;             //费用
@property (nonatomic,strong)NSString *startTime;        //订单开始时间
@property (nonatomic,strong)NSString *fromAddr;         //出发地地址
@property (nonatomic,strong)NSString *fromLon;          //出发地经度
@property (nonatomic,strong)NSString *fromLat;          //出发地纬度
@property (nonatomic,strong)NSString *arriveTime;       //抵达目的地时间
@property (nonatomic,strong)NSString *toAddr;           //目的地地址
@property (nonatomic,strong)NSString *toLon;            //目的地经度
@property (nonatomic,strong)NSString *toLat;            //目的地纬度
@property (nonatomic,strong)NSNumber *arriveLocalTimes; //抵达目的地用时，单位分钟
@property (nonatomic,strong)NSNumber *invoiceStatus;    //索要发票状态： 0待处理，1已处理，2不处理  -1未开
@property (nonatomic,strong)NSString *vehicleId;        //车辆ID

//只有专车且当前执行中的订单时才有
@property (nonatomic,strong)NSMutableArray *costDetail; //计费费用明细：变量名、费用、里程（米）、时间、变量ID、单价、公式
@property (nonatomic,strong)NSNumber *isDispatcher;     //是否指派单 1指派单  0即时单
@property (nonatomic,strong)NSNumber *sumMiles;        //最新一次上报的累计里程单位米

@property (nonatomic,assign)CGFloat itemHei;

@end
