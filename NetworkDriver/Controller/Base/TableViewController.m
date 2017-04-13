//
//  DJTTableViewVC.m
//  TY
//
//  Created by songzhanglong on 14-5-28.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "TableViewController.h"

@interface TableViewController ()

@end

@implementation TableViewController

/** 创建表和网络请求 */
- (void)createTableViewAndRequestAction:(NSString *)action Param:(NSDictionary *)param {
    self.param = param;
    self.action = action;
    
    //data source
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [_tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    //_tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    //_tableView.backgroundColor = self.view.backgroundColor;
    UIView *footView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView setTableFooterView:footView];
    [self.view addSubview:_tableView];
}

#pragma mark - 表头，尾创建，删除
- (void)createTableRefreshView:(BOOL)isHeader {
    if (isHeader) {
        if (!_tableView.mj_header) {
            _tableView.mj_header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh)];
        }
    }
    else{
        if (!_tableView.mj_footer) {
            _tableView.mj_footer = [MJChiBaoZiFooter2 footerWithRefreshingTarget:self refreshingAction:@selector(startPullRefresh2)];
        }
    }
}

- (void)removeTableRefreshView:(BOOL)isHeader {
    if (isHeader) {
        if (_tableView.mj_header) {
            _tableView.mj_header = nil;
        }
    }
    else{
        if (_tableView.mj_footer) {
            _tableView.mj_footer = nil;
        }
    }
}

#pragma mark - 下拉，上拉刷新
/** @brief	开始刷新 */
- (void)beginRefresh {
    if (_tableView.mj_header) {
        [_tableView.mj_header beginRefreshing];
    }
}

/** @brief	结束下拉刷新 */
- (void)finishRefresh {
    if (_tableView.mj_header.isRefreshing) {
        [_tableView.mj_header endRefreshing];
    }
    
    if (_tableView.mj_footer.isRefreshing) {
        [_tableView.mj_footer endRefreshing];
    }
}

- (BOOL)isRefreshing {
    return _tableView.mj_header.isRefreshing || _tableView.mj_footer.isRefreshing;
}

/** 重置请求参数，子类覆盖 */
- (void)resetRequestParam {
    
}

/** 开始刷新 */
- (BOOL)startPullRefresh {
    //重置请求参数
    [self resetRequestParam];
    
    if (!_action || !_param) {
        [self finishRefresh];
        return NO;
    }
    
    __weak __typeof(self)weakSelf = self;
    //针对老接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
    
    self.sessionTask = [HttpClient asynchronousNormalRequest:url parameters:_param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf requestFinish:error Data:data];
        });
    }];
    
    return YES;
}

- (BOOL)startPullRefresh2 {
    if (_tableView && _tableView.mj_header.isRefreshing) {
        [_tableView.mj_footer endRefreshing];
        return NO;
    }
    
    //重置请求参数
    [self resetRequestParam];
    
    if (!_action || !_param) {
        [self finishRefresh];
        return NO;
    }
    
    __weak __typeof(self)weakSelf = self;
    //针对老接口
    NSString *url = [G_INTERFACE_ADDRESS stringByAppendingString:_action];
    
    self.sessionTask = [HttpClient asynchronousNormalRequest:url parameters:_param complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf requestFinish2:error Data:data];
        });
        
    }];
    
    return YES;
}

#pragma mark - 网络请求结束
/** 数据请求结果 */
- (void)requestFinish:(NSError *)error Data:(id)result {
    //自己加的
    self.sessionTask = nil;
    [self finishRefresh];
}

- (void)requestFinish2:(NSError *)error Data:(id)result {
    self.sessionTask = nil;
    [self finishRefresh];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end
