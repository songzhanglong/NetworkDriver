//
//  HomePageViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/21.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "HomePageViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "YQSlideMenuController.h"
#import "AcceptCarCell.h"
#import "NewMsgCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <iflyMSC/iflyMSC.h>
#import "PcmPlayer.h"
#import "TTSConfig.h"
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HttpClient.h"
#import "CustomIOSAlertView.h"
#import "UIColor+Hex.h"
#import "OrderDetailInfo.h"
#import "OrderInformation.h"
#import "OrdersViewController.h"
#import "CTMediator+Order.h"
#import "MsgItem.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MsgCenterViewController.h"

static const NSString *conDetailInfo  = @"detailInfo";

@interface HomePageViewController ()<IFlySpeechSynthesizerDelegate,UIActionSheetDelegate>

@property (nonatomic,strong)UIButton *beginTrip;
@property (nonatomic,strong)IFlySpeechSynthesizer * iFlySpeechSynthesizer;
//@property (nonatomic,strong)PcmPlayer *audioPlayer;
@property (nonatomic,strong)CustomIOSAlertView *alertView;
@property (nonatomic,assign)BOOL addPushIdRequested;
@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation HomePageViewController

- (void)dealloc
{
    //定时器
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self.locationManager];
    [self.locationManager.locService stopUserLocationService];
    self.locationManager.locService.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Pay object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveGrabOrderNotification:) name:Order_Grab object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePayOrderNotification:) name:Order_Pay object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePayOrderNotification:) name:Order_Cancel object:nil];
    
    //initial
    [self initialNavItems];
    [self createTableViewAndRequestAction:nil Param:nil];
    [self.tableView setBackgroundColor:self.view.backgroundColor];
    [self.view addSubview:self.beginTrip];
    [self.beginTrip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-(60 * SCREEN_HEIGHT / 1334));
        make.width.and.height.equalTo(@80);
    }];
    
    //查询最新5条消息
    [self queryMsgCenterInfo];
    //查询司机订单数量接口
    [self queryDriverOrderCount];
    
    //上报在线时长
    [self performSelector:@selector(addOnlineTime) withObject:nil afterDelay:3 * 60];
    
    //当前有订单在执行
    if ([GlobalManager shareInstance].userInfo.orderNo.length > 0) {
        __weak typeof(self)weakSelf = self;
        double delayInSeconds = 1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^{
            [weakSelf popAlertView];
        });
    }
    
    //[self testSelecter];
}

- (void)testSelecter
{
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        NSString *expireTime = [[NSNumber numberWithDouble:([[NSDate date] timeIntervalSince1970] + 20) * 1000] stringValue];
        NSDictionary *dic = @{@"flag":@"order",  //订单处理过程中使用
                              @"msgType": @"1", //消息类型：1抢单
                              @"seconds": @"20", //倒计时，秒数
                              @"orderNo": @"189292993923", //订单号
                              @"expireTime": expireTime, //到期时间long型=推送时间+倒计时间隔
                              @"applyTime": @"2015-11-05 12:07:00",    //申请时间
                              @"fromAddr":@"上海市火车站,113.324233, 32.232423",    //出发地地址, 经度, 纬度
                              @"toAddr":@"上海市嘉定区X033浏翔公路,121.3195770000, 31.3545680000", //目的地地址, 经度, 纬度
                              @"isDispatcher":@"1" //是否指派单 1指派单  0即时单
                              };
        [[NSNotificationCenter defaultCenter] postNotificationName:Order_Grab object:dic];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = YES;
    
    //讯飞
    [self initSynthesizer];
    
    //百度
    if (self.locationManager) {
        NSLog(@"开始定位");
    }
    //声音
    if (self.grabOrder) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
        NSTimeInterval expireTimer = 0;
        NSInteger dis = 0;
        if (self.grabOrder) {
            expireTimer = [self.grabOrder.expireTime doubleValue];
            dis = (expireTimer - interval) / 1000;
            if (dis <= 3) {
                //保存的消息已过期
                self.grabOrder = nil;
            }
            else{
                [self speakByGrabOrder:_grabOrder];
                OrderImmediatelyController *receive = [[OrderImmediatelyController alloc] init];
                receive.grabOrder = _grabOrder;
                receive.maxSeconds = dis;
                [self.navigationController pushViewController:receive animated:YES];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    YQSlideMenuController *side = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
    side.needSwipeShowMenu = NO;
    
//    [_iFlySpeechSynthesizer stopSpeaking];
//    //[_audioPlayer stop];
//    _iFlySpeechSynthesizer.delegate = nil;
}

#pragma mark - Private Methods
- (void)initialNavItems
{
    //right
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"未完成订单" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:MiddleFont];
    [rightBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    @weakify(self);
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        OrdersViewController *orders = [[OrdersViewController alloc] init];
        orders.isCurrent = YES;
        [self.navigationController pushViewController:orders animated:YES];
    }];
    
    //left
    UIImage *img = [UIImage imageNamed:@"navHead"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, rightBtn.bounds.size.width, img.size.height);
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, rightBtn.bounds.size.width - img.size.width)];
    [backBtn setImage:img forState:UIControlStateNormal];
    [[backBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        YQSlideMenuController *sideCon = (YQSlideMenuController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        [sideCon showMenu];
    }];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
    
    
    //middle
    UIImageView *midImg = [[UIImageView alloc] init];
    [midImg setImage:[UIImage imageNamed:@"Navibar_logo.png"]];
    [midImg sizeToFit];
    self.navigationItem.titleView = midImg;
    
    [RACObserve([GlobalManager shareInstance], clientId) subscribeNext:^(NSString *x) {
        @strongify(self);
        if (x.length > 0 && !self.addPushIdRequested) {
            [self addPushId:x];
        }
    }];
    
    [RACObserve([GlobalManager shareInstance].userInfo, isReceiveTask) subscribeNext:^(NSNumber *x) {
        @strongify(self);
        self.beginTrip.selected = (x.integerValue == 1);
    }];
}

