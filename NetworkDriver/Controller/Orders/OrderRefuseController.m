//
//  OrderRefuseController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderRefuseController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderRefuseCell.h"
#import "GlobalManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HomePageViewController.h"
#import "OrderImmediatelyController.h"
#import "OrderCancelController.h"

@implementation OrderRefuseController
{
    NSInteger _checkIdx;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"拒绝接单";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCancelFromPassenger:) name:Order_Grab_Cancel object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self initialTableFootView];
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
- (void)initialTableFootView
{
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei + 35)];
    
    //sure
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sureBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [sureBtn.layer setMasksToBounds:YES];
    [sureBtn.layer setCornerRadius:itemHei / 2];
    [sureBtn.titleLabel setFont:MiddleFont];
    [sureBtn setTitle:@"提交" forState:UIControlStateNormal];
    [sureBtn setBackgroundColor:BASELINE_COLOR];
    [headerView addSubview:sureBtn];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(headerView.mas_bottom);
        make.height.equalTo(@(itemHei));
        make.left.equalTo(@25);
        make.right.equalTo(headerView.mas_right).with.offset(-25);
    }];
    @weakify(self);
    [[sureBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        if ([[GlobalManager shareInstance].appInit.reassignmentList count] > 0) {
            [self refuseOrder];
        }
    }];
    
    [self.tableView setTableFooterView:headerView];
}

- (void)backToPreControl:(id)sender {
    NSArray *controllers = self.navigationController.viewControllers;
    UIViewController *preCon = controllers[controllers.count - 2];
    if ([preCon isKindOfClass:[OrderImmediatelyController class]]) {
        OrderImmediatelyController *immediateCon = (OrderImmediatelyController *)preCon;
        if (immediateCon.maxSeconds < 0) {
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 司机取消
- (void)refuseOrder
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在提交...";
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    LocationManager *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager;
    NSDictionary *dic = @{@"cmd":@"reassignment",@"token":userInfo.token,@"version":app_Version,@"params":@{@"orderNo":_orderInfo.orderNo,@"reassignment":[GlobalManager shareInstance].appInit.reassignmentList[_checkIdx],@"mapType":@"baidu",@"Lon":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.longitude] stringValue],@"Lat":[[NSNumber numberWithDouble:location.userLocation.location.coordinate.latitude] stringValue]}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"reassignment"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf refuseOrderFinish:error Data:data];
        });
    }];
}

- (void)refuseOrderFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        HomePageViewController *home = (HomePageViewController *)[self.navigationController.viewControllers firstObject];
        if ([_orderInfo.orderNo isEqualToString:home.grabOrder.orderNo]) {
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
    return [[GlobalManager shareInstance].appInit.reassignmentList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([OrderRefuseCell class]);
    OrderRefuseCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[OrderRefuseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    OrderRefuseCell *refuseCell = (OrderRefuseCell *)cell;
    NSArray *arr = [GlobalManager shareInstance].appInit.reassignmentList;
    [refuseCell.reasonLab setText:arr[indexPath.row]];
    refuseCell.checkBtn.selected = (indexPath.row == _checkIdx);
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row != _checkIdx) {
        NSInteger preIdx = _checkIdx;
        _checkIdx = indexPath.row;
        [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:preIdx inSection:1],indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *refuseHeaderCellId = @"refuseHeaderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:refuseHeaderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:refuseHeaderCellId];
        headerView.contentView.backgroundColor = self.view.backgroundColor;
        UILabel *label = [[UILabel alloc] init];
        [label setText:@"请选择原因帮助我们优化派单系统"];
        [label setTextColor:[UIColor darkGrayColor]];
        [label setFont:SmallFont];
        [headerView.contentView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(headerView.contentView.mas_centerX);
            make.centerY.equalTo(headerView.contentView.mas_centerY);
        }];
    }
    
    return headerView;
}

@end
