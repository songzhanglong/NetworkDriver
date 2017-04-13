//
//  OrderBillingController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderBillingController.h"
#import "OrderBillingCell.h"
#import "OrderPersonCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderPayController.h"
#import "OrderRefuseController.h"
#import "OrderDetailInfo.h"
#import "OrderInformation.h"
#import "GlobalManager.h"
#import "HomePageViewController.h"
#import <MBProgressHUD.h>
#import "NSString+Common.h"
#import "MapViewController.h"
#import "OrderCancelController.h"

@interface OrderBillingController ()<UIAlertViewDelegate>

@property (nonatomic,strong)OrderBillingCell *billingCell;
@property (nonatomic,assign)CGFloat cellHei;
@property (nonatomic,strong)CLLocation *userLocation;
@property (nonatomic,assign)double distanse;
@property (nonatomic,assign)CGFloat expandTime;

@end

@implementation OrderBillingController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"正在服务";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    //时间和日期还原
    
    [self initialNavRightItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCancelFromPassenger:) name:Order_Grab_Cancel object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.estimatedRowHeight = 260;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
#endif
    
    [self.tableView registerClass:[OrderBillingCell class] forCellReuseIdentifier:NSStringFromClass([OrderBillingCell class])];
    
    [self initialTableFootView];
}

- (void)testSelecter
{
    OrderPayController *payCon = [[OrderPayController alloc] init];
    payCon.orderInfo = self.orderInfo;
    PayChargeInfo *charge = [[PayChargeInfo alloc] init];
    charge.cost = @"23.4";
    charge.arriveDestinationTimes = @"1134";
    charge.costDetail = [NSMutableArray arrayWithObjects:@[@"按天计费",@"40",@"",@"2",@"vd006",@"2",@"2*20"],@[@"按天计费",@"40",@"",@"2",@"vd0024",@"2",@"2*20"], nil];
    payCon.payCharge = charge;
    [self.navigationController pushViewController:payCon animated:YES];
}

#pragma mark - 地理位置刷新
- (void)refushDistanceToDestination:(BMKUserLocation *)userLocation
{
    UIView *topView = [self.tableView.tableFooterView viewWithTag:1];
    UILabel *lab = (UILabel *)[topView viewWithTag:2];
    if (lab) {
        //CLLocation
        CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.toLat doubleValue] longitude:[_orderInfo.toLon doubleValue]];
        CLLocationDistance distance = [userLocation.location distanceFromLocation:fromLocation] / 1000;
        CLLocationDistance distanceTime = distance * 60 / 35;
        [lab setText:[NSString stringWithFormat:@"距离下车地点%.1f公里,大约需要%.1f分钟",distance,distanceTime]];
    }
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
        };
    }];
    
    LocationManager *locationMana = (LocationManager *)((HomePageViewController *)self.navigationController.viewControllers.firstObject).locationManager;
    if (!locationMana.isCaculating) {
        [locationMana beginLocationUpload];
    }
    else{
        //
        NSString *file = [APPDocumentsDirectory stringByAppendingPathComponent:Order_Save_Plist];
        NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:file];
        if (dic) {
            self.distanse = [[dic valueForKey:Save_Distance] doubleValue] / 1000;
            double lat = [[dic valueForKey:Save_Lat] doubleValue],lon = [[dic valueForKey:Save_Lon] doubleValue];
            CLLocation *tmpLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            self.distanse += [locationMana.userLocation.location distanceFromLocation:tmpLoc] / 1000;
            NSDate *date = [dic valueForKey:Save_Date];
            double timer = [[dic valueForKey:Save_Timer] doubleValue];
            self.expandTime = timer + floor([[NSDate date] timeIntervalSinceDate:date]);
        }
    }
    
    //坐标观察
    @weakify(self);
    [RACObserve(locationMana, userLocation) subscribeNext:^(BMKUserLocation *location) {
        @strongify(self);
        if (!self.userLocation) {
            self.userLocation = location.location;
        }
        else{
            [self refushDistanceToDestination:location];
            self.userLocation = location.location;
        }
    }];
    
    //距离观察
    [RACObserve(locationMana, sumMiles) subscribeNext:^(NSNumber *miles) {
        @strongify(self);
        self.distanse += miles.doubleValue / 1000;
//        if (self.tableView) {
//            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
    }];
    [RACObserve(locationMana, sumTimes) subscribeNext:^(NSNumber *miles) {
        @strongify(self);
        self.expandTime += 5;
        if (self.tableView) {
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }];
}