//设置合成参数
- (void)initSynthesizer
{
    if (_iFlySpeechSynthesizer) {
        return;
    }
    
    TTSConfig *instance = [TTSConfig sharedInstance];
    if (instance == nil) {
        return;
    }
    
    //合成服务单例
    if (_iFlySpeechSynthesizer == nil) {
        _iFlySpeechSynthesizer = [IFlySpeechSynthesizer sharedInstance];
    }
    
    _iFlySpeechSynthesizer.delegate = self;
    
    //设置语速1-100
    [_iFlySpeechSynthesizer setParameter:instance.speed forKey:[IFlySpeechConstant SPEED]];
    
    //设置音量1-100
    [_iFlySpeechSynthesizer setParameter:instance.volume forKey:[IFlySpeechConstant VOLUME]];
    
    //设置音调1-100
    [_iFlySpeechSynthesizer setParameter:instance.pitch forKey:[IFlySpeechConstant PITCH]];
    
    //设置采样率
    [_iFlySpeechSynthesizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //设置发音人
    [_iFlySpeechSynthesizer setParameter:instance.vcnName forKey:[IFlySpeechConstant VOICE_NAME]];
    
    //设置文本编码格式
    [_iFlySpeechSynthesizer setParameter:@"unicode" forKey:[IFlySpeechConstant TEXT_ENCODING]];
    
    //asr_audio_path保存录音文件路径，如不再需要，设置value为nil表示取消，默认目录是documents
    [_iFlySpeechSynthesizer setParameter:nil forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];
    NSLog(@"%@",APPDocumentsDirectory);
}

- (void)speakByGrabOrder:(GrabOrderInfo *)grabInfo
{
    if (self.iFlySpeechSynthesizer.isSpeaking) {
        [self.iFlySpeechSynthesizer stopSpeaking];
    }
    
    NSString *fromAddr = [[grabInfo.fromAddr componentsSeparatedByString:@","] firstObject],*toAddr = [[grabInfo.toAddr componentsSeparatedByString:@","] firstObject];
    NSString *lstStr = nil;
    if (toAddr.length == 0) {
        lstStr = [NSString stringWithFormat:@"您有一张新订单,上车地点%@",fromAddr];
    }
    else{
        lstStr = [NSString stringWithFormat:@"您有一张新订单,从%@到%@",fromAddr,toAddr];
    }
    [self.iFlySpeechSynthesizer startSpeaking:lstStr];
}

- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [self.tableView setTableFooterView:[UIView new]];
        return;
    }
    
    CGFloat itemHei = 120;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
    
    UILabel *orderNum = [[UILabel alloc] init];
    [orderNum setFont:MiddleFont];
    [orderNum setTextColor:BASELINE_COLOR];
    [orderNum setText:@"暂无数据"];
    [headerView addSubview:orderNum];
    [orderNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView.mas_centerX);
        make.centerY.equalTo(headerView.mas_centerY);
    }];
    
    [self.tableView setTableFooterView:headerView];
}

