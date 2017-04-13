//
//  LeftViewController.m
//  NewTeacher
//
//  Created by songzhanglong on 14/12/24.
//  Copyright (c) 2014年 songzhanglong. All rights reserved.
//

#import "SideslipViewController.h"
#import "YQSlideMenuController.h"
#import "AppDelegate.h"
#import "NSString+Common.h"
#import <Masonry.h>
#import "CTMediator+ModuleLogin.h"
#import "CTMediator+Sideslip.h"
#import "CTMediator+ModuleWeb.h"
#import "MarkScore.h"
#import "GlobalManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface SideslipViewController ()

@property (strong,nonatomic) UIImageView *parallaxHeaderView;
@property (strong,nonatomic) MASConstraint *parallaxHeaderHeightConstraint;
@property (nonatomic,assign) CGFloat parallaxHeaderHeight;
@property (nonatomic,strong) UIColor *overallColor;

@end

@implementation SideslipViewController

- (void)dealloc {
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.overallColor = rgba(47, 47, 55, 1);
    self.view.backgroundColor = self.overallColor;
    self.dataSource = @[@"我的订单",@"我的钱包",@"消息中心",/*@"邀请好友",*/@"意见反馈",@"关于",@"联系我们",@"退出"];
    self.imageNames = @[@"sideslip_order.png",@"sideslip_cpupon.png",@"sideslip_msg.png",/*@"sideslip_invite.png",*/@"sideslip_feedback.png",@"sideslip_about.png",@"sideslip_contact.png",@"sideslip_exit.png"];
    [self createTableViewAndRequestAction:nil Param:nil];
    [self.tableView setBackgroundColor:self.overallColor];

    //initial
    [self initialTableHeaderView];
    [self initialParallaxHeaderView];
    [self initialHeaderInfo];
}

#pragma mark - Private methods
- (void)initialTableHeaderView
{
    UIView *hederView = [[UIView alloc] init];
    [hederView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    [hederView setBackgroundColor:self.overallColor];
    //labels
    CGFloat margin = (SCREEN_WIDTH - 80 - 30) / 2;
    UILabel *totalOrders = [[UILabel alloc] init];
    [totalOrders setTextColor:[UIColor whiteColor]];
    [totalOrders setNumberOfLines:0];
    [totalOrders setBackgroundColor:[UIColor blackColor]];
    totalOrders.layer.cornerRadius = 10;
    totalOrders.layer.masksToBounds = YES;
    [totalOrders setTextAlignment:NSTextAlignmentCenter];
    [hederView addSubview:totalOrders];
    [totalOrders mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.top.equalTo(@(3));
        make.bottom.equalTo(hederView.mas_bottom).with.offset(-3);
        make.width.equalTo(@(margin));
    }];
    //成交率
    UILabel *perentLab = [[UILabel alloc] init];
    [perentLab setTextColor:[UIColor whiteColor]];
    [perentLab setNumberOfLines:0];
    [perentLab setBackgroundColor:[UIColor blackColor]];
    perentLab.layer.cornerRadius = 10;
    perentLab.layer.masksToBounds = YES;
    [perentLab setTextAlignment:NSTextAlignmentCenter];
    [hederView addSubview:perentLab];
    [perentLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(totalOrders.mas_right).with.offset(10);
        make.top.equalTo(totalOrders.mas_top);
        make.bottom.equalTo(totalOrders.mas_bottom);
        make.width.equalTo(totalOrders.mas_width);
    }];
    
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    [RACObserve(detailInfo, orderCount) subscribeNext:^(id x) {
        totalOrders.text = [[detailInfo.orderCount.orders stringValue] stringByAppendingString:@"\n总接单数"];
        [perentLab setText:[detailInfo.orderCount.finishRate stringByAppendingString:@"\n总成交率"]];
    }];
    
    [self.tableView setTableHeaderView:hederView];
}

