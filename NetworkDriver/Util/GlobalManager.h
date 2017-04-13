//
//  DJTGlobalManager.h
//  TY
//
//  Created by songzhanglong on 14-5-21.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworkReachabilityManager.h"
#import "AppInitInfo.h"
#import "UserDetailInfo.h"

@interface GlobalManager : NSObject

@property (nonatomic,assign)AFNetworkReachabilityStatus networkReachabilityStatus;    //网络状态
@property (nonatomic,strong)AppInitInfo *appInit;       //应用初始化信息
@property (nonatomic,strong)UserDetailInfo *userInfo;   //用户信息
@property (nonatomic,strong)NSString *clientId;         //个推clientId

+ (GlobalManager *)shareInstance;

/**
 *	@brief	查找视图的某个父类
 *
 *	@param 	view 	视图
 *	@param 	father 	类别
 *
 *	@return	查找结果
 */
+ (id)findViewFrom:(UIView *)view To:(Class)father;


@end
