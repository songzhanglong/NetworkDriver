//
//  AppDelegate.m
//  NetworkDriver
//
//  Created by szl on 16/9/20.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AppDelegate.h"
#import <GeTuiSdk.h>
#import <UMMobClick/MobClick.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "UMSocial.h"
#import "UMSocialWechatHandler.h"
#import "CTMediator+ModuleLogin.h"
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HttpClient.h"
#import <iflyMSC/iflyMSC.h>
#import <AlipaySDK/AlipaySDK.h>
#import "BNCoreServices.h"

/// 个推开发者网站中申请App时，注册的AppId、AppKey、AppSecret
#define kGtAppId           @"MwqdzksDwQ6n6Dlxd2Vu41"
#define kGtAppKey          @"cuSnGmp7Qj6W45DVWRvWwA"
#define kGtAppSecret       @"J1OZWqW9oO863V88sbIc18"
#define kBaidusdkKey       @"qW40WB9j4wKW80HlNvYLFTPuMq4LQc6k"

// 科大讯飞
#define APPID_VALUE           @"57e9d9df"

@interface AppDelegate ()<GeTuiSdkDelegate,BMKGeneralDelegate>

@property (nonatomic,strong)BMKMapManager* mapManager;
@property (nonatomic,strong)NSURLSessionDataTask *sessionTast;
@property (nonatomic,assign)BOOL initDataFromNet;   //初始化完毕

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // 通过个推平台分配的appId、 appKey 、appSecret 启动SDK，注：该方法需要在主线程中调用
    [GeTuiSdk startSdkWithAppId:kGtAppId appKey:kGtAppKey appSecret:kGtAppSecret delegate:self];
    // 注册APNS
    [self registerRemoteNotification];
    
    //友盟配置
    [self umengTrack];
    
    // 科大讯飞
    [self configMSCVoice];
    
    //map
    self.mapManager = [[BMKMapManager alloc] init];
    if (![self.mapManager start:kBaidusdkKey generalDelegate:self]) {
        NSLog(@"manager start failed!");
    }
    
    //初始化导航SDK
    [BNCoreServices_Instance initServices:kBaidusdkKey];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
    
    //UINavigationBar
    [[UINavigationBar appearance] setBarTintColor:BASELINE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:   [UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    NSString *phone = [userDef valueForKey:LOGIN_PHONE],*password = [userDef valueForKey:LOGIN_PASS];
    if (phone.length > 0 && password.length > 0) {
        [[CTMediator sharedInstance] CTMediator_rootviewControllerForLaunch];
    }
    else {
        [[CTMediator sharedInstance] CTMediator_rootviewControllerForLogin:NO];
    }
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

/** 远程通知注册成功委托 */
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"\n>>>[DeviceToken Success]:%@\n\n", token);
    
    //向个推服务器注册deviceToken
    [GeTuiSdk registerDeviceToken:token];
}

/** iOS7.0 以后支持APP后台刷新数据，会回调 performFetchWithCompletionHandler 接口，此处为保证个推数据刷新需调用[GeTuiSdk resume] 接口恢复个推SDK 运行刷新数据。 */
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    /// Background Fetch 恢复SDK 运行
    [GeTuiSdk resume];
    completionHandler(UIBackgroundFetchResultNewData);
}

/** APP已经接收到“远程”通知(推送) - 透传推送消息  */
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    // 将收到的APNs信息传给个推统计
    [GeTuiSdk handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    __weak typeof(GlobalManager *)manager = [GlobalManager shareInstance];
    __weak typeof(self)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [manager setNetworkReachabilityStatus:status];
        if (status <= AFNetworkReachabilityStatusNotReachable) {
            [weakSelf.window makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        }
        else{
            [weakSelf appInitInfo];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
        return YES;
    }
    
    return ([[CTMediator sharedInstance] performActionWithUrl:url completion:nil] && [UMSocialSnsService handleOpenURL:url]);
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];
        
        return YES;
    }
    
    return ([[CTMediator sharedInstance] performActionWithUrl:url completion:nil] && [UMSocialSnsService handleOpenURL:url]);
}

