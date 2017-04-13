//
//  MsgCenterViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MsgCenterViewController.h"
#import "MsgCenterCell.h"
#import "MsgItem.h"
#import "GlobalManager.h"
#import "NSString+Common.h"
#import <Masonry.h>

@interface MsgCenterViewController ()

@property (nonatomic,strong)MsgCenterCell *msgCell;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic,assign)NSInteger pageNo;
@property (nonatomic,assign)NSInteger numPerPage;

@end

@implementation MsgCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"消息中心";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    _pageNo = 1,_numPerPage = 20;
    
    [self createTableViewAndRequestAction:@"queryMsgList" Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.estimatedRowHeight = 90;
    self.tableView.sectionHeaderHeight = 12;
    
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    if ([UIDevice currentDevice].systemVersion.integerValue > 7) {
        self.tableView.rowHeight = UITableViewAutomaticDimension;
    }
#endif
    [self.tableView registerClass:[MsgCenterCell class] forCellReuseIdentifier:NSStringFromClass([MsgCenterCell class])];

    [self createTableRefreshView:YES];
    [self beginRefresh];
}

#pragma mark - Private methods
- (void)createTableFooterView
{
    if ([self.dataArr count] > 0) {
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
    NSDictionary *dic = @{@"cmd":@"queryMsgList",@"token":userInfo.token,@"version":app_Version,@"params":@{@"onePageNum":pageCount,@"pageNo":pageNo,@"userId":userInfo.userId}};
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
        NSArray *msgList = [detail valueForKey:@"dataList"];
        self.dataArr = [MsgItem arrayOfModelsFromDictionaries:msgList error:nil];
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
        
        NSArray *msgList = [detail valueForKey:@"dataList"];
        NSMutableArray *items = [MsgItem arrayOfModelsFromDictionaries:msgList error:nil];
        NSInteger curSec = [self.dataArr count];
        NSMutableArray *indexPaths = [NSMutableArray array];
        for (NSInteger i = 0; i < [items count]; i++) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:curSec++]];
        }
        [self.dataArr addObjectsFromArray:items];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_dataArr count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = NSStringFromClass([MsgCenterCell class]);
    MsgCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[MsgCenterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [cell resetMsgItem:_dataArr[indexPath.section]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef IOS_8_NEW_FEATURE_SELF_SIZING
    // iOS 8 的Self-sizing特性
    return UITableViewAutomaticDimension;
#else
    if (!_msgCell) {
        _msgCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([MsgCenterCell class])];
        _msgCell.tag = -1000;
    }
    
    // 获取对应的数据
    MsgItem *item = _dataArr[indexPath.section];
    // 判断高度是否已经计算过
    if (item.itemHei <= 0) {
        // 填充数据
        [_msgCell resetMsgItem:item];
        // 根据当前数据，计算Cell的高度，注意+1
        item.itemHei = [_msgCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 0.5f;
    }
    
    return item.itemHei;
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


@end