//弹框
- (void)popAlertView
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, 180)];
    [contentView setBackgroundColor:[UIColor whiteColor]];
    contentView.layer.cornerRadius = 7;
    contentView.layer.masksToBounds = YES;
    [self addSubViewToAlertContentView:contentView];
    _alertView = [[CustomIOSAlertView alloc] init];
    [_alertView setContainerView:contentView];
    [_alertView setButtonTitles:nil];
    [_alertView setUseMotionEffects:true];
    [_alertView show];
}

- (void)addSubViewToAlertContentView:(UIView *)contentView
{
    UIView *upContent = [[UIView alloc] init];
    [contentView addSubview:upContent];
    [upContent mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView.mas_centerX);
        make.centerY.equalTo(contentView.mas_centerY).with.offset(-25);
    }];
    //up
    UILabel *upLab = [[UILabel alloc] init];
    [upLab setFont:BigFont];
    [upLab setTextColor:[UIColor blackColor]];
    [upLab setText:@"您的行程正在进行中"];
    [upContent addSubview:upLab];
    [upLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.equalTo(upContent.mas_right);
    }];
    //content
    UILabel *quesLab = [[UILabel alloc] init];
    [quesLab setFont:[UIFont systemFontOfSize:24]];
    [quesLab setTextColor:BASELINE_COLOR];
    [quesLab setText:@"是否进入？"];
    [upContent addSubview:quesLab];
    [quesLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(upLab.mas_bottom).with.offset(10);
        make.centerX.equalTo(upLab.mas_centerX);
        make.bottom.equalTo(upContent.mas_bottom);
    }];
    
    //margin
    UIView *hMargin = [UIView new];
    [hMargin setBackgroundColor:[UIColor lightGrayColor]];
    [contentView addSubview:hMargin];
    [hMargin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(contentView);
        make.bottom.equalTo(contentView.mas_bottom).with.offset(-50);
        make.height.equalTo(@1);
    }];
    
    //noJoin
    CGFloat wei = (CGRectGetWidth(contentView.bounds) - 1) / 2,hei = 50;
    UIImage *hliImg = [UIColor createImageWithColor:BASELINE_COLOR Size:CGSizeMake(wei, hei)];
    UIButton *noJoin = [UIButton buttonWithType:UIButtonTypeCustom];
    [noJoin setTitle:@"不进入" forState:UIControlStateNormal];
    [noJoin setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [noJoin setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [noJoin.titleLabel setFont:BigFont];
    [noJoin setBackgroundImage:hliImg forState:UIControlStateHighlighted];
    [contentView addSubview:noJoin];
    [noJoin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.bottom.equalTo(contentView);
        make.width.equalTo(@(wei));
        make.height.equalTo(@(hei));
    }];
    @weakify(self);
    [[noJoin rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.alertView close];
        self.alertView = nil;
    }];
    
    //margin
    UIView *vMargin = [UIView new];
    [vMargin setBackgroundColor:[UIColor lightGrayColor]];
    [contentView addSubview:vMargin];
    [vMargin mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.height.equalTo(noJoin);
        make.left.equalTo(noJoin.mas_right);
        make.width.equalTo(@1);
    }];;
    
    //join
    UIButton *joinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [joinBtn setTitle:@"进入" forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [joinBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [joinBtn.titleLabel setFont:BigFont];
    [joinBtn setBackgroundImage:hliImg forState:UIControlStateHighlighted];
    [contentView addSubview:joinBtn];
    [joinBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.and.bottom.equalTo(contentView);
        make.width.and.height.equalTo(noJoin);
    }];
    [[joinBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self.alertView close];
        self.alertView = nil;
        [self queryOrderDetail];
    }];
}

#pragma mark - notifi
- (void)receiveGrabOrderNotification:(NSNotification *)notifi
{
    if (self.grabOrder) {
        return;
    }
    
    NSDictionary *dic = [notifi object];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    NSTimeInterval expireTimer = 0;
    NSTimeInterval dis = 0;
    expireTimer = [[dic valueForKey:@"expireTime"] doubleValue];
    dis = (expireTimer - interval) / 1000;
    if (dis <= 3) {
        //时间太短，直接过滤
        return;
    }
    
    GrabOrderInfo *grab = [[GrabOrderInfo alloc] initWithDictionary:dic error:nil];
    self.grabOrder = grab;
    if ([self.navigationController.topViewController isKindOfClass:[HomePageViewController class]]) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES]; //此次有可能正在做订单请求
        [self speakByGrabOrder:grab];
        OrderImmediatelyController *receive = [[OrderImmediatelyController alloc] init];
        receive.grabOrder = grab;
        receive.maxSeconds = dis;
        [self.navigationController pushViewController:receive animated:YES];
    }
}

