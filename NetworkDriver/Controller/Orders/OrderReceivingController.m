//
//  OrderReceivingController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderReceivingController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderInformation.h"
#import "GlobalManager.h"
#import "MapViewController.h"
#import <MBProgressHUD.h>
#import "HomePageViewController.h"
#import "NSString+Common.h"

@implementation OrderReceivingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"已接单";
}

- (void)testSelecter
{
    OrderWaitPassengerController *wait = [[OrderWaitPassengerController alloc] init];
    wait.orderInfo = self.orderInfo;
    [self.navigationController pushViewController:wait animated:YES];
}

#pragma mark - Private Methods
- (void)initialTableFootView
{
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    UIImageView *addressImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_location.png"]];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20 + addressImg.image.size.height + 30 + itemHei + 15 + itemHei)];
    
    UIView *topView = [UIView new];
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
    HomePageViewController *homePage = [self.navigationController.viewControllers firstObject];
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[self.orderInfo.fromLat doubleValue] longitude:[self.orderInfo.fromLon doubleValue]];
    CLLocationDistance distance = [homePage.locationManager.userLocation.location distanceFromLocation:fromLocation] / 1000;
    CLLocationDistance distanceTime = distance * 60 / 35;
    [label setText:[NSString stringWithFormat:@"距离上车地点%.1f公里,大约需要%.1f分钟",distance,distanceTime]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:MiddleFont];
    [topView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(addressImg.mas_right).with.offset(5);
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
    [arriveBtn setTitle:@"我已抵达" forState:UIControlStateNormal];
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
        [self updateReachFromAddr];
    }];
    
    //getOn
    UIButton *getOnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [getOnBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [getOnBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [getOnBtn.layer setMasksToBounds:YES];
    [getOnBtn.layer setCornerRadius:itemHei / 2];
    [getOnBtn.titleLabel setFont:MiddleFont];
    [getOnBtn setTitle:@"导航至上车地点" forState:UIControlStateNormal];
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
        [self.navigationController pushViewController:map animated:YES];
    }];
    
    [self.tableView setTableFooterView:headerView];
}

#pragma mark - 抢单
- (void)updateReachFromAddr
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在提交...";
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    LocationManager *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager;
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *dic = @{@"cmd":@"updateReachFromAddr",@"token":userInfo.token,@"version":app_Version,@"params":@{@"orderNo":self.orderInfo.orderNo,@"mapType":@"baidu",@"Lon":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.longitude] stringValue],@"Lat":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.latitude] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"updateReachFromAddr"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateReachFromAddrFinish:error Data:data];
        });
    }];
}

- (void)updateReachFromAddrFinish:(NSError *)error Data:(id)result
{
//    [self testSelecter];
//    return;
    
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        OrderWaitPassengerController *wait = [[OrderWaitPassengerController alloc] init];
        wait.orderInfo = self.orderInfo;
        [self.navigationController pushViewController:wait animated:YES];
    }
}

@end
