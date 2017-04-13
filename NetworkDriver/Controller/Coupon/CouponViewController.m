//
//  CouponViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/24.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "CouponViewController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CouponViewCell.h"
#import "CouponDetailViewController.h"
#import "NSString+Common.h"
#import "GlobalManager.h"
#import "CouponOfMonth.h"

@interface CouponViewController ()

@property (nonatomic,strong)CouponOfMonth *couponOfMonth;
@property (nonatomic,strong)NSDate *curDate;

@end

@implementation CouponViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"我的钱包";
    
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    _curDate = [NSDate date];
    
    [self createTableViewAndRequestAction:@"queryDriverWallet" Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self createTableRefreshView:YES];
    [self beginRefresh];
}

#pragma mark - Private Methods
- (NSDate *)adjacentMonthOfDate:(NSInteger)month Date:(NSDate *)date
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = month;
    
    return [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:date options:0];
}

- (void)createTableHeaderView
{
    if ([self.couponOfMonth.dataList count] == 0) {
        CGFloat itemHei = 56;
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
        
        //content
        UIView *contentView = [UIView new];
        contentView.backgroundColor = rgba(249, 249, 249, 1);
        [headerView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.and.bottom.equalTo(headerView);
            make.top.equalTo(@12);
        }];
        
        //top
        [self createTopViewTo:contentView];
        [self.tableView setTableHeaderView:headerView];
        return;
    }
    CGFloat itemHei = 162;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemHei)];
    
    //content
    UIView *contentView = [UIView new];
    contentView.backgroundColor = rgba(249, 249, 249, 1);
    [headerView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(headerView);
        make.top.equalTo(@12);
    }];
    
    //top
    [self createTopViewTo:contentView];
    
    //bottom
    UIView *bottomLine = [[UIView alloc] init];
    [bottomLine setBackgroundColor:[UIColor lightGrayColor]];
    [contentView addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(contentView);
        make.left.equalTo(contentView.mas_left).with.offset(15);
        make.right.equalTo(contentView.mas_right).with.offset(-15);
        make.height.equalTo(@1);
    }];
    
    //content
    UIView *conView = [[UIView alloc] init];
    [contentView addSubview:conView];
    [conView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(contentView.mas_centerX);
        make.centerY.equalTo(contentView.mas_centerY).with.offset(22);
    }];
    
    //today month
    UILabel *todayMonth = [[UILabel alloc] init];
    [todayMonth setText:@"本月收入"];
    [todayMonth setFont:MiddleFont];
    [todayMonth setTextColor:[UIColor darkGrayColor]];
    [conView addSubview:todayMonth];
    [todayMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(conView.mas_centerX);
        make.top.equalTo(@0);
    }];
    //price
    UILabel *priceLab = [[UILabel alloc] init];
    NSString *priceStr = [([_couponOfMonth.income stringValue] ?: @"0") stringByAppendingString:@"元"];
    NSRange range = NSMakeRange(0, priceStr.length - 1);
    NSMutableAttributedString *attrNum = [[NSMutableAttributedString alloc] initWithString:priceStr];
    [attrNum addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:32] range:range];
    [priceLab setFont:MiddleFont];
    [priceLab setAttributedText:attrNum];
    [priceLab setTextColor:BASELINE_COLOR];
    [conView addSubview:priceLab];
    [priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(conView.mas_centerX);
        make.top.equalTo(todayMonth.mas_bottom).with.offset(12);
        make.width.equalTo(conView.mas_width);
        make.bottom.equalTo(conView.mas_bottom);
    }];
    
    [self.tableView setTableHeaderView:headerView];
}

