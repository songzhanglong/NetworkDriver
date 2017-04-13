//
//  OrderImmediatelyController.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderImmediatelyController.h"
#import "OrderImmediatelyCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HomePageViewController.h"
#import "OrderInformation.h"
#import "HomePageViewController.h"
#import "OrderReceivingController.h"

@interface OrderImmediatelyController ()

@property (nonatomic,strong)OrderImmediatelyCell *immediatelyCell;
@property (nonatomic,assign)CGFloat cellHei;
@property (nonatomic,strong)NSTimer *timer;

@end

@implementation OrderImmediatelyController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab_End object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"订单";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    [self initialNavRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCancel:) name:Order_Cancel object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderGrabEnd:) name:Order_Grab_End object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.estimatedRowHeight = 350;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
#endif
    
    [self.tableView registerClass:[OrderImmediatelyCell class] forCellReuseIdentifier:NSStringFromClass([OrderImmediatelyCell class])];
    
    [self initialTableFootView];
    
    //抢单倒计时
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTimer:) userInfo:nil repeats:YES];
}

- (void)testSelecter
{
    NSDictionary *dic2 = @{
                           @"flag":@"order", //订单处理过程中使用
                           @"isSuccess":@"1", //是否抢单成功，1成功  0失败
                           @"msgType": @"3",//消息类型： 3抢单结束
                           @"orderNo": @"189292993923",//订单号
                           @"winner":@"蔡师傅",//抢单成功者昵称
                           @"applyName":@"张小闲", //乘客姓名
                           @"applyPhone":@"131988232323",//乘客电话
                           @"applyHeadImg":@"http://123234.jpg",     //乘客头像
                           @"applyTime": @"2015-11-05 12:07:00",    //申请时间
                           @"fromAddr":@"上海市火车站,113.324233, 32.232423",    //出发地地址, 经度, 纬度
                           @"toAddr":@"上海市嘉定区X033浏翔公路,121.3195770000, 31.3545680000"    //目的地地址, 经度, 纬度
                           };
    [[NSNotificationCenter defaultCenter] postNotificationName:Order_Grab_End object:dic2];
}

#pragma mark - Private Methods
- (void)initialNavRightItem
{
    //right
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"客服" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:MiddleFont];
    [rightBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        AppInitInfo *appInit = [GlobalManager shareInstance].appInit;
        if (appInit && [appInit.platformCustomerPhone length] > 0) {
            UIWebView*callWebview =[[UIWebView alloc] init];
            NSString *url = [NSString stringWithFormat:@"tel:%@",appInit.platformCustomerPhone];
            NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
            [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
            [self.view addSubview:callWebview];
        }
    }];
}

- (void)initialTableFootView
{
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei + 35)];
    
    UIView *backView = [UIView new];
    [backView setTag:10];
    [headerView addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(itemHei));
        make.bottom.equalTo(headerView.mas_bottom);
        make.left.equalTo(@25);
        make.right.equalTo(headerView.mas_right).with.offset(-25);
    }];
    
    UIButton *loginBtn = [self createBtnWith:itemHei];
    [loginBtn setTitle:[NSString stringWithFormat:@"抢单%ld",(long)_maxSeconds] forState:UIControlStateNormal];
    [loginBtn setBackgroundColor:BASELINE_COLOR];
    [loginBtn setTag:100];
    [backView addSubview:loginBtn];
    [loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.equalTo(backView);
        if ([self.grabOrder.isDispatcher integerValue] == 0) {
            make.right.equalTo(backView.mas_right);
        }
    }];
    @weakify(self);
    [[loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self grabOrderStart];
    }];
    
    if ([_grabOrder.isDispatcher integerValue] == 1) {
        UIButton *refuseBtn = [self createBtnWith:itemHei];
        [refuseBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        [refuseBtn setBackgroundColor:rgba(105, 105, 105, 1)];
        [backView addSubview:refuseBtn];
        [refuseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.and.top.and.bottom.equalTo(backView);
            make.left.equalTo(loginBtn.mas_right).with.offset(10);
            make.width.equalTo(loginBtn.mas_width).with.multipliedBy(0.5);
        }];
        [[refuseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [self updateDriverRefuseOrder];
        }];
    }
    
    [self.tableView setTableFooterView:headerView];
}

