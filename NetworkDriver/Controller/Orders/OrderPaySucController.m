//
//  OrderPaySucController.m
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderPaySucController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderInformation.h"
#import "GlobalManager.h"
#import "OrderFinishViewController.h"
#import "OrderPersonCell.h"
#import "OrderPriceViewCell.h"
#import "OrderPriceEditCell.h"

@interface OrderPaySucController ()

@end

@implementation OrderPaySucController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:Order_Pay object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"等待乘客支付";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePayOrderNotification:) name:Order_Pay object:nil];
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.sectionHeaderHeight = 12;
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //[self testSelecter];
}

- (void)testSelecter
{
    __weak typeof(self)weakSelf = self;
    double delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^{
        OrderFinishViewController *finish = [[OrderFinishViewController alloc] init];
        finish.payCharge = _payCharge;
        [weakSelf.navigationController pushViewController:finish animated:YES];
    });
}

#pragma mark - notifi
- (void)receivePayOrderNotification:(NSNotification *)notifi
{
    NSDictionary *dic = [notifi object];
    if ([_orderInfo.orderNo isEqualToString:[dic valueForKey:@"orderNo"]]) {
        NSInteger msgType = [[dic valueForKey:@"msgType"] integerValue];
        if ((msgType >= 11) && (self.navigationController.topViewController == self)) {
            OrderFinishViewController *finish = [[OrderFinishViewController alloc] init];
            finish.payCharge = _payCharge;
            [self.navigationController pushViewController:finish animated:YES];
        }
        [[GlobalManager shareInstance].userInfo setOrderNo:nil];
    }
}

#pragma mark - Private Methods
- (void)backToPreControl:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
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
                    textField.enabled = NO;
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
            CGFloat totalPrice = 0;
            for (NSInteger i = 0; i < [_payCharge.costDetail count]; i++) {
                NSArray *subArr = _payCharge.costDetail[i];
                totalPrice += [subArr[1] floatValue];
            }
            NSString *newStr = [[[NSNumber numberWithFloat:totalPrice] stringValue] stringByAppendingString:@"元"];
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