- (void)receivePayOrderNotification:(NSNotification *)notifi
{
    if (self.grabOrder) {
        NSDictionary *dic = [notifi object];
        if ([self.grabOrder.orderNo isEqualToString:[dic valueForKey:@"orderNo"]]) {
            self.grabOrder = nil;
            //右上角按钮气泡消失
            [[GlobalManager shareInstance].userInfo setOrderNo:nil];
        }
    }
}

#pragma mark - 合成回调 IFlySpeechSynthesizerDelegate
/**
 开始播放回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakBegin
{
    NSLog(@"开始播放");
}

/**
 缓冲进度回调
 
 progress 缓冲进度
 msg 附加信息
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onBufferProgress:(int) progress message:(NSString *)msg
{
    NSLog(@"buffer progress %2d%%. msg: %@.", progress, msg);
}

/**
 播放进度回调
 
 progress 缓冲进度
 
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void) onSpeakProgress:(int) progress beginPos:(int)beginPos endPos:(int)endPos
{
    NSLog(@"speak progress %2d%%.", progress);
}

/**
 合成暂停回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakPaused
{
    NSLog(@"播放暂停");
}

/**
 恢复合成回调
 注：
 对通用合成方式有效，
 对uri合成无效
 ****/
- (void)onSpeakResumed
{
    NSLog(@"播放继续");
}

/**
 合成结束（完成）回调
 
 对uri合成添加播放的功能
 ****/
- (void)onCompleted:(IFlySpeechError *) error
{
    
    if (error.errorCode != 0) {
        NSLog(@"错误码:%d",error.errorCode);
        return;
    }
    
    NSLog(@"合成结束");
}

/**
 取消合成回调
 ****/
- (void)onSpeakCancel
{
    NSLog(@"正在取消...");
}

#pragma mark - 查询最新5条消息
- (void)queryMsgCenterInfo
{
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"queryMsgList",@"token":userInfo.token,@"version":app_Version,@"params":@{@"onePageNum":@"5",@"pageNo":@"1",@"userId":userInfo.userId}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryMsgList"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf queryMsgCenterInfoFinish:error Data:data];
        });
    }];
}

- (void)queryMsgCenterInfoFinish:(NSError *)error Data:(id)result
{
    if (error) {
        [self performSelector:@selector(queryMsgCenterInfo) withObject:nil afterDelay:5];
    }
    else{
        //订单数量
        id detail = [result valueForKey:@"detail"];
        NSArray *msgList = [detail valueForKey:@"dataList"];
        self.dataSource = [MsgItem arrayOfModelsFromDictionaries:msgList error:nil];
        [self.tableView reloadData];
        
        [self createTableFooterView];
    }
}

#pragma mark - 查询司机订单数量接口
- (void)queryDriverOrderCount
{
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"queryDriverOrderCount",@"token":detailInfo.token,@"version":app_Version,@"params":@{@"userId":detailInfo.userId}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryDriverOrderCount"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf queryDriverOrderCountFinish:error Data:data];
        });
    }];
}

- (void)queryDriverOrderCountFinish:(NSError *)error Data:(id)result
{
    if (error) {
        [self performSelector:@selector(queryDriverOrderCount) withObject:nil afterDelay:5];
    }
    else{
        //订单数量
        id detail = [result valueForKey:@"detail"];
        DriverOrderCount *driverOrder = [[DriverOrderCount alloc] initWithDictionary:detail error:nil];
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
        [detailInfo setOrderCount:driverOrder];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - 查询司机可使用车辆列表接口
- (void)queryDriverVehicleList
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"正在查询...";
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"queryDriverVehicleList",@"token":detailInfo.token,@"version":app_Version,@"params":@{@"userId":detailInfo.userId,@"lpno":detailInfo.bindLpno,@"corpId":detailInfo.corpId}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryDriverVehicleList"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf queryDriverVehicleListFinish:error Data:data];
        });
    }];
}

