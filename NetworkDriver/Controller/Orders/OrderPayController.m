//
//  OrderPayController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPayController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderPaySucController.h"
#import "OrderInformation.h"
#import <IQKeyboardManager.h>
#import <MBProgressHUD.h>
#import "GlobalManager.h"
#import "NSString+Common.h"
#import "HomePageViewController.h"
#import "OrderCancelController.h"
#import "OrderPersonCell.h"
#import "OrderPriceViewCell.h"
#import "OrderPriceEditCell.h"

@interface OrderPayController ()<UIAlertViewDelegate>

@end

@implementation OrderPayController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Grab_Cancel object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"费用结算";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orderCancelFromPassenger:) name:Order_Grab_Cancel object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self initialTableheaderView];
    [self initialTableFootView];
}

- (void)testSelecter
{
    OrderPaySucController *suc = [[OrderPaySucController alloc] init];
    suc.payCharge = _payCharge;
    suc.orderInfo = _orderInfo;
    [self.navigationController pushViewController:suc animated:YES];
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
- (void)initialTableheaderView
{
    /*
     CGFloat itemHei = 56.0;
     UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
     
     UILabel *lab = [[UILabel alloc] init];
     [lab setTextColor:BASELINE_COLOR];
     [lab setFont:BigFont];
     [headerView addSubview:lab];
     
     NSString *labStr = [NSString stringWithFormat:@"费用总计%@元",_payCharge.cost];
     NSRange range = [labStr rangeOfString:_payCharge.cost];
     NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:labStr];
     [attributeStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:30] range:range];
     [lab setAttributedText:attributeStr];
     
     [lab mas_makeConstraints:^(MASConstraintMaker *make) {
     make.centerX.equalTo(headerView.mas_centerX);
     make.centerY.equalTo(headerView.mas_centerY).with.offset(6);
     }];
     
     [self.tableView setTableHeaderView:headerView];
     */
}

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
    [sureBtn setTitle:@"确认" forState:UIControlStateNormal];
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
        [[IQKeyboardManager sharedManager] resignFirstResponder];
        Class actionClass = NSClassFromString(@"UIAlertController");
        if (actionClass) {
            UIAlertController *alertController = [actionClass alertControllerWithTitle:@"乘客费用及支付" message:@"请您确认费用无误,并提示乘客先付款后下车!" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self updateConfirmCost];
            }]];
            [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"乘客费用及支付" message:@"请您确认费用无误,并提示乘客先付款后下车!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            [alert show];
        }
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
        [self updateConfirmCost];
    }
}

#pragma mark - 司机端结束计费接口
- (void)updateConfirmCost
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
    
    CLLocation *fromLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.fromLat doubleValue] longitude:[_orderInfo.fromLon doubleValue]];
    CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:[_orderInfo.toLat doubleValue] longitude:[_orderInfo.toLon doubleValue]];
    CLLocationDistance route = floor([fromLocation distanceFromLocation:toLocation]);
    CLLocationDistance routeTimer = floor(route * 60 / (1000 * 35));
    HomePageViewController *home = [self.navigationController.viewControllers firstObject];
    BMKUserLocation *userLocation = home.locationManager.userLocation;
    
    //总价
    CGFloat totalPrice = 0;
    for (NSInteger i = 0; i < [_payCharge.costDetail count]; i++) {
        NSArray *subArr = _payCharge.costDetail[i];
        totalPrice += [subArr[1] floatValue];
    }
    
    NSDictionary *dic = @{@"cmd":@"updateConfirmCost",@"token":userInfo.token,@"version":app_Version,@"params":@{@"orderNo":_orderInfo.orderNo,@"mapType": @"baidu",@"address":_orderInfo.toAddr,@"Lon":[[NSNumber numberWithDouble:userLocation.location.coordinate.longitude] stringValue],@"Lat":[[NSNumber numberWithDouble:userLocation.location.coordinate.latitude] stringValue],@"arriveDestinationMiles":[[NSNumber numberWithDouble:route] stringValue],@"arriveDestinationTimes":[[NSNumber numberWithDouble:routeTimer] stringValue],@"cost":[[NSNumber numberWithFloat:totalPrice] stringValue],@"costDetail":_payCharge.costDetail}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"updateConfirmCost"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf updateConfirmCostFinish:error Data:data];
        });
    }];
}

