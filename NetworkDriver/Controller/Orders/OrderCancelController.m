//
//  OrderCancelController.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderCancelController.h"
#import "OrderPersonCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderInformation.h"
#import "OrderDetailInfo.h"
#import "GlobalManager.h"

@implementation OrderCancelController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"订单取消";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    [self initialNavRightItem];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.rowHeight = 80;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initialTableFootView];
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
    CGFloat itemHei = 240;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
    UIImageView *faceCry = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_cryface.png"]];
    [headerView addSubview:faceCry];
    [faceCry mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@36);
        make.centerX.equalTo(headerView.mas_centerX);
    }];
    
    UILabel *orderNum = [[UILabel alloc] init];
    [orderNum setFont:MiddleFont];
    [orderNum setTextColor:[UIColor blackColor]];
    NSString *orderNo = _orderInfo.orderNo ?: @"";
    if (orderNo.length > 8) {
        orderNo = [orderNo substringFromIndex:orderNo.length - 8];
    }
    [orderNum setText:[@"当前订单 " stringByAppendingString:orderNo]];
    [headerView addSubview:orderNum];
    [orderNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(faceCry.mas_bottom).with.offset(16);
        make.centerX.equalTo(headerView.mas_centerX);
    }];
    
    UILabel *cancelSeason = [[UILabel alloc] init];
    [cancelSeason setFont:MiddleFont];
    [cancelSeason setTextColor:[UIColor blackColor]];
    [cancelSeason setText:@"乘客取消：我已选择其他交通工具"];
    [headerView addSubview:cancelSeason];
    [cancelSeason mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(orderNum.mas_bottom).with.offset(8);
        make.centerX.equalTo(headerView.mas_centerX);
    }];
    
    [self.tableView setTableFooterView:headerView];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([OrderPersonCell class]);
    OrderPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[OrderPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        [[((OrderPersonCell *)cell).phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            UIWebView*callWebview =[[UIWebView alloc] init];
            NSString *url = [NSString stringWithFormat:@"tel:%@",_orderInfo.applyPhone];
            NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
            [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
            [self.view addSubview:callWebview];
        }];
    }
    
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:_orderInfo.applyHeadImg ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
    [cell.nameLab setText:(_orderInfo.applyName.length > 0) ? _orderInfo.applyName : @"匿名"];
    
    return cell;
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