- (void)createTopViewTo:(UIView *)father
{
    UIView *subView = [[UIView alloc] init];
    [father addSubview:subView];
    [subView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(father.mas_left).with.offset(15);
        make.right.equalTo(father.mas_right).with.offset(-15);
        make.height.equalTo(@44);
        make.top.equalTo(@0);
    }];
    
    //leftBtn
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftBtn setImage:[UIImage imageNamed:@"coupon_left.png"] forState:UIControlStateNormal];
    [subView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(subView.mas_centerY);
        make.left.equalTo(@0);
    }];
    @weakify(self);
    [[leftBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self requestAdjacentMonth:-1];
    }];
    //prelab
    UILabel *preMonth = [[UILabel alloc] init];
    NSDate *preDate = [self adjacentMonthOfDate:-1 Date:_curDate];
    NSString *preMonthStr = [NSString stringByDate:@"M月" Date:preDate];
    [preMonth setText:preMonthStr];
    [preMonth setFont:MiddleFont];
    [preMonth setTextColor:[UIColor darkGrayColor]];
    [subView addSubview:preMonth];
    [preMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftBtn.mas_right).with.offset(2);
        make.centerY.equalTo(leftBtn.mas_centerY);
    }];
    
    //centerlab
    UILabel *centerMonth = [[UILabel alloc] init];
    [centerMonth setText:[NSString stringByDate:@"yyyy年M月" Date:_curDate]];
    [centerMonth setFont:MiddleFont];
    [centerMonth setTextColor:[UIColor darkGrayColor]];
    [subView addSubview:centerMonth];
    [centerMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.and.centerX.equalTo(subView);
    }];
    
    //rightBtn
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBtn setImage:[UIImage imageNamed:@"coupon_right.png"] forState:UIControlStateNormal];
    [subView addSubview:rightBtn];
    [rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(leftBtn.mas_centerY);
        make.right.equalTo(subView.mas_right);
    }];
    [[rightBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self requestAdjacentMonth:1];
    }];
    //rightlab
    UILabel *rightMonth = [[UILabel alloc] init];
    NSDate *followingDate = [self adjacentMonthOfDate:1 Date:_curDate];
    NSString *followingStr = [NSString stringByDate:@"M月" Date:followingDate];
    [rightMonth setText:followingStr];
    [rightMonth setFont:MiddleFont];
    [rightMonth setTextColor:[UIColor darkGrayColor]];
    [subView addSubview:rightMonth];
    [rightMonth mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightBtn.mas_left).with.offset(-2);
        make.centerY.equalTo(leftBtn.mas_centerY);
    }];
    
    //line
    UIView *ligthGrayLine = [[UIView alloc] init];
    [ligthGrayLine setBackgroundColor:[UIColor lightGrayColor]];
    [subView addSubview:ligthGrayLine];
    [ligthGrayLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(subView);
        make.height.equalTo(@1);
    }];
}

- (void)createTableFooterView
{
    if ([self.couponOfMonth.dataList count] > 0) {
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

#pragma mark - actions
- (void)requestAdjacentMonth:(NSInteger)month
{
    _curDate = [self adjacentMonthOfDate:month Date:_curDate];
    [self.view makeToastActivity];
    self.tableView.userInteractionEnabled = NO;
    
    if (![self startPullRefresh]) {
        [self.view hideToastActivity];
        self.tableView.userInteractionEnabled = YES;
        self.couponOfMonth = nil;
        [self createTableHeaderView];
        [self createTableFooterView];
    }
}

#pragma mark - 接口配置
- (void)resetRequestParam
{
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *month = [NSString stringByDate:@"yyyy-MM" Date:_curDate];
    NSDictionary *dic = @{@"cmd":@"queryDriverWallet",@"token":userInfo.token,@"version":app_Version,@"params":@{@"userId":userInfo.userId,@"month":month}};
    dic = [NSString convertDicToStr:dic];
    self.param = dic;
}

- (void)requestFinish:(NSError *)error Data:(id)result
{
    [super requestFinish:error Data:result];
    [self.view hideToastActivity];
    self.tableView.userInteractionEnabled = YES;
    
    if (error == nil) {
        id detail = [result valueForKey:@"detail"];
        self.couponOfMonth = [[CouponOfMonth alloc] initWithDictionary:detail error:nil];
        [self.tableView reloadData];
    }
    
    [self createTableHeaderView];
    [self createTableFooterView];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_couponOfMonth.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *coupouCellId = @"coupouCellId";
    CouponViewCell *cell = [tableView dequeueReusableCellWithIdentifier:coupouCellId];
    if (cell == nil) {
        cell = [[CouponViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:coupouCellId];
    }
    
    CouponOfDay *coupon = [_couponOfMonth.dataList objectAtIndex:indexPath.row];
    cell.dateLab.text = coupon.day;
    cell.priceLab.text = [([coupon.income stringValue] ?: @"0") stringByAppendingString:@"元"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CouponOfDay *coupon = [_couponOfMonth.dataList objectAtIndex:indexPath.row];
    CouponDetailViewController *detail = [[CouponDetailViewController alloc] init];
    detail.title = coupon.day;
    detail.curDate = coupon.day;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = rgba(249, 249, 249, 1);
}

@end
