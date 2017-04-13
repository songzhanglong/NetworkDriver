//
//  GrabOrderInfo.h
//  NetworkDriver
//
//  Created by szl on 16/10/12.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface GrabOrderInfo : JSONModel

@property (nonatomic,strong)NSString *flag;         //订单处理过程中使用
@property (nonatomic,strong)NSNumber *msgType;      //消息类型：1抢单
@property (nonatomic,strong)NSNumber *seconds;      //倒计时，秒数
@property (nonatomic,strong)NSString *orderNo;      //订单号
@property (nonatomic,strong)NSString *expireTime;   //到期时间long型=推送时间+倒计时间隔
@property (nonatomic,strong)NSString *applyTime;    //申请时间
@property (nonatomic,strong)NSString *fromAddr;     //出发地地址, 经度, 纬度
@property (nonatomic,strong)NSString *toAddr;       //目的地地址, 经度, 纬度
@property (nonatomic,strong)NSNumber *isDispatcher; //是否指派单 1指派单  0即时单

@end
