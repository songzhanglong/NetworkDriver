//
//  MsgItem.h
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MsgItem : JSONModel

@property (nonatomic,strong)NSString *msgId;        //消息ID
@property (nonatomic,strong)NSString *msg;          //消息体
@property (nonatomic,strong)NSString *time;         //消息发送时间
@property (nonatomic,strong)NSString *sender;       //消息发送人
@property (nonatomic,strong)NSNumber *msgType;      //消息类型， 1系统消息  2支付消息
@property (nonatomic,strong)NSString *orderNo;      //订单号，支付消息有
@property (nonatomic,assign)CGFloat itemHei;

@end