- (void)initialTableFootView
{
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    UIImageView *addressImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_location.png"]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20 + addressImg.image.size.height + 30 + itemHei + 15 + itemHei)];
    
    UIView *topView = [UIView new];
    [topView setTag:1];
    [headerView addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView.mas_centerX);
        make.top.equalTo(@20);
    }];
    //address
    [topView addSubview:addressImg];
    [addressImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.bottom.equalTo(@0);
        make.bottom.equalTo(topView.mas_bottom);
    }];
    
    //tiplab
    UILabel *label = [UILabel new];
    [label setTag:2];
    HomePageViewController *homePage = [self.navigationController.viewControllers firstObject];
    //CLLocation
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.toLat doubleValue] longitude:[_orderInfo.toLon doubleValue]];
    CLLocationDistance distance = [homePage.locationManager.userLocation.location distanceFromLocation:fromLocation] / 1000;
    CLLocationDistance distanceTime = distance * 60 / 35;
    [label setText:[NSString stringWithFormat:@"距离下车地点%.1f公里,大约需要%.1f分钟",distance,distanceTime]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:MiddleFont];
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressImg.mas_right).with.offset(2);
        make.centerY.equalTo(addressImg.mas_centerY);
        make.right.equalTo(topView.mas_right);
    }];
    
    //arrive
    UIButton *arriveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [arriveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [arriveBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [arriveBtn.layer setMasksToBounds:YES];
    [arriveBtn.layer setCornerRadius:itemHei / 2];
    [arriveBtn.titleLabel setFont:MiddleFont];
    [arriveBtn setTitle:@"服务完成" forState:UIControlStateNormal];
    [arriveBtn setBackgroundColor:BASELINE_COLOR];
    [headerView addSubview:arriveBtn];
    [arriveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView.mas_bottom);
        make.height.equalTo(@(itemHei));
        make.left.equalTo(@25);
        make.right.equalTo(headerView.mas_right).with.offset(-25);
    }];
    @weakify(self);
    [[arriveBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        Class actionClass = NSClassFromString(@"UIAlertController");
        if (actionClass) {
            UIAlertController *alertController = [actionClass alertControllerWithTitle:@"服务已完成" message:@"把乘客送到指定地点?" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self updateEndCharge];
            }]];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"服务已完成" message:@"把乘客送到指定地点?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
    }];
    
    //getOn
    UIButton *getOnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getOnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getOnBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [getOnBtn.layer setMasksToBounds:YES];
    [getOnBtn.layer setCornerRadius:itemHei / 2];
    [getOnBtn.titleLabel setFont:MiddleFont];
    [getOnBtn setTitle:@"导航至下车地点" forState:UIControlStateNormal];
    [getOnBtn setBackgroundColor:rgba(105, 105, 105, 1)];
    [headerView addSubview:getOnBtn];
    [getOnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(arriveBtn.mas_top).with.offset(-15);
        make.left.and.right.and.height.equalTo(arriveBtn);
    }];
    [[getOnBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        MapViewController *map = [[MapViewController alloc] init];
        map.orderInfo = self.orderInfo;
        map.getOff = YES;
        [self.navigationController pushViewController:map animated:YES];
    }];
    
    [self.tableView setTableFooterView:headerView];
}