#pragma mark - 注册APNS
- (void)registerRemoteNotification {
#ifdef __IPHONE_8_0
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        
        UIUserNotificationType types = (UIUserNotificationTypeAlert |
                                        UIUserNotificationTypeSound |
                                        UIUserNotificationTypeBadge);
        
        UIUserNotificationSettings *settings;
        settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        
    } else {
        UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
    }
#else
    UIRemoteNotificationType apn_type = (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge);
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apn_type];
#endif
}

#pragma mark - GeTuiSdkDelegate
/** SDK启动成功返回cid */
- (void)GeTuiSdkDidRegisterClient:(NSString *)clientId {
    //个推SDK已注册，返回clientId
    NSLog(@"\n>>>[GeTuiSdk RegisterClient]:%@\n\n", clientId);
    [[GlobalManager shareInstance] setClientId:clientId];
}

/** SDK遇到错误回调 */
- (void)GeTuiSdkDidOccurError:(NSError *)error {
    //个推错误报告，集成步骤发生的任何错误都在这里通知，如果集成后，无法正常收到消息，查看这里的通知。
    NSLog(@"\n>>>[GexinSdk error]:%@\n\n", [error localizedDescription]);
}

/** SDK收到透传消息回调 */
- (void)GeTuiSdkDidReceivePayloadData:(NSData *)payloadData andTaskId:(NSString *)taskId andMsgId:(NSString *)msgId andOffLine:(BOOL)offLine fromGtAppId:(NSString *)appId {
    //收到个推消息
    /*
    NSString *payloadMsg = nil;
    if (payloadData) {
        payloadMsg = [[NSString alloc] initWithBytes:payloadData.bytes length:payloadData.length encoding:NSUTF8StringEncoding];
    }
    
    NSString *msg = [NSString stringWithFormat:@"taskId=%@,messageId:%@,payloadMsg:%@%@",taskId,msgId, payloadMsg,offLine ? @"<离线消息>" : @""];
    NSLog(@"\n>>>[GexinSdk ReceivePayload]:%@\n\n", msg);
     */
    NSDictionary *content = [NSJSONSerialization JSONObjectWithData:payloadData options:NSJSONReadingMutableContainers error:nil];
    NSString *flag = [content valueForKey:@"flag"];
    NSString *msgType = [content valueForKey:@"msgType"];
    if ([flag isEqualToString:@"order"]) {
        NSInteger orderType = [msgType integerValue];
        if (orderType == 1) {
            //抢单
            [[NSNotificationCenter defaultCenter] postNotificationName:Order_Grab object:content];
            /*
            {
                "flag":”order”,  //订单处理过程中使用
                "msgType": "1", //消息类型：1抢单
                "seconds": "20", //倒计时，秒数
                "orderNo": "189292993923", //订单号
                "expireTime": "234245235345", //到期时间long型=推送时间+倒计时间隔
                "applyTime": "2015-11-05 12:07:00",    //申请时间
                "fromAddr":"上海市火车站,113.324233, 32.232423",    //出发地地址, 经度, 纬度
                "toAddr":"上海市火车站,113.324233, 32.232423", //目的地地址, 经度, 纬度
                "isDispatcher":"1" //是否指派单 1指派单  0即时单
            }
             */
        }
        else if (orderType == 2){
            //还未有司机抢单乘客取消叫车
            [[NSNotificationCenter defaultCenter] postNotificationName:Order_Cancel object:content];
            /*
            "flag":”order”, //订单处理过程中使用
            "msgType": "2", //消息类型：2取消叫车
            "orderNo": "189292993923"//订单号
             */
        }
        else if (orderType == 3){
            //抢单完成(已接单)
            [[NSNotificationCenter defaultCenter] postNotificationName:Order_Grab_End object:content];
            /*
             "flag":”order”, //订单处理过程中使用
             "isSuccess":”1”, //是否抢单成功，1成功  0失败
             "msgType": "3",//消息类型： 3抢单结束
             "orderNo": "189292993923"//订单号
             "winner":"蔡师傅"//抢单成功者昵称
             "applyName":"张小闲" //乘客姓名
             "applyPhone":"131988232323"//乘客电话
             "applyHeadImg":"http://123234.jpg"     //乘客头像
             "applyTime": "2015-11-05 12:07:00",    //申请时间
             "fromAddr":"上海市火车站,113.324233, 32.232423",    //出发地地址, 经度, 纬度
             "toAddr":"上海市火车站,113.324233, 32.232423",    //目的地地址, 经度, 纬度
             */
        }
        else if (orderType == 4){
            //司机还未到达乘客上车地点乘客取消行程
            [[NSNotificationCenter defaultCenter] postNotificationName:Order_Grab_Cancel object:content];
            /*
            "flag":”order”, //订单处理过程中使用
            "msgType": "4", //消息类型：4乘客取消行程
            "orderNo": "189292993923"//订单号
             */
        }
        else if (orderType == 11){
            //支付完成
            [[NSNotificationCenter defaultCenter] postNotificationName:Order_Pay object:content];
            /*
             "flag":”order”,   //订单处理过程中使用
             "msgType": "11",               //消息类型：11 支付完成
             "orderNo": "189292993923"//订单号
             */
        }
    }
    
    /**
     *汇报个推自定义事件
     *actionId：用户自定义的actionid，int类型，取值90001-90999。
     *taskId：下发任务的任务ID。
     *msgId： 下发任务的消息ID。
     *返回值：BOOL，YES表示该命令已经提交，NO表示该命令未提交成功。注：该结果不代表服务器收到该条命令
     **/
    [GeTuiSdk sendFeedbackMessage:90001 andTaskId:taskId andMsgId:msgId];
}

