//
//  OrderDoneController.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderDoneController.h"
#import "OrderAchieveCell.h"
#import "OrderPersonCell.h"
#import "OrderAppraiseCell.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "OrderRefuseController.h"
#import "OrderInformation.h"
#import "OrderDetailInfo.h"
#import "GlobalManager.h"
#import "OrderPriceViewCell.h"
#import "NSString+Common.h"

@interface OrderDoneController ()

@property (nonatomic,strong)OrderAchieveCell *immediatelyCell;
@property (nonatomic,assign)CGFloat cellHei;

@end

@implementation OrderDoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"订单详情";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    [self initialNavRightItem];
    
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
    
    [self.tableView registerClass:[OrderAchieveCell class] forCellReuseIdentifier:NSStringFromClass([OrderAchieveCell class])];
    
    [self queryOrderDetail];
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
    @weakify(self);
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
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

#pragma mark - 订单详情接口
- (void)queryOrderDetail
{
    if (_detailInfo || [_orderInfo.costDetail count] > 0) {
        return;
    }
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];

    NSDictionary *dic = @{@"cmd":@"queryOrderDetail",@"token":userInfo.token,@"version":app_Version,@"params":@{@"driverId":userInfo.userId,@"orderNo":_orderInfo.orderNo,@"mapType":@"baidu"}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"queryOrderDetail"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf grabOrderFinish:error Data:data];
        });
    }];
}

- (void)grabOrderFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        self.detailInfo = [[OrderDetailInfo alloc] initWithDictionary:detail error:nil];
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 1 + [_detailInfo.costDetail count];
    }
    return (_detailInfo.comment.length > 0) ? 2 : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = nil;
    switch (indexPath.section) {
        case 0:
        {
            cellId = NSStringFromClass([OrderPersonCell class]);
        }
            break;
        case 1:
        {
            cellId = (indexPath.row == 0) ? NSStringFromClass([OrderAchieveCell class]) : NSStringFromClass([OrderPriceViewCell class]);
        }
            break;
        case 2:
        {
            cellId = (indexPath.row == 0) ? NSStringFromClass([OrderAppraiseCell class]) : NSStringFromClass([UITableViewCell class]);
        }
            break;
        default:
            break;
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
        else if(indexPath.section == 1){
            if (indexPath.row == 0) {
                cell = [[OrderAchieveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            else{
                cell = [[OrderPriceViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
        }
        else{
            if (indexPath.row == 0) {
                cell = [[OrderAppraiseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            }
            else{
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
                cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
                cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
                
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.textColor = [UIColor darkGrayColor];
                cell.textLabel.highlightedTextColor = [UIColor whiteColor];
                cell.textLabel.font = MiddleFont;
                cell.textLabel.numberOfLines = 0;
                
                UIView *lineView = [UIView new];
                [lineView setBackgroundColor:[UIColor lightGrayColor]];
                [cell.contentView addSubview:lineView];
                [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(@25);
                    make.right.equalTo(cell.contentView.mas_right).with.offset(-25);
                    make.top.equalTo(@0);
                    make.height.equalTo(@1);
                }];
            }
        }
        
    }
    if (indexPath.section == 0) {
        OrderPersonCell *personCell = (OrderPersonCell *)cell;
        [personCell.headImg sd_setImageWithURL:[NSURL URLWithString:_orderInfo.applyHeadImg ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
        [personCell.nameLab setText:(_orderInfo.applyName.length > 0) ? _orderInfo.applyName : @"匿名"];
    }
    else if(indexPath.section == 1){
        if (indexPath.row == 0) {
            OrderAchieveCell *immeCell = (OrderAchieveCell *)cell;
            NSString *orderNo = _orderInfo.orderNo ?: @"";
            if (orderNo.length > 8) {
                orderNo = [orderNo substringFromIndex:orderNo.length - 8];
            }
            [immeCell.orderNumberLab setText:[@"订单号:" stringByAppendingString:orderNo]];
            [immeCell.orderStateLab setText:(_orderInfo.status.integerValue == 0) ? @"已过期" : @"已完成"];
            NSString *fromAddr = (_orderInfo.startTime.length > 0) ? [[[_orderInfo.startTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.fromAddr]] : _orderInfo.fromAddr;
            NSString *toAddr = (_orderInfo.arriveTime.length > 0) ? [[[_orderInfo.arriveTime componentsSeparatedByString:@" "] lastObject] stringByAppendingString:[@" " stringByAppendingString:_orderInfo.toAddr]] : _orderInfo.toAddr;
            [immeCell.getOnLab setText:fromAddr];
            [immeCell.getOffLab setText:toAddr];
            [immeCell.totalPrice setText:_orderInfo.cost.stringValue ?: @"0.0"];
        }
        else{
            OrderPriceViewCell *priceCell = (OrderPriceViewCell *)cell;
            NSArray *array = [_detailInfo.costDetail objectAtIndex:indexPath.row - 1];
            NSString *leftStr = [array firstObject],*rightStr = ([array[6] length] > 0) ? [NSString stringWithFormat:@"%@=%@元",array[6],array[1]] : [array[1] stringByAppendingString:@"元"];
            [priceCell resetLeftTip:leftStr Price:rightStr];
//            priceCell.leftLab.text = leftStr;
//            priceCell.rightLab.text = rightStr;
        }
    }
    else{
        if (indexPath.row == 0) {
            OrderAppraiseCell *appraiseCell = (OrderAppraiseCell *)cell;
            appraiseCell.markScore.score = [_detailInfo.starClass floatValue];
        }
        else{
            cell.textLabel.text = _detailInfo.comment;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 80;
    }
    else if (indexPath.section == 2){
        return (indexPath.row == 0) ? (120 - 44) : 44;
    }
    else if (indexPath.row != 0)
    {
        return 35;
    }
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    return UITableViewAutomaticDimension;
#else
    if (!_immediatelyCell) {
        _immediatelyCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OrderAchieveCell class])];
        _immediatelyCell.tag = -1000;
    }
    
    // 判断高度是否已经计算过
    if (_cellHei <= 0) {
        // 填充数据
        [_immediatelyCell.totalPrice setText:@"0.0"];
        
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
