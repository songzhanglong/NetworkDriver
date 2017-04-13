//
//  DJTGlobalDefineKit.h
//  TY
//
//  Created by songzhanglong on 14-5-20.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#ifndef TY_DJTGlobalDefineKit_h
#define TY_DJTGlobalDefineKit_h

#define APPDELEGETE                 ((AppDelegate *)[[UIApplication sharedApplication]delegate])

#define USERDEFAULT                 ([NSUserDefaults standardUserDefaults])
#pragma mark - 路径
#define APPDocumentsDirectory       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]                    //document路径
#define APPCacheDirectory           [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]                 //cache路径
#define APPTmpDirectory             [NSHomeDirectory()  stringByAppendingPathComponent:@"tmp"]   //tmp路径

#pragma mark - 屏幕参数
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)

#pragma mark - 接口地址
//#define G_INTERFACE_ADDRESS         @"http://120.27.94.21:8086/huading/"      //测试环境
//#define G_INTERFACE_DSE             @"http://120.27.94.21:8888/status/saving" //测试环境

#define G_INTERFACE_ADDRESS         @"http://115.28.228.178:8080/huading/"    //http服务器地址(生产)
#define G_INTERFACE_DSE             @"http://120.27.43.46:8888/status/saving" //生产

#define G_TOKEN                     @"8HUEDING#@%$#!89QAZ"
#pragma mark - HmacSHA1加密密钥
#define SERCET_KEY                  @"abcdefghijklmnopqrstuvwx" //HMac1加密秘钥
#define JS_FILE_NAME                @"society"                  //js文件名称
#define GT_NOTICE                   @"gtMsgNotice"
#define AppInit_FileName            @"appInit"                  //app初始化文件存储

#pragma mark - 背景颜色与字体
#define G_BACKGROUND_COLOR          [UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0]
#define CreateColor(x,y,z)          [UIColor colorWithRed:x / 255.0 green:y / 255.0 blue:z / 255.0 alpha:1.0]
#define rgba(r,g,b,a)               [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define FontSize(x)                 [UIFont systemFontOfSize:x]

#pragma mark - 设计颜色
#define BASELINE_COLOR              rgba(25,192,109,1)      //主色调
#define BLUE_COLOR                  rgba(0,144,255,1)       //蓝色
#define GREEN_COLOR                 rgba(0,200,128,1)       //绿色
#define RED_COLOR                   rgba(255,68,68,1)       //深红
#define LIGHTRED_COLOR              rgba(255,100,88,1)      //浅红

#define BigFont                     [UIFont systemFontOfSize:17]
#define MiddleFont                  [UIFont systemFontOfSize:15]
#define SmallFont                   [UIFont systemFontOfSize:12]

#define CREATE_IMG(name)            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"png"]]
#define CREATE_JPG(name)            [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:@"jpg"]]
#define cre

#pragma mark - 友盟APPKEY
#define UMENG_APPKEY                @"579ea4c167e58e08a00017ef"    //公司

#define NET_WORK_TIP                @"无法连接服务器，请检查你的网络设置。"
#define REQUEST_FAILE_TIP           @"无法连接服务器，请尝试重新打开客户端。"
#define SHARE_TIP_INFO              @"您还需要安装对应的APP"
#define LOGIN_PHONE                 @"loginPhone"
#define LOGIN_PASS                  @"loginPass"
#define LOGIN_CODE                  @"loginCode"

#pragma mark - 订单过程中的通知
#define Order_Grab                  @"orderGrab"        //抢单
#define Order_Cancel                @"orderCancel"      //还未有司机抢单乘客取消叫车
#define Order_Grab_End              @"orderGrabEnd"     //抢单完成(已接单)
#define Order_Grab_Cancel           @"orderGrabCancel"  //司机还未到达乘客上车地点乘客取消行程
#define Order_Pay                   @"orderPay"         //支付完成
#define Order_Save_Plist            @"OrderSavePlist.plist"   //订单保存

#define Save_Distance               @"distanse"         //已走距离
#define Save_Lat                    @"lat"              //纬度
#define Save_Lon                    @"lon"              //经度
#define Save_Date                   @"date"             //日期
#define Save_Timer                  @"timer"            //花费时间
#define Save_No                     @"SaveNo"           //订单编号

typedef enum
{
    ClassType = 0,//班级动态
    BabyType,     //宝贝相册
    NoneType,     //直接进入
    
}ActivityType;//新建动态

#endif