- (void)updateConfirmCostFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        LocationManager *locationMana = (LocationManager *)((HomePageViewController *)self.navigationController.viewControllers.firstObject).locationManager;
        [locationMana endLocationUpload];
        
        OrderPaySucController *suc = [[OrderPaySucController alloc] init];
        suc.payCharge = _payCharge;
        suc.orderInfo = _orderInfo;
        [self.navigationController pushViewController:suc animated:YES];
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
    return [_payCharge.costDetail count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = nil;
    if (indexPath.section == 0) {
        cellId = NSStringFromClass([OrderPersonCell class]);
    }
    else
    {
        if (indexPath.row == 0) {
            cellId = NSStringFromClass([UITableViewCell class]);
        }
        else{
            NSArray *array = [_payCharge.costDetail objectAtIndex:indexPath.row - 1];
            //变量ID
            NSString *chargeId = array[4];
            BOOL isOther = [chargeId isEqualToString:@"vd0024"];
            cellId = isOther ? NSStringFromClass([OrderPriceEditCell class]) : NSStringFromClass([OrderPriceViewCell class]);
        }
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        if (indexPath.section == 0) {
            cell = [[OrderPersonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            @weakify(self);
            [[((OrderPersonCell *)cell).phoneBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
                @strongify(self);
                UIWebView*callWebview =[[UIWebView alloc] init];
                NSString *url = [NSString stringWithFormat:@"tel:%@",self.orderInfo.applyPhone];
                NSURL *telURL = [NSURL URLWithString:url];// 貌似tel:// 或者 tel: 都行
                [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
                [self.view addSubview:callWebview];
            }];
        }
        else {
            if (indexPath.row == 0) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.font = [UIFont systemFontOfSize:30];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
            }
            else{
                NSInteger subIdx = indexPath.row - 1;
                NSArray *array = [_payCharge.costDetail objectAtIndex:subIdx];
                //变量ID
                NSString *chargeId = array[4];
                BOOL isOther = [chargeId isEqualToString:@"vd0024"];
                if (isOther) {
                    cell = [[OrderPriceEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                    UITextField *textField = ((OrderPriceEditCell *)cell).textField;
                    [textField setText:array[1]];
                    [textField.rac_textSignal subscribeNext:^(NSString *x) {
                        NSArray *detailArr = [self.payCharge.costDetail objectAtIndex:subIdx];
                        NSString *price = detailArr[1];
                        if (![price isEqualToString:x]) {
                            NSMutableArray *newArr = [NSMutableArray arrayWithArray:detailArr];
                            [newArr replaceObjectAtIndex:1 withObject:x];
                            [self.payCharge.costDetail replaceObjectAtIndex:subIdx withObject:newArr];
                        }
                    }];
                }
                else{
                    cell = [[OrderPriceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                }
            }
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.section == 0) {
        OrderPersonCell *personCell = (OrderPersonCell *)cell;
        [personCell.headImg sd_setImageWithURL:[NSURL URLWithString:_orderInfo.applyHeadImg ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
        [personCell.nameLab setText:(_orderInfo.applyName.length > 0) ? _orderInfo.applyName : @"匿名"];
    }
    else {
        if (indexPath.row == 0) {
            UITableViewCell *immeCell = (UITableViewCell *)cell;
            NSString *lstStr = _payCharge.cost;
            NSString *newStr = [lstStr stringByAppendingString:@"元"];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:newStr];
            [attrStr addAttribute:NSFontAttributeName value:MiddleFont range:NSMakeRange(newStr.length - 1, 1)];
            [immeCell.textLabel setAttributedText:attrStr];
        }
        else{
            
            NSArray *array = [_payCharge.costDetail objectAtIndex:indexPath.row - 1];
            NSString *leftStr = [array firstObject];
            //变量ID
            NSString *chargeId = array[4];
            BOOL isOther = [chargeId isEqualToString:@"vd0024"];
            if (isOther) {
                OrderPriceEditCell *editCell = (OrderPriceEditCell *)cell;
                editCell.leftLab.text = leftStr;
            }
            else{
                NSString *rightStr = ([array[6] length] > 0) ? [NSString stringWithFormat:@"%@=%@元",array[6],array[1]] : [array[1] stringByAppendingString:@"元"];
                OrderPriceViewCell *priceCell = (OrderPriceViewCell *)cell;
                [priceCell resetLeftTip:leftStr Price:rightStr];
            }
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }
    else {
        if (indexPath.row == 0) {
            return 55;
        }
        return 35;
    }
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
