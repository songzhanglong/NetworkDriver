//
//  BaseViewController.m
//  TYSociety
//
//  Created by szl on 16/6/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "BaseViewController.h"
#import <MBProgressHUD.h>

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //避免push时会看似停顿
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
}

- (void)setShowBack:(BOOL)showBack {
    if (showBack) {
        //返回按钮
        UIImage *img = [UIImage imageNamed:@"NavBack"];
        NSLog(@"%@",NSStringFromCGSize(img.size));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        backBtn.backgroundColor = [UIColor clearColor];
        [backBtn setImage:img forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backToPreControl:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = -10;//这个数值可以根据情况自由变化
        self.navigationItem.leftBarButtonItems = @[negativeSpacer, backBarButtonItem];
        
        UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
        
        [rightView setBackgroundColor:[UIColor clearColor]];
        UIBarButtonItem *rigBtn = [[UIBarButtonItem alloc] initWithCustomView:rightView];
        self.navigationItem.rightBarButtonItem = rigBtn;
    }
    else {
        self.navigationItem.leftBarButtonItems = nil;
        self.navigationItem.rightBarButtonItem = nil;
    }
}

/** 返回事件，子类可复写 */
- (void)backToPreControl:(id)sender {
    if (self.navigationController.presentingViewController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 标题
- (UILabel *)titleLable {
    if (!_titleLable) {
        
        CGRect leftViewbounds = ((UIBarButtonItem *)[self.navigationItem.leftBarButtonItems lastObject]).customView.bounds;
        CGRect rightViewbounds = ((UIBarButtonItem *)[self.navigationItem.rightBarButtonItems lastObject]).customView.bounds;
        CGFloat maxWidth = MAX(leftViewbounds.size.width, rightViewbounds.size.width);
        
        _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - maxWidth * 2, 21)];
        [_titleLable setFont:BigFont];
        [_titleLable setTextAlignment:NSTextAlignmentCenter];
        [_titleLable setTextColor:[UIColor whiteColor]];
        [_titleLable setBackgroundColor:[UIColor clearColor]];
        self.navigationItem.titleView = _titleLable;
    }
    
    return _titleLable;
}

#pragma mark - 状态栏与方向
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