- (void)queryDriverVehicleListFinish:(NSError *)error Data:(id)result
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        //车辆列表
        id detail = [result valueForKey:@"detail"];
        NSArray *dataList = [detail valueForKey:@"dataList"];
        NSArray *items = [CarItem arrayOfModelsFromDictionaries:dataList error:nil];
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
        [detailInfo setCarItems:items];
        
        //提示
        Class actionClass = NSClassFromString(@"UIAlertController");
        if (actionClass) {
            UIAlertController *alertController = [actionClass alertControllerWithTitle:@"请选择车辆" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            for (NSInteger i = 0; i < [detailInfo.carItems count]; i++) {
                CarItem *item = detailInfo.carItems[i];
                [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:item.lpno style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self drawoutCar:item];
                }]];
            }
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                NSLog(@"取消");
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIActionSheet *actin = [[UIActionSheet alloc] initWithTitle:@"请选择车辆" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles: nil];
            for (NSInteger i = 0; i < [detailInfo.carItems count]; i++) {
                CarItem *item = detailInfo.carItems[i];
                [actin addButtonWithTitle:item.lpno];
            }
            [actin addButtonWithTitle:@"取消"];
            actin.cancelButtonIndex = actin.numberOfButtons - 1;
            [actin showInView:self.view];
        }
    }
}

#pragma mark - addPushId
- (void)addPushId:(NSString *)clientId
{
    _addPushIdRequested = YES;
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"addPushId",@"token":detailInfo.token,@"version":app_Version,@"params":@{@"platform":@"ios",@"userId":detailInfo.userId,@"pushId":clientId}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"addPushId"] parameters:dic complateBlcok:^(NSError *error, id data) {
        if (error) {
            [weakSelf performSelector:@selector(addPushId:) withObject:clientId afterDelay:5];
        }
    }];
}

#pragma mark - 订单详情接口
- (void)queryOrderDetail
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"正在进入...";
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dic = @{@"cmd":@"queryOrderDetail",@"token":userInfo.token,@"version":app_Version,@"params":@{@"driverId":userInfo.userId,@"orderNo":userInfo.orderNo,@"mapType":@"baidu"}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryOrderDetail"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf queryOrderDetailFinish:error Data:data];
        });
    }];
}

- (void)queryOrderDetailFinish:(NSError *)error Data:(id)result
{
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.sessionTask = nil;
    if (self.navigationController.topViewController == self) {
        if (error == nil) {
            id detail = [result valueForKey:@"detail"];
            OrderDetailInfo *detailInfo = [[OrderDetailInfo alloc] initWithDictionary:detail error:nil];
            OrderInformation *info = [[OrderInformation alloc] initWithString:[detailInfo toJSONString] error:nil];
            UIViewController *con = [[CTMediator sharedInstance] CTMediator_viewControllerForOrder:info];
            if (con) {
                [con setValue:detailInfo forKey:@"detailInfo"];
                objc_setAssociatedObject(self, &conDetailInfo, detailInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [self.navigationController pushViewController:con animated:YES];
            }
        }
        else{
            [self.view makeToast:error.domain duration:1.0 position:@"center"];
        }
    }
}

#pragma mark - 上报在线时长接口
- (void)addOnlineTime
{
    UserDetailInfo *userDetail = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"addOnlineTime",@"token":userDetail.token,@"version":app_Version,@"params":@{@"onlineTime":@"0.05"}};
    dic = [NSString convertDicToStr:dic];
    
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"addOnlineTime"] parameters:dic complateBlcok:^(NSError *error, id data) {
        
    }];
    
    [self performSelector:@selector(addOnlineTime) withObject:nil afterDelay:3 * 60];
}

