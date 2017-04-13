//
//  OrdersViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrdersViewController.h"
#import "OrderOfMineCell.h"
#import <Masonry.h>
#import "OrderInformation.h"
#import "CTMediator+Order.h"
#import "NSString+Common.h"
#import "GlobalManager.h"

@interface OrdersViewController ()

@property (nonatomic,strong)OrderOfMineCell *msgCell;
@property (nonatomic,strong)NSArray *dataSource;
@property (nonatomic,assign)NSInteger pageNo;
@property (nonatomic,assign)NSInteger numPerPage;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = _isCurrent ? @"未完成订单" : @"已完成订单";
    
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    _pageNo = 1,_numPerPage = 20;
    
    [self createTableViewAndRequestAction:@"queryMyOrderList" Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.sectionHeaderHeight = 42;
    self.tableView.estimatedRowHeight = 130;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
#endif
    
    [self.tableView registerClass:[OrderOfMineCell class] forCellReuseIdentifier:NSStringFromClass([OrderOfMineCell class])];
    [self createTableRefreshView:YES];
    [self beginRefresh];
}

#pragma mark - Private methods
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
- (void)resetRequestParam
{
    NSString *pageNo = [NSString stringWithFormat:@"%ld",(long)_pageNo];
    NSString *pageCount = [NSString stringWithFormat:@"%ld",(long)_numPerPage];
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"queryMyOrderList",@"token":userInfo.token,@"version":app_Version,@"params":@{@"onePageNum":pageCount,@"pageNo":pageNo,@"driverId":userInfo.userId,@"isCurrent":_isCurrent ? @"1" : @"0",@"needInvoice":@"0",@"orderType":@"1"}};
    dic = [NSString convertDicToStr:dic];
    self.param = dic;
}

- (BOOL)startPullRefresh
{
    if ([self.tableView.mj_footer isRefreshing]) {
        [self.tableView.mj_header endRefreshing];
        return NO;
    }
    _pageNo = 1;
    return [super startPullRefresh];
}

- (BOOL)startPullRefresh2
{
    if ([self.tableView.mj_header isRefreshing]) {
        [self.tableView.mj_footer endRefreshing];
        return NO;
    }
    _pageNo++;
    return [super startPullRefresh2];
}

- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    
    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        NSInteger pages = [[detail valueForKey:@"pages"] integerValue];
        if (pages <= _pageNo) {
            [self removeTableRefreshView:NO];
        }
        else{
            [self createTableRefreshView:NO];
        }
        NSArray *orderList = [detail valueForKey:@"dataList"];
        NSMutableArray *arrayOfNet = [OrderInformation arrayOfModelsFromDictionaries:orderList error:nil];
        //先排序，再遍历
        NSArray *sortArr = [arrayOfNet sortedArrayUsingComparator:^NSComparisonResult(OrderInformation *  _Nonnull obj1, OrderInformation *  _Nonnull obj2) {
            return [obj2.applyTime compare:obj1.applyTime];
        }];
        
        NSMutableArray *lastArr = [NSMutableArray array];
        for (NSInteger i = 0; i < [sortArr count]; i++) {
            if ([lastArr count] == 0) {
                [lastArr addObject:[NSMutableArray array]];
            }
            NSMutableArray *preArr = [lastArr lastObject];
            if ([preArr count] == 0) {
                [preArr addObject:sortArr[i]];
            }
            else{
                OrderInformation *curItem = sortArr[i];
                NSString *curStr = [[curItem.applyTime componentsSeparatedByString:@" "] firstObject];
                OrderInformation *preItem = [preArr lastObject];
                NSString *preStr = [[preItem.applyTime componentsSeparatedByString:@" "] firstObject];
                if ([curStr isEqualToString:preStr]) {
                    [preArr addObject:curItem];
                }
                else{
                    [lastArr addObject:[NSMutableArray arrayWithObject:curItem]];
                }
            }
        }
        
        self.dataSource = lastArr;
        [self.tableView reloadData];
    }
    
    [self createTableFooterView];
}