- (void)initialParallaxHeaderView {
    //UIImage *headerImg = CREATE_IMG(@"sideslip_top");
    //self.parallaxHeaderHeight = SCREEN_WIDTH * headerImg.size.height / headerImg.size.width;
    self.parallaxHeaderHeight = 120;
    self.tableView.contentInset = UIEdgeInsetsMake(_parallaxHeaderHeight, 0, 0, 0);
    _parallaxHeaderView = [UIImageView new];
    //[self.view insertSubview:_parallaxHeaderView belowSubview:self.tableView];
    [_parallaxHeaderView setBackgroundColor:self.overallColor];
    [self.view addSubview:_parallaxHeaderView];
    _parallaxHeaderView.contentMode = UIViewContentModeScaleAspectFill;
    //_parallaxHeaderView.image = headerImg;
    [_parallaxHeaderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view.mas_top);
        _parallaxHeaderHeightConstraint = make.height.equalTo(@(_parallaxHeaderHeight));
    }];
    
    // Add KVO
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)initialHeaderInfo
{
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView sd_setImageWithURL:[NSURL URLWithString:detailInfo.headImage ?: @""] placeholderImage:[UIImage imageNamed:@"navHead.png"]];
    [imgView setClipsToBounds:YES];
    [imgView setContentMode:UIViewContentModeScaleAspectFill];
    imgView.layer.cornerRadius = 28;
    imgView.layer.masksToBounds = YES;
    [_parallaxHeaderView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.height.equalTo(@(56));
        make.width.equalTo(imgView.mas_height);
        make.bottom.equalTo(_parallaxHeaderView.mas_bottom).with.offset(-((_parallaxHeaderHeight - 56 - 20) / 2));
    }];
    
    UIView *rightView = [[UIView alloc] init];
    [_parallaxHeaderView addSubview:rightView];
    [rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imgView.mas_right).with.offset(10);
        make.centerY.equalTo(imgView.mas_centerY);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    [label setText:detailInfo.realName];
    [label setFont:[UIFont systemFontOfSize:20]];
    [label setTextColor:[UIColor whiteColor]];
    [label sizeToFit];
    [rightView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(0));
        make.top.equalTo(@(0));
        make.right.lessThanOrEqualTo(rightView.mas_right);
    }];
    
    MarkScore *mark = [[MarkScore alloc] initWithMargin:5 Name:@"gradeStarN.png" Hli:@"gradeStarH.png"];
    mark.score = [detailInfo.starClass floatValue];
    [rightView addSubview:mark];
    [mark mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label.mas_left);
        make.top.equalTo(label.mas_bottom).with.offset(5);
        //没有这些约束，rightView宽高不会重置
        make.right.lessThanOrEqualTo(rightView.mas_right);
        make.bottom.equalTo(rightView.mas_bottom);
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        CGPoint contentOffset = ((NSValue *)change[NSKeyValueChangeNewKey]).CGPointValue;
        if (contentOffset.y < -_parallaxHeaderHeight) {
            _parallaxHeaderHeightConstraint.equalTo(@(-contentOffset.y));
        }
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *leftIdentifierBase = @"leftCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:leftIdentifierBase];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leftIdentifierBase];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = BASELINE_COLOR;
    }
    
    [cell.imageView setImage:[UIImage imageNamed:_imageNames[indexPath.row]]];
    [cell.textLabel setText:_dataSource[indexPath.row]];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == [_dataSource count] - 1) {
        NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
        [userDef removeObjectForKey:LOGIN_PASS];
        [[CTMediator sharedInstance] CTMediator_rootviewControllerForLogin:YES];
    }
    else
    {
        YQSlideMenuController *deckController = (YQSlideMenuController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        [deckController hideMenu];
        
        double delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *className = nil;
                switch (indexPath.row) {
                    case 0:
                    {
                        className = @"OrdersViewController";
                    }
                        break;
                    case 1:
                    {
                        className = @"CouponViewController";
                    }
                        break;
                    case 2:
                    {
                        className = @"MsgCenterViewController";
                    }
                        break;
                        /*
                    case 3:
                    {
                        className = @"InviteViewController";
                    }
                        break;
                    case 4:
                    {
                        className = @"FeedbacktViewController";
                    }
                        break;
                    case 5:
                    {
                        className = @"AboutViewController";
                    }
                        break;
                    case 6:
                    {
                        UINavigationController *nav = (UINavigationController *)deckController.contentViewController;
                        NSString *driver_lxwm = [GlobalManager shareInstance].appInit.ecex_lxwm;
                        if ([driver_lxwm length] == 0) {
                            [nav.view makeToast:@"应用初始化失败，请稍后再试" duration:1.0 position:@"center"];
                        }
                        else{
                            UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForWeb:driver_lxwm];
                            [nav pushViewController:controller animated:YES];
                        }
                    }
                        break;
                         */
                    case 3:
                    {
                        className = @"FeedbacktViewController";
                    }
                        break;
                    case 4:
                    {
                        className = @"AboutViewController";
                    }
                        break;
                    case 5:
                    {
                        UINavigationController *nav = (UINavigationController *)deckController.contentViewController;
                        NSString *driver_lxwm = [GlobalManager shareInstance].appInit.ecex_lxwm;
                        if ([driver_lxwm length] == 0) {
                            [nav.view makeToast:@"应用初始化失败，请稍后再试" duration:1.0 position:@"center"];
                        }
                        else{
                            UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForWeb:driver_lxwm];
                            [nav pushViewController:controller animated:YES];
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                if (className) {
                    UIViewController *controller = [[CTMediator sharedInstance] CTMediator_viewControllerForSideslip:className];
                    UINavigationController *nav = (UINavigationController *)deckController.contentViewController;
                    [nav pushViewController:controller animated:YES];
                }
                
            });
            
        });
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = self.overallColor;
}

@end
