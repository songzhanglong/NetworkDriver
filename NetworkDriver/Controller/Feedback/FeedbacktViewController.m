//
//  ContactViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "FeedbacktViewController.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "IQKeyboardManager.h"
#import "GlobalManager.h"
#import "NSString+Common.h"

@interface FeedbacktViewController ()

@property (nonatomic,strong)UITextView *textView;
@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)UIButton *commitBtn;

@end

@implementation FeedbacktViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"意见反馈";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.commitBtn];
    
    [self initialConstraint];
}

#pragma mark - Private
- (void)initialConstraint
{
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.and.right.equalTo(self.view);
        make.height.equalTo(self.textView.mas_width).with.multipliedBy(0.5);
    }];
    [[self.textView rac_textSignal] subscribeNext:^(NSString *x) {
        self.tipLab.hidden = (x.length > 0);
    }];
    [self.tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self.textView).with.offset(5);
    }];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.top.equalTo(self.textView.mas_bottom).with.offset(20);
        make.height.equalTo(@40);
    }];
    
    [_textView.rac_textSignal subscribeNext:^(NSString *x) {
        _commitBtn.enabled = (x.length > 0);
    }];
}

#pragma mark - 提交反馈
- (void)beginFeedback
{
    if (_textView.text.length == 0) {
        [self.view makeToast:@"请留下您的意见与建议吧" duration:1.0 position:@"center"];
        return;
    }
    
    if ([GlobalManager shareInstance].networkReachabilityStatus <= AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:NET_WORK_TIP duration:1.0 position:@"center"];
        return;
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    UserDetailInfo *userInfo = [GlobalManager shareInstance].userInfo;
    NSDictionary *dic = @{@"cmd":@"addFeedBack",@"token":G_TOKEN,@"version":app_Version,@"params":@{@"userId":userInfo.userId,@"content":_textView.text,@"appType":@"6"}};
    dic = [NSString convertDicToStr:dic];
    __weak typeof(self)weakSelf = self;
    [self.view makeToastActivity];
    self.view.userInteractionEnabled = NO;
    self.sessionTask = [HttpClient asynchronousNormalRequest:[G_INTERFACE_ADDRESS stringByAppendingString:@"addFeedBack"] parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf feedBackFinish:error Data:data];
        });
    }];
}

- (void)feedBackFinish:(NSError *)error Data:(id)result{
    self.view.userInteractionEnabled = YES;
    [self.view hideToastActivity];
    self.sessionTask = nil;
    
    if (error) {
        [self.navigationController.view makeToast:error.domain duration:1.0 position:@"center"];
    }
    else{
        [self.navigationController.view makeToast:@"您的意见已发送成功" duration:1.0 position:@"center"];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma makr - lazy load
- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.autocorrectionType = UITextAutocorrectionTypeNo;
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    }
    return _textView;
}

- (UILabel *)tipLab
{
    if (!_tipLab) {
        _tipLab = [[UILabel alloc] init];
        _tipLab.enabled = NO;
        [_tipLab setTextColor:[UIColor lightGrayColor]];
        [_tipLab setText:@"留下您的意见与建议吧..."];
        [_tipLab setFont:[UIFont systemFontOfSize:14]];
    }
    return _tipLab;
}

- (UIButton *)commitBtn
{
    if (!_commitBtn) {
        _commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_commitBtn setTitle:@"提交反馈" forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commitBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        [_commitBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        _commitBtn.layer.masksToBounds = YES;
        _commitBtn.layer.cornerRadius = 5;
        [_commitBtn setBackgroundColor:BASELINE_COLOR];
        @weakify(self);
        [[_commitBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            @strongify(self);
            [[IQKeyboardManager sharedManager] resignFirstResponder];
            [self beginFeedback];
        }];
    }
    return _commitBtn;
}

@end