- (UIButton *)createBtnWith:(CGFloat)hei
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn.layer setMasksToBounds:YES];
    [btn.layer setCornerRadius:hei / 2];
    [btn.titleLabel setFont:MiddleFont];
    return btn;
}

#pragma mark - notifi
- (void)orderCancel:(NSNotification *)notifi
{
    NSDictionary *dic = [notifi object];
    NSString *orderNo = [dic valueForKey:@"orderNo"];
    if (![_grabOrder.orderNo isEqualToString:orderNo]) {
        return;
    }
    [[GlobalManager shareInstance].userInfo setOrderNo:nil];
    [self clearTimer];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    [self.navigationController.view makeToast:@"乘客已取消" duration:1.0 position:@"center"];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)orderGrabEnd:(NSNotification *)notifi
{
    NSDictionary *dic = [notifi object];
    NSString *orderNo = [dic valueForKey:@"orderNo"];
    if (![_grabOrder.orderNo isEqualToString:orderNo]) {
        return;
    }
    
    [self clearTimer];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    NSString *isSuccess = [dic valueForKey:@"isSuccess"];
    if ([isSuccess integerValue] == 0) {
        [[GlobalManager shareInstance].userInfo setOrderNo:nil];
        
        //[self.navigationController.view makeToast:@"抢单失败" duration:1.0 position:@"center"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else{
        [[GlobalManager shareInstance].userInfo setOrderNo:orderNo];
        
        OrderReceivingController *wait = [[OrderReceivingController alloc] init];
        OrderInformation *info = [[OrderInformation alloc] init];
        info.applyName = [dic valueForKey:@"applyName"];
        info.applyTime = [dic valueForKey:@"applyTime"];
        info.applyPhone = [dic valueForKey:@"applyPhone"];
        info.applyHeadImg = [dic valueForKey:@"applyHeadImg"];
        NSArray *fromAddress = [[dic valueForKey:@"fromAddr"] componentsSeparatedByString:@","];
        NSArray *toAddress = [[dic valueForKey:@"toAddr"] componentsSeparatedByString:@","];
        info.fromAddr = fromAddress[0];
        info.fromLat = fromAddress[2];
        info.fromLon = fromAddress[1];
        info.toAddr = toAddress[0];
        info.toLat = toAddress[2];
        info.toLon = toAddress[1];
        info.orderNo = [dic valueForKey:@"orderNo"];
        info.isDispatcher = _grabOrder.isDispatcher;
        wait.orderInfo = info;
        [self.navigationController pushViewController:wait animated:YES];
    }
}

#pragma mark - timer
- (void)startTimer:(NSTimeInterval)time
{
    _maxSeconds--;
    if (_maxSeconds < 0) {
        [self clearTimer];
        if (self.navigationController.topViewController == self) {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            //[self.navigationController.view makeToast:@"订单已过期" duration:1.0 position:@"center"];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    else{
        UIView *backView = [self.tableView.tableFooterView viewWithTag:10];
        if (backView) {
            UIButton *btn = (UIButton *)[backView viewWithTag:100];
            [btn setTitle:(_maxSeconds > 0) ? [NSString stringWithFormat:@"抢单%ld",(long)_maxSeconds]  : @"抢单" forState:UIControlStateNormal];
        }
    }
}

- (void)clearTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

#pragma mark - 抢单
- (void)grabOrderStart
{
//    [self testSelecter];
//    
//    return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在抢单...";
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    LocationManager *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager;
    NSDictionary *dic = @{@"cmd":@"grabOrder",@"token":userInfo.token,@"version":app_Version,@"params":@{@"driverId":userInfo.userId,@"orderNo":_grabOrder.orderNo,@"mapType":@"baidu",@"Lon":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.longitude] stringValue],@"Lat":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.latitude] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"grabOrder"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf grabOrderFinish:error Data:data];
        });
    }];
}

