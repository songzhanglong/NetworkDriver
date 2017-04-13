//
//  OrderWaitPassengerController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderWaitPassengerController.h"
#import "OrderWaitPassengerCell.h"
#import "OrderPersonCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "KxMenu.h"
#import "OrderRefuseController.h"
#import "OrderInformation.h"
#import "OrderDetailInfo.h"
#import <MBProgressHUD.h>
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HomePageViewController.h"
#import "OrderBillingController.h"
#import "OrderCancelController.h"

@interface OrderWaitPassengerController ()<UIAlertViewDelegate>

@property (nonatomic,strong)OrderWaitPassengerCell *waitCell;
@property (nonatomic,assign)CGFloat cellHei;

@end

@implementation OrderWaitPassengerController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"等待乘客";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    [self initialNavRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCancelFromPassenger:) name:Order_Grab_Cancel object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.estimatedRowHeight = 240;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
#endif
    
    [self.tableView registerClass:[OrderWaitPassengerCell class] forCellReuseIdentifier:NSStringFromClass([OrderWaitPassengerCell class])];
    
    [self initialTableFootView];
}

- (void)testSelecter
{
    OrderBillingController *billing = [[OrderBillingController alloc] init];
    billing.orderInfo = _orderInfo;
    [self.navigationController pushViewController:billing animated:YES];
}

#pragma mark - notice
- (void)orderCancelFromPassenger:(NSNotification *)notifi
{
    NSDictionary *dic = [notifi object];
    NSString *orderNo = [dic valueForKey:@"orderNo"];
    if (![_orderInfo.orderNo isEqualToString:orderNo]) {
        return;
    }
    
    if (self.navigationController.topViewController == self) {
        [[GlobalManager shareInstance].userInfo setOrderNo:nil];
        OrderCancelController *cancel = [[OrderCancelController alloc] init];
        cancel.orderInfo = _orderInfo;
        [self.navigationController pushViewController:cancel animated:YES];
    }
}

#pragma mark - Private Methods
- (void)initialNavRightItem
{
    //right
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setTitle:@"更多" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    [rightBtn.titleLabel setFont:MiddleFont];
    [rightBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        [self popMenuItems];
    }];
}

- (void)initialTableFootView
{
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei + 35)];
    
    //计费
    UIButton *billingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [billingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [billingBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [billingBtn.layer setMasksToBounds:YES];
    [billingBtn.layer setCornerRadius:itemHei / 2];
    [billingBtn.titleLabel setFont:MiddleFont];
    [billingBtn setTitle:@"开始计费" forState:UIControlStateNormal];
    [billingBtn setBackgroundColor:BASELINE_COLOR];
    [headerView addSubview:billingBtn];
    [billingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView.mas_bottom);
        make.height.equalTo(@(itemHei));
        make.left.equalTo(@25);
        make.right.equalTo(headerView.mas_right).with.offset(-25);
    }];
    @weakify(self);
    [[billingBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        Class actionClass = NSClassFromString(@"UIAlertController");
        if (actionClass) {
            UIAlertController *alertController = [actionClass alertControllerWithTitle:@"确认现在出发" message:@"乘客已上车" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self beginCaculatePrice];
            }]];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认现在出发" message:@"乘客已上车" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
    
    [self.tableView setTableFooterView:headerView];
}

- (void)backToPreControl:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)popMenuItems
{
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"取消订单"
                     image:nil
                    target:self
                    action:@selector(cancelOrder:)],
      
      [KxMenuItem menuItem:@"客服"
                     image:nil
                    target:self
                    action:@selector(callPlatformCustomerPhone)]
      ];
    
    KxMenuItem *first = menuItems[0],*last = [menuItems lastObject];
    first.foreColor = [UIColor blackColor];
    first.alignment = NSTextAlignmentCenter;
    last.foreColor = [UIColor blackColor];
    
    CGRect rect = [self.navigationController.navigationBar convertRect:self.navigationItem.rightBarButtonItem.customView.frame toView:self.navigationController.view];
    
    [KxMenu showMenuInView:self.navigationController.view
                  fromRect:rect
                 menuItems:menuItems];
}

- (void)cancelOrder:(KxMenuItem *)item
{
    OrderRefuseController *refuse = [[OrderRefuseController alloc] init];
    refuse.orderInfo = _orderInfo;
    [self.navigationController pushViewController:refuse animated:YES];
}

