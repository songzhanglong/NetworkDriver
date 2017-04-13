//
//  AboutViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "AboutViewController.h"
#import "CTMediator+ModuleWeb.h"
#import <Masonry.h>
#import "GlobalManager.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"关于";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [self createTableViewAndRequestAction:nil Param:nil];
    self.tableView.backgroundColor = self.view.backgroundColor;
    self.tableView.scrollEnabled = NO;
    [self initialTableHeaderView];
}

#pragma mark - Private Methods
- (void)initialTableHeaderView
{
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"driverLogo.png"]];
    imgView.layer.cornerRadius = 10;
    imgView.layer.masksToBounds = YES;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, imgView.image.size.height * 2 + 20)];
    UIView *subFatherView = [UIView new];
    [headerView addSubview:subFatherView];
    [subFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.and.centerY.equalTo(headerView);
    }];
    
    [subFatherView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(@0);
        make.right.equalTo(subFatherView.mas_right);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    [label setText:currentVersion ];
    [label setTextColor:[UIColor darkGrayColor]];
    [subFatherView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(imgView.mas_centerX);
        make.top.equalTo(imgView.mas_bottom).with.offset(5);
        make.bottom.equalTo(subFatherView.mas_bottom);
    }];
    
    [self.tableView setTableHeaderView:headerView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *aboutCellId = @"aboutCellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:aboutCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:aboutCellId];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = @"服务条款";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *driver_yhxy = [GlobalManager shareInstance].appInit.ecex_yhxy;
    if ([driver_yhxy length] == 0) {
        [self.view makeToast:@"应用初始化失败，请稍后再试" duration:1.0 position:@"center"];
        return;
    }
    UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForWeb:driver_yhxy];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
