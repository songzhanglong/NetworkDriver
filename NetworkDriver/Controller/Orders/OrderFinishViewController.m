//
//  OrderFinishViewController.m
//  NetworkDriver
//
//  Created by szl on 16/10/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderFinishViewController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <MBProgressHUD.h>
#import "GlobalManager.h"
#import "NSString+Common.h"

@interface OrderFinishViewController ()

@property (nonatomic,strong)UIImageView *topImg;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UILabel *priceLab;
@property (nonatomic,strong)UIButton *contBtn;
@property (nonatomic,strong)UIButton *endCarBtn;

@end

@implementation OrderFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"支付成功";
    self.showBack = YES;
    
    [self.view addSubview:self.topImg];
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.priceLab];
    [self.view addSubview:self.contBtn];
    [self.view addSubview:self.endCarBtn];
    
    [self initialConstraintsOfSubviews];
    [self initialReactiveSignal];
}

#pragma mark - Private Methods
- (void)backToPreControl:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)initialConstraintsOfSubviews
{
    //account
    [self.topImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(@(70));
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.topImg.mas_bottom).with.offset(10);
    }];
    [self.priceLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.tipLab.mas_bottom).with.offset(10);
    }];
    CGFloat itemHei = 96.0 * SCREEN_HEIGHT / 1334;
    [self.contBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(itemHei));
        make.left.equalTo(@25);
        make.right.equalTo(self.view.mas_right).with.offset(-25);
        make.top.equalTo(self.priceLab.mas_bottom).with.offset(40);
    }];
    self.contBtn.layer.cornerRadius = itemHei / 2;
    [self.endCarBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(itemHei));
        make.left.equalTo(@25);
        make.right.equalTo(self.view.mas_right).with.offset(-25);
        make.top.equalTo(self.contBtn.mas_bottom).with.offset(15);
    }];
    self.endCarBtn.layer.cornerRadius = itemHei / 2;
}

- (void)initialReactiveSignal
{
    // 监听登录按钮点击
    @weakify(self);
    [[self.contBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self backToPreControl:nil];
    }];
    [[self.endCarBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self isReceiveOrder];
    }];
}

#pragma mark - 收车
- (void)isReceiveOrder
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    // 加一层蒙版
    hud.dimBackground = YES;
    hud.labelText = @"正在请求...";
    
    //参数请求
    UserDetailInfo *userDetail = [GlobalManager shareInstance].userInfo;
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSDictionary *dic = @{@"cmd":@"isReceiveOrder",@"token":userDetail.token,@"version":app_Version,@"params":@{@"userId":userDetail.userId,@"vehicleId":userDetail.bindVehicleId,@"needPush":@"0"}};
    dic = [NSString convertDicToStr:dic];
    
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"isReceiveOrder"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf isReceiveOrderFinish:error Data:data];
        });
    }];
}

- (void)isReceiveOrderFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    if (error) {
        [self.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        UserDetailInfo *userDetail = [GlobalManager shareInstance].userInfo;
        userDetail.isReceiveTask = [NSNumber numberWithInt:0];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - lazy load
- (UIImageView *)topImg
{
    if (!_topImg) {
        _topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"order_pay.png"]];
    }
    return _topImg;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        [_tipLab setFont:BigFont];
        [_tipLab setTextColor:BASELINE_COLOR];
        [_tipLab setText:@"支付成功"];
    }
    return _tipLab;
}

- (UILabel *)priceLab
{
    if (!_priceLab) {
        _priceLab = [[UILabel alloc] init];
        [_priceLab setFont:[UIFont systemFontOfSize:30]];
        [_priceLab setTextColor:[UIColor blackColor]];
        CGFloat totalPrice = 0;
        for (NSArray *subArr in _payCharge.costDetail) {
            totalPrice += [subArr[1] floatValue];
        }
        NSString *priceStr = [[NSNumber numberWithFloat:totalPrice] stringValue];
        [_priceLab setText:[priceStr stringByAppendingString:@"元"]];
    }
    return _priceLab;
}

- (UIButton *)contBtn
{
    if (!_contBtn) {
        _contBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_contBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_contBtn.layer setMasksToBounds:YES];
        [_contBtn.titleLabel setFont:MiddleFont];
        [_contBtn setTitle:@"继续接单" forState:UIControlStateNormal];
        [_contBtn setBackgroundColor:BASELINE_COLOR];
    }
    return _contBtn;
}

- (UIButton *)endCarBtn
{
    if (!_endCarBtn) {
        _endCarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_endCarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_endCarBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_endCarBtn.layer setMasksToBounds:YES];
        [_endCarBtn.titleLabel setFont:MiddleFont];
        [_endCarBtn setTitle:@"我要收车" forState:UIControlStateNormal];
        [_endCarBtn setBackgroundColor:rgba(105, 105, 105, 1)];
    }
    return _endCarBtn;
}

@end