#pragma mark - 友盟配置
- (void)umengTrack {
    UMConfigInstance.appKey = UMENG_APPKEY;
    UMConfigInstance.channelId = @"App Store";
    UMConfigInstance.ePolicy = SEND_INTERVAL;
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setLogEnabled:NO];
    
    //分享
    //设置友盟社会化组件APPKEY
    [UMSocialData setAppKey:UMENG_APPKEY];
    
    //设置微信AppId，设置分享url，默认使用友盟的网址
    [UMSocialWechatHandler setWXAppId:@"wxcfdcc514434adb67" appSecret:@"b294990ff8fffdbbff534c40472e8f02" url:@"http://www.huadingweiye.com/"];
    NSString *app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]; ;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = app_Name;
    [UMSocialData defaultData].extConfig.wechatTimelineData.title = app_Name;
    
    //对未安装客户端平台进行隐藏
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToWechatSession, UMShareToWechatTimeline]];
}

#pragma mark - 科大讯飞
- (void)configMSCVoice
{
    //设置sdk的log等级，log保存在下面设置的工作路径中
    [IFlySetting setLogFile:LVL_NONE];
    
    //打开输出在console的log开关
    [IFlySetting showLogcat:NO];
    
    //设置sdk的工作路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [paths objectAtIndex:0];
    [IFlySetting setLogFilePath:cachePath];
    
    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",APPID_VALUE];
    
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initString];
}

#pragma mark - BMKGeneralDelegate
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

#pragma mark - 初始化
- (void)appInitInfo{
    if (self.sessionTast || self.initDataFromNet) {
        return;
    }
    //不存在，填充plist文件内容
    if (![GlobalManager shareInstance].appInit) {
        NSString *plist = [APPDocumentsDirectory stringByAppendingPathComponent:AppInit_FileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:plist]) {
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:plist]];
            AppInitInfo *initInfo = [[AppInitInfo alloc] initWithDictionary:dic error:nil];
            [[GlobalManager shareInstance] setAppInit:initInfo];
        }
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"init",@"token":@"",@"version":app_Version,@"params":@{}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTast = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"init"] parameters:dic complateBlcok:^(NSError *error, id data) {
        [weakSelf appInitFinish:error Data:data];
    }];
}

- (void)appInitFinish:(NSError *)error Data:(id)result
{
    self.sessionTast = nil;
    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        if (!detail || ![detail isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        self.initDataFromNet = YES;
        NSString *plist = [APPDocumentsDirectory stringByAppendingPathComponent:AppInit_FileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:plist]) {
            NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:plist]];
            if ([dic isEqualToDictionary:detail]) {
                return;
            }
        }
        AppInitInfo *info = [[AppInitInfo alloc] initWithDictionary:detail error:nil];
        [[GlobalManager shareInstance] setAppInit:info];
        
        [detail writeToFile:plist atomically:YES];
    }
}

@end