#pragma mark - 是否开启接单服务开关接口
- (void)drawoutCar:(CarItem *)item
{
    NSLog(@"%@:%@",item.vehicleProduct,item.lpno);
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在请求...";
    
    //参数请求
    BOOL isOff = (item == nil);
    UserDetailInfo *userDetail = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"isReceiveOrder",@"token":userDetail.token,@"version":app_Version,@"params":@{@"userId":userDetail.userId,@"vehicleId":!isOff ? item.vehicleId : userDetail.bindVehicleId,@"needPush":!isOff ? @"1" : @"0"}};
    dic = [NSString convertDicToStr:dic];
    
    __weak typeof(self)weakSelf = self;
    [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"isReceiveOrder"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.navigationController.view animated:YES];
            if (error) {
                [weakSelf.view makeToast:error.domain duration:1.0 position:@"center"];
            }
            else{
                userDetail.isReceiveTask = [NSNumber numberWithInt:isOff ? 0 : 1];
                if (!isOff) {
                    userDetail.bindVehicleId = item.vehicleId;
                    userDetail.bindLpno = item.lpno;
                    userDetail.bindVehicleProduct = item.vehicleProduct;
                }
            }
        });
    }];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.numberOfButtons - 1) {
        CarItem *item = [GlobalManager shareInstance].userInfo.carItems[buttonIndex];
        [self drawoutCar:item];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL firstCell = (indexPath.section == 0);
    NSString *cellId = firstCell ? @"acceptCellId" : @"newMsgCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (firstCell) {
            cell = [[AcceptCarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        else{
            cell = [[NewMsgCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
    }
    if (firstCell) {
        [(AcceptCarCell *)cell resetDriverOrderCount];
    }
    else{
        MsgItem *msg = self.dataSource[indexPath.row];
        [(NewMsgCell *)cell resetNewMessage:msg.time Content:msg.msg];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    }
    return 80;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *homeCellId = @"homeCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:homeCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:homeCellId];
        //img
        UIImageView *leftImg = [[UIImageView alloc] init];
        [leftImg setTag:1];
        [headerView.contentView addSubview:leftImg];
        [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15));
            make.bottom.equalTo(headerView.contentView.mas_bottom).with.offset(-15);
        }];
        //tip
        UILabel *tipLab = [[UILabel alloc] init];
        [tipLab setTag:2];
        [tipLab setFont:MiddleFont];
        [tipLab setTextColor:[UIColor darkGrayColor]];
        [headerView.contentView addSubview:tipLab];
        [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImg.mas_right).with.offset(2);
            make.centerY.equalTo(leftImg.mas_centerY);
        }];
        //car
        UILabel *carLab = [[UILabel alloc] init];
        [carLab setFont:MiddleFont];
        [carLab setTextColor:[UIColor blackColor]];
        [carLab setTag:3];
        [headerView.contentView addSubview:carLab];
        [carLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(tipLab.mas_right);
            make.centerY.equalTo(tipLab.mas_centerY);
        }];
        
        //more
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreBtn setTag:4];
        [moreBtn setTitle:@"更多>>" forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [moreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        [moreBtn.titleLabel setFont:SmallFont];
        [headerView.contentView addSubview:moreBtn];
        [moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(headerView.contentView.mas_right).with.offset(-15);
            make.centerY.equalTo(tipLab.mas_centerY);
        }];
        @weakify(self);
        [[moreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            MsgCenterViewController *msgCenter = [[MsgCenterViewController alloc] init];
            [self.navigationController pushViewController:msgCenter animated:YES];
        }];
    }
    
    BOOL firstSec = (section == 0);
    UIImageView *leftImg = (UIImageView *)[headerView.contentView viewWithTag:1];
    [leftImg setImage:[UIImage imageNamed:firstSec ? @"car_icon.png" : @"news_icon.png"]];
    UILabel *tipLab = (UILabel *)[headerView.contentView viewWithTag:2];
    [tipLab setText:firstSec ? @"当前听单车辆 " : @""];
    UILabel *carLab = (UILabel *)[headerView.contentView viewWithTag:3];
    if (firstSec) {
        NSString *bindLpno = [GlobalManager shareInstance].userInfo.bindLpno;
        [carLab setText:(bindLpno.length > 0) ? bindLpno : @"--"];
    }
    else{
        [carLab setText:@"最新消息"];
    }
    UIButton *moreBtn = (UIButton *)[headerView.contentView viewWithTag:4];
    moreBtn.hidden = firstSec;
    
    return headerView;
}

#pragma mark - lazy load
- (UIButton *)beginTrip
{
    if (!_beginTrip) {
        _beginTrip = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beginTrip setBackgroundColor:BASELINE_COLOR];
        [_beginTrip setTitle:@"出车" forState:UIControlStateNormal];
        [_beginTrip setTitle:@"收车" forState:UIControlStateSelected];
        [_beginTrip setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_beginTrip setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        _beginTrip.layer.masksToBounds = YES;
        _beginTrip.layer.cornerRadius = 40;
        _beginTrip.layer.borderColor = rgba(164,225,200,1).CGColor;
        _beginTrip.layer.borderWidth = 5;
        @weakify(self);
        [[_beginTrip rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            if (self.beginTrip.selected) {
                [self drawoutCar:nil];
            }
            else{
                [self queryDriverVehicleList];
            }
        }];
    }
    return _beginTrip;
}

- (LocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[LocationManager alloc] init];
    }
    return _locationManager;
}

@end
