//
//  UserDetailInfo.h
//  CallCar
//
//  Created by szl on 16/6/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface DriverOrderCount : JSONModel

@property (nonatomic,strong)NSNumber *orders;           //司机截至目前订单数
@property (nonatomic,strong)NSString *finishRate;       //司机截至目前订单完成率
@property (nonatomic,strong)NSNumber *currentOrders;    //司机今日订单数
@property (nonatomic,strong)NSString *currentFinishRate;//司机今日订单完成率

@end

@interface CarItem : JSONModel

@property (nonatomic,strong)NSString *vehicleId;        //车辆ID
@property (nonatomic,strong)NSString *lpno;             //车牌号
@property (nonatomic,strong)NSString *vehicleProduct;   //车辆型号
@property (nonatomic,strong)NSNumber *status;           //状态：2待绑定 3人车绑定

@end

@interface UserDetailInfo : JSONModel

//app
@property (nonatomic,strong)NSString *token;                //token
@property (nonatomic,strong)NSString *userId;               //用户ID
@property (nonatomic,strong)NSString *mobile;               //手机号码作为用户名
@property (nonatomic,strong)NSString *nickName;             //昵称
@property (nonatomic,strong)NSString *realName;             //姓名
@property (nonatomic,strong)NSString *sex;                  //性别：男、女
@property (nonatomic,strong)NSString *headImage;            //头像
@property (nonatomic,strong)NSString *id;                   //身份证号
@property (nonatomic,strong)NSString *address;              //住址
@property (nonatomic,strong)NSString *drivingType;          //驾照类型A1（大型客车）、A2（牵引车）、A3（城市公交车）、B1（中型客车）、B2（大型货车）、C1（小型汽车）、C2（小型自动挡汽车）、C3（低速载货车）、C4（三轮汽车）
@property (nonatomic,strong)NSString *drivingLastFour;      //驾照后四位
@property (nonatomic,strong)NSString *drivingStartTime;     //驾照起始日期：yyyy-mm-dd,用时间选择器
@property (nonatomic,strong)NSString *drivingValidTime;     //驾照有效期数字
@property (nonatomic,strong)NSString *myPic;                //本人照片
@property (nonatomic,strong)NSString *idPic;                //身份证正面照片
@property (nonatomic,strong)NSString *drivingPic;           //驾驶证照片
@property (nonatomic,strong)NSNumber *status;               //状态：0禁用、1注册（未完善个人信息）、2待审核（已完善个人信息） 3审核通过 4审核未通过
@property (nonatomic,strong)NSString *invitationCode;       //我的邀请码

//司机app
@property (nonatomic,strong)NSString *bindVehicleId;        //绑定的车辆ID
@property (nonatomic,strong)NSString *bindLpno;             //绑定的车牌号
@property (nonatomic,strong)NSString *bindVehicleProduct;   //绑定的车辆型号
@property (nonatomic,strong)NSString *orderNo;              //当前正在执行的订单号
@property (nonatomic,strong)NSNumber *orderStatus;          //当前正在执行的订单状态
@property (nonatomic,strong)NSNumber *isReceiveTask;        //是否接收任务：1接单  0不接单

//other
@property (nonatomic,strong)NSString *callCenter;
@property (nonatomic,strong)NSString *userType;             //用户类型.虚拟运营商管理员：vspAdmin;虚拟运营商客服：vspCustomer;虚拟运营商财务：vspAccounter;企业管理员：corpAdmin;部门管理员：deptAdmin;客服：customServer;财务人员：accountPerson;调度员：dispatcher;司机：driver;乘客：passenger

@property (nonatomic,strong)NSString *corpName;             //所属机构名称
@property (nonatomic,strong)NSString *userName;             //用户名
@property (nonatomic,strong)NSString *corpId;               //所属机构ID
@property (nonatomic,strong)NSString *starClass;
@property (nonatomic,strong)NSString *deptId;               //所属部门ID

//customer
@property (nonatomic,strong)DriverOrderCount<Ignore> *orderCount;
@property (nonatomic,strong)NSArray<Ignore> *carItems;

@end
