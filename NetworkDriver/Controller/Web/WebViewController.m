//
//  WebViewController.m
//  CallCar
//
//  Created by szl on 16/7/3.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "WebViewController.h"
#import <IMYWebView.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface WebViewController ()<IMYWebViewDelegate>

@property (nonatomic,strong)IMYWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.showBack = YES;
    self.title = @"努力加载中...";
    [self.view addSubview:self.webView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}

#pragma mark - IMYWebViewDelegate
- (void)webViewDidFinishLoad:(IMYWebView *)webView{
    // new for memory cleaning
    self.title = webView.title;
}

#pragma mark - lazy load
- (IMYWebView *)webView
{
    if (!_webView) {
        _webView = [[IMYWebView alloc] initWithFrame:self.view.bounds];
        [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        //_webView.scrollView.showsVerticalScrollIndicator = NO;
        [_webView setScalesPageToFit:YES];
        [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
        [_webView setDelegate:self];
    }
    return _webView;
}

@end