- (void)callPlatformCustomerPhone
{
    AppInitInfo *appInit = [GlobalManager shareInstance].appInit;
    if (appInit && [appInit.platformCustomerPhone length] > 0) {
        UIWebView*callWebview =[[UIWebView alloc] init];
        NSString *url = [NSString stringWithFormat:@"tel:%@",appInit.platformCustomerPhone];
        NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.view addSubview:callWebview];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self beginCaculatePrice];
    }
}

#pragma mark - 司机开始计费接口
- (void)beginCaculatePrice
{
//    [self testSelecter];
//    return;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在请求...";
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    LocationManager *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager;
    NSDictionary *dic = @{@"cmd":@"updateStartCharge",@"token":userInfo.token,@"version":app_Version,@"params":@{@"driverId":userInfo.userId,@"orderNo":_orderInfo.orderNo,@"mapType":@"baidu",@"Lon":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.longitude] stringValue],@"Lat":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.latitude] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"updateStartCharge"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf beginCaculatePriceFinish:error Data:data];
        });
    }];
}

- (void)beginCaculatePriceFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        OrderBillingController *billing = [[OrderBillingController alloc] init];
        billing.orderInfo = _orderInfo;
        [self.navigationController pushViewController:billing animated:YES];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = (indexPath.section == 0) ? NSStringFromClass([OrderPersonCell class]) : NSStringFromClass([OrderWaitPassengerCell class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[OrderPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            [[((OrderPersonCell *)cell).phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                UIWebView*callWebview =[[UIWebView alloc] init];
                NSString *url = [NSString stringWithFormat:@"tel:%@",_orderInfo.applyPhone];
                NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
                [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
                [self.view addSubview:callWebview];
            }];
        }
        else{
            cell = [[OrderWaitPassengerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
    }
    if (indexPath.section == 0) {
        OrderPersonCell *personCell = (OrderPersonCell *)cell;
        [personCell.headImg sd_setImageWithURL:[NSURL URLWithString:_orderInfo.applyHeadImg ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
        [personCell.nameLab setText:(_orderInfo.applyName.length > 0) ? _orderInfo.applyName : @"匿名"];
    }
    else{
        OrderWaitPassengerCell *passengerCell = (OrderWaitPassengerCell *)cell;
        NSString *orderNo = _orderInfo.orderNo ?: @"";
        if (orderNo.length > 8) {
            orderNo = [orderNo substringFromIndex:orderNo.length - 8];
        }
        [passengerCell.orderNumberLab setText:[@"订单号:" stringByAppendingString:orderNo]];
        [passengerCell.orderStateLab setText:([_orderInfo.isDispatcher integerValue] == 0) ? @"即时单" : @"指派单"];
        NSString *fromAddr = (_orderInfo.startTime.length > 0) ? [[[_orderInfo.startTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.fromAddr]] : _orderInfo.fromAddr;
        NSString *toAddr = (_orderInfo.arriveTime.length > 0) ? [[[_orderInfo.arriveTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.toAddr]] : _orderInfo.toAddr;
        [passengerCell.getOnLab setText:fromAddr];
        [passengerCell.getOffLab setText:toAddr];
        
        //CLLocation
        CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.fromLat doubleValue] longitude:[_orderInfo.fromLon doubleValue]];
        CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.toLat doubleValue] longitude:[_orderInfo.toLon doubleValue]];
        CLLocationDistance route = [fromLocation distanceFromLocation:toLocation]/1000;
        CLLocationDistance routeTime = route * 60 / 35;
        [passengerCell.routeLab setText:[NSString stringWithFormat:@"全程约%.1f公里,大约需要%.1f分钟",route,routeTime]];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    return UITableViewAutomaticDimension;
#else
    if (!_waitCell) {
        _waitCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OrderWaitPassengerCell class])];
        _waitCell.tag = -1000;
    }
    
    // 判断高度是否已经计算过
    if (_cellHei <= 0) {
        // 填充数据
        [_waitCell.routeLab setText:@"全程"];
        
        // 根据当前数据，计算Cell的高度，注意+1
        _cellHei = [_waitCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    return _cellHei;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *passengerHeaderCellId = @"passengerHeaderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:passengerHeaderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:passengerHeaderCellId];
        headerView.contentView.backgroundColor = self.view.backgroundColor;
    }
    
    return headerView;
}

@end
