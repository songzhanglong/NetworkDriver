//
//  DJTTableViewVC.h
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "BaseViewController.h"
#import "MJRefresh.h"
#import "MJChiBaoZiHeader.h"
#import "MJChiBaoZiFooter2.h"
#import "Toast+UIView.h"

@interface TableViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSString *action;       //请求接口
@property (nonatomic,strong)NSDictionary *param;    //请求参数
@property (nonatomic,strong)UITableView *tableView;

/** 创建表和网络请求 */
- (void)createTableViewAndRequestAction:(NSString *)action Param:(NSDictionary *)param;

#pragma mark - 表头，尾创建，删除
- (void)createTableRefreshView:(BOOL)isHeader;
- (void)removeTableRefreshView:(BOOL)isHeader;

#pragma mark - 上下拉刷新
/** 开始刷新 */
- (void)beginRefresh;

/** 结束下拉刷新 */
- (void)finishRefresh;

/** @brief	开始刷新  */
- (BOOL)startPullRefresh;
- (BOOL)startPullRefresh2;

/** 是否正在刷新 */
- (BOOL)isRefreshing;

#pragma mark - 网络请求结束
/** 数据请求结果 */
- (void)requestFinish:(NSError *)error Data:(id)result;
- (void)requestFinish2:(NSError *)error Data:(id)result;

@end