- (void)backToPreControl:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self updateEndCharge];
    }
}

#pragma mark - 司机端结束计费接口
- (void)updateEndCharge
{
//    [self testSelecter];
//    return;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在提交...";
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dic = @{@"cmd":@"updateEndCharge",@"token":userInfo.token,@"version":app_Version,@"params":@{@"orderNo":_orderInfo.orderNo,@"arriveDestinationMiles":[[NSNumber numberWithDouble:floor(_distanse * 1000)] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"updateEndCharge"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateEndChargeFinish:error Data:data];
        });
    }];
}

- (void)updateEndChargeFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        OrderPayController *payCon = [[OrderPayController alloc] init];
        payCon.orderInfo = self.orderInfo;
        id detail = [result valueForKey:@"detail"];
        PayChargeInfo *charge = [[PayChargeInfo alloc] initWithDictionary:detail error:nil];
        payCon.payCharge = charge;
        [self.navigationController pushViewController:payCon animated:YES];
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
    NSString *cellId = (indexPath.section == 0) ? NSStringFromClass([OrderPersonCell class]) : NSStringFromClass([OrderBillingCell class]);
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
            cell = [[OrderBillingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
    }
    if (indexPath.section == 0) {
        OrderPersonCell *personCell = (OrderPersonCell *)cell;
        [personCell.headImg sd_setImageWithURL:[NSURL URLWithString:_orderInfo.applyHeadImg ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
        [personCell.nameLab setText:(_orderInfo.applyName.length > 0) ? _orderInfo.applyName : @"匿名"];
        
    }
    else{
        OrderBillingCell *billingCell = (OrderBillingCell *)cell;
        NSString *orderNo = _orderInfo.orderNo ?: @"";
        if (orderNo.length > 8) {
            orderNo = [orderNo substringFromIndex:orderNo.length - 8];
        }
        [billingCell.orderNumberLab setText:[@"订单号:" stringByAppendingString:orderNo]];
        [billingCell.orderStateLab setText:([_orderInfo.isDispatcher integerValue] == 0) ? @"即时单" : @"指派单"];
        NSString *fromAddr = (_orderInfo.startTime.length > 0) ? [[[_orderInfo.startTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.fromAddr]] : _orderInfo.fromAddr;
        NSString *toAddr = (_orderInfo.arriveTime.length > 0) ? [[[_orderInfo.arriveTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.toAddr]] : _orderInfo.toAddr;
        [billingCell.getOnLab setText:fromAddr];
        [billingCell.getOffLab setText:toAddr];
        
        //CLLocation
//        CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.fromLat doubleValue] longitude:[_orderInfo.fromLon doubleValue]];
//        CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.toLat doubleValue] longitude:[_orderInfo.toLon doubleValue]];
//        CLLocationDistance route = [fromLocation distanceFromLocation:toLocation]/1000;
//        CLLocationDistance routeTime = route * 60 / 35;
        
        [billingCell.routeLab setText:[NSString stringWithFormat:@"当前行程%.1f公里,花费%.1f分钟",_distanse,_expandTime / 60]];
        //[billingCell.priceLab setText:_detailInfo.estimateCost ?: @"0.0"];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    if (!_billingCell) {
        _billingCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OrderBillingCell class])];
        _billingCell.tag = -1000;
    }
    
    // 判断高度是否已经计算过
    if (_cellHei <= 0) {
        // 填充数据
        [_billingCell.routeLab setText:@"当前形成9.8公里,花费20分钟"];
        //[_billingCell.priceLab setText:@"69.9"];
        
        // 根据当前数据，计算Cell的高度，注意+1
        _cellHei = [_billingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    return _cellHei;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *billingHeaderCellId = @"billingHeaderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:billingHeaderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:billingHeaderCellId];
        headerView.contentView.backgroundColor = self.view.backgroundColor;
    }
    
    return headerView;
}

@end
