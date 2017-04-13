//
//  PayChargeInfo.h
//  NetworkDriver
//
//  Created by szl on 16/10/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface PayChargeInfo : JSONModel

@property (nonatomic,strong)NSString *cost;                     //总费用
@property (nonatomic,strong)NSString *arriveDestinationTimes;   //抵达目的地时间秒
@property (nonatomic,strong)NSMutableArray *costDetail;         //计费费用明细：变量名、费用、里程（米）、时间、变量ID、单价、公式 ["按天计费","40","","2"、"vd006"、"2"、"2*20"],

@end
