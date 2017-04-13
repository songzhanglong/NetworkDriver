//
//  CouponDetailViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponDetailViewController.h"
#import "CouponDetailViewCell.h"
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "CouponDetailPerDay.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import "OrderDetailInfo.h"
#import "OrderInformation.h"
#import "CTMediator+Order.h"

static const NSString *conDetailInfo  = @"detailInfo";

@interface CouponDetailViewController ()

@property (nonatomic,strong)NSMutableArray *dataSource;

@end

@implementation CouponDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"queryDriverWalletDetail",@"token":userInfo.token,@"version":app_Version,@"params":@{@"userId":userInfo.userId,@"day":_curDate}};
    dic = [NSString convertDicToStr:dic];
    [self createTableViewAndRequestAction:@"queryDriverWalletDetail" Param:dic];
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setRowHeight:56];
    
    [self createTableRefreshView:YES];
    [self beginRefresh];
}

#pragma mark - Private Methods
- (void)createTableFooterView
{
    if ([self.dataSource count] > 0) {
        [self.tableView setTableFooterView:[UIView new]];
        return;
    }
    
    CGFloat itemHei = 240;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
    
    //middle
    UIView *middleView = [UIView new];
    [headerView addSubview:middleView];
    [middleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(headerView.mas_centerX);
        make.centerY.equalTo(headerView.mas_centerY);
    }];
    
    UIImageView *faceCry = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_cryface.png"]];
    [middleView addSubview:faceCry];
    [faceCry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.centerX.equalTo(middleView.mas_centerX);
    }];
    
    UILabel *orderNum = [[UILabel alloc] init];
    [orderNum setFont:MiddleFont];
    [orderNum setTextColor:[UIColor blackColor]];
    [orderNum setText:@"暂无数据，下拉试试"];
    [middleView addSubview:orderNum];
    [orderNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(faceCry.mas_bottom).with.offset(16);
        make.centerX.equalTo(middleView.mas_centerX);
        make.width.equalTo(middleView.mas_width);
        make.bottom.equalTo(middleView.mas_bottom);
    }];
    
    [self.tableView setTableFooterView:headerView];
}

#pragma mark - 接口配置
- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        NSArray *orderList = [detail valueForKey:@"dataList"];
        self.dataSource = [CouponDetailPerDay arrayOfModelsFromDictionaries:orderList error:nil];
        [self.tableView reloadData];
    }
    
    [self createTableFooterView];
}

#pragma mark - 订单详情接口
- (void)queryOrderDetail:(NSString *)orderNo
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.dimBackground = YES;
    hud.labelText = @"正在请求...";
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    NSDictionary *dic = @{@"cmd":@"queryOrderDetail",@"token":userInfo.token,@"version":app_Version,@"params":@{@"driverId":userInfo.userId,@"orderNo":orderNo,@"mapType":@"baidu"}};
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

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *coupouDetailCellId = @"coupouDetailCellId";
    CouponDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:coupouDetailCellId];
    if (cell == nil) {
        cell = [[CouponDetailViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:coupouDetailCellId];
    }
    
    CouponDetailPerDay *detail = self.dataSource[indexPath.row];
    NSString *orderNo = detail.orderNo ?: @"";
    if (orderNo.length > 8) {
        orderNo = [orderNo substringFromIndex:orderNo.length - 8];
    }
    cell.numberLab.text = [@"订单编号 " stringByAppendingString:orderNo];
    cell.priceLab.text = [([detail.income stringValue] ?: @"0") stringByAppendingString:@"元"];
    [cell.timeLab setText:detail.time];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CouponDetailPerDay *detail = self.dataSource[indexPath.row];
    [self queryOrderDetail:detail.orderNo];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = rgba(249, 249, 249, 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([self.dataSource count] > 0) ? 12 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *couponDetailHeaderCellId = @"couponDetailHeaderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:couponDetailHeaderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:couponDetailHeaderCellId];
        headerView.contentView.backgroundColor = self.view.backgroundColor;
    }
    
    return headerView;
}

@end