- (void)grabOrderFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    if (error) {
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self clearTimer];
        self.tableView.tableFooterView.userInteractionEnabled = NO;
        UIView *backView = [self.tableView.tableFooterView viewWithTag:10];
        if (backView) {
            UIButton *btn = (UIButton *)[backView viewWithTag:100];
            [btn setTitle:@"抢单" forState:UIControlStateNormal];
        }
    }
}

#pragma mark - 拒绝指派单
- (void)updateDriverRefuseOrder
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在提交...";
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    LocationManager *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager;
    NSDictionary *dic = @{@"cmd":@"updateDriverRefuseOrder",@"token":userInfo.token,@"version":app_Version,@"params":@{@"userId":userInfo.userId,@"orderNo":_grabOrder.orderNo,@"lon":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.longitude] stringValue],@"lat":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.latitude] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"updateDriverRefuseOrder"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateDriverRefuseOrderFinish:error Data:data];
        });
    }];
}

- (void)updateDriverRefuseOrderFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self clearTimer];
        HomePageViewController *home = (HomePageViewController *)[self.navigationController.viewControllers firstObject];
        if ([_grabOrder.orderNo isEqualToString:home.grabOrder.orderNo]) {
            home.grabOrder = nil;
        }
        [[GlobalManager shareInstance].userInfo setOrderNo:nil];
        [self.navigationController.view makeToast:@"提交成功" duration:1.0 position:@"center"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([OrderImmediatelyCell class]);
    OrderImmediatelyCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[OrderImmediatelyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSString *orderNo = _grabOrder.orderNo ?: @"";
    if (orderNo.length > 8) {
        orderNo = [orderNo substringFromIndex:orderNo.length - 8];
    }
    [cell.orderNumberLab setText:[@"订单号:" stringByAppendingString:orderNo]];
    [cell.orderStateLab setText:([_grabOrder.isDispatcher integerValue] == 0) ? @"即时单" : @"指派单"];
    NSArray *fromAddress = [_grabOrder.fromAddr componentsSeparatedByString:@","];
    NSArray *toAddress = [_grabOrder.toAddr componentsSeparatedByString:@","];
    [cell.getOnLab setText:[fromAddress firstObject]];
    [cell.getOffLab setText:[toAddress firstObject]];

    HomePageViewController *homePage = [self.navigationController.viewControllers firstObject];
    //CLLocation
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[fromAddress[2] doubleValue] longitude:[fromAddress[1] doubleValue]];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:[toAddress[2] doubleValue] longitude:[toAddress[1] doubleValue]];
    CLLocationDistance route = [fromLocation distanceFromLocation:toLocation]/1000;
    CLLocationDistance routeTime = route * 60 / 35;
    CLLocationDistance distance = [homePage.locationManager.userLocation.location distanceFromLocation:fromLocation] / 1000;
    CLLocationDistance distanceTime = distance * 60 / 35;

    [cell.distanceLab setText:[NSString stringWithFormat:@"距您%.1f公里,大约需要%.1f分钟",distance,distanceTime]];
    [cell.routeLab setText:[NSString stringWithFormat:@"行程%.1f公里,大约需要%.1f分钟",route,routeTime]];
    //[cell.priceLab setText:@"0.0"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    return UITableViewAutomaticDimension;
#else
    if (!_immediatelyCell) {
        _immediatelyCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OrderImmediatelyCell class])];
        _immediatelyCell.tag = -1000;
    }
    
    // 判断高度是否已经计算过
    if (_cellHei <= 0) {
        // 填充数据
        [_immediatelyCell.distanceLab setText:@"距您5.3公里,大约需要20分钟"];
        [_immediatelyCell.routeLab setText:@"行程9.1公里,大约需要30分钟"];
        //[_immediatelyCell.priceLab setText:@"69.9"];

        // 根据当前数据，计算Cell的高度，注意+1
        _cellHei = [_immediatelyCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    return _cellHei;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *immediatelyHeaderCellId = @"immediatelyHeaderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:immediatelyHeaderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:immediatelyHeaderCellId];
        headerView.contentView.backgroundColor = self.view.backgroundColor;
    }
    
    return headerView;
}

@end