- (void)requestFinish2:(NSError *)error Data:(id)result
{
    [super requestFinish2:error Data:result];

    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        NSInteger pages = [[detail valueForKey:@"pages"] integerValue];
        if (pages <= _pageNo) {
            [self removeTableRefreshView:NO];
        }

        NSArray *orderList = [detail valueForKey:@"dataList"];

        //数据统一
        NSMutableArray *arrayOfNet = [OrderInformation arrayOfModelsFromDictionaries:orderList error:nil];
        for (NSArray *subArr in self.dataSource) {
            [arrayOfNet addObjectsFromArray:subArr];
        }
        //先排序，再遍历
        NSArray *sortArr = [arrayOfNet sortedArrayUsingComparator:^NSComparisonResult(OrderInformation *  _Nonnull obj1, OrderInformation *  _Nonnull obj2) {
            return [obj2.applyTime compare:obj1.applyTime];
        }];
        
        NSMutableArray *lastArr = [NSMutableArray array];
        for (NSInteger i = 0; i < [sortArr count]; i++) {
            if ([lastArr count] == 0) {
                [lastArr addObject:[NSMutableArray array]];
            }
            NSMutableArray *preArr = [lastArr lastObject];
            if ([preArr count] == 0) {
                [preArr addObject:sortArr[i]];
            }
            else{
                OrderInformation *curItem = sortArr[i];
                NSString *curStr = [[curItem.applyTime componentsSeparatedByString:@" "] firstObject];
                OrderInformation *preItem = [preArr lastObject];
                NSString *preStr = [[preItem.applyTime componentsSeparatedByString:@" "] firstObject];
                if ([curStr isEqualToString:preStr]) {
                    [preArr addObject:curItem];
                }
                else{
                    [lastArr addObject:[NSMutableArray arrayWithObject:curItem]];
                }
            }
        }
        self.dataSource = lastArr;
        [self.tableView reloadData];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataSource objectAtIndex:section];
    return [arr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([OrderOfMineCell class]);
    OrderOfMineCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[OrderOfMineCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSArray *arr = [self.dataSource objectAtIndex:indexPath.section];
    [cell setupData:arr[indexPath.row] Last:([arr count] - 1 == indexPath.row)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *arr = [self.dataSource objectAtIndex:indexPath.section];
    
    OrderInformation *item = arr[indexPath.row];
    UIViewController *con = [[CTMediator sharedInstance] CTMediator_viewControllerForOrder:item];
    if (con) {
        [self.navigationController pushViewController:con animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    return UITableViewAutomaticDimension;
#else
    if (!_msgCell) {
        _msgCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([OrderOfMineCell class])];
        _msgCell.tag = -1000;
    }
    
    // 获取对应的数据
    NSArray *arr = [self.dataSource objectAtIndex:indexPath.section];
    OrderInformation *item = arr[indexPath.row];
    // 判断高度是否已经计算过
    if (item.itemHei <= 0) {
        // 填充数据
        [_msgCell setupData:item Last:(arr.count - 1 == indexPath.row)];
        // 根据当前数据，计算Cell的高度，注意+1
        item.itemHei = [_msgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    }
    
    return item.itemHei;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *orderCellId = @"orderCellId";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:orderCellId];
    if (headerView == nil) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:orderCellId];
        //img
        UIImageView *leftImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_timer.png"]];
        [headerView.contentView addSubview:leftImg];
        [leftImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15));
            make.centerY.equalTo(headerView.mas_centerY);
        }];
        //time
        UILabel *timeLab = [[UILabel alloc] init];
        [timeLab setTag:1];
        [timeLab setFont:MiddleFont];
        [timeLab setTextColor:[UIColor blackColor]];
        [headerView.contentView addSubview:timeLab];
        [timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(leftImg.mas_right).with.offset(5);
            make.centerY.equalTo(leftImg.mas_centerY);
        }];
    }
    
    UILabel *timeLab = (UILabel *)[headerView.contentView viewWithTag:1];
    NSArray *arr = [self.dataSource objectAtIndex:section];
    OrderInformation *info = [arr firstObject];
    if (info.applyTime.length > 0) {
        [timeLab setText:[[info.applyTime componentsSeparatedByString:@" "] firstObject]];
    }
    else{
        [timeLab setText:@"--"];
    }
    
    return headerView;
}

@end
