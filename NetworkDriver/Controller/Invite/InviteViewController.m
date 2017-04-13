//
//  InviteViewController.m
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "InviteViewController.h"
#import "UMSocial.h"
#import "WXApi.h"
#import "ShareModule.h"
#import <Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "GlobalManager.h"

@interface InviteViewController ()

@property (nonatomic,strong)UIView *topBackView;
@property (nonatomic,strong)UILabel *topTipLab;
@property (nonatomic,strong)UILabel *bottomTipLab;
@property (nonatomic,strong)UILabel *numLab;
@property (nonatomic,strong)UIView *bottomBackView;

@end

@implementation InviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"邀请好友";
    self.view.backgroundColor = rgba(236, 236, 236, 1);
    
    [self.view addSubview:self.topBackView];
    [self.topBackView addSubview:self.topTipLab];
    [self.topBackView addSubview:self.numLab];
    [self.topBackView addSubview:self.bottomTipLab];
    [self.view addSubview:self.bottomBackView];
    
    NSArray *array = [self generateDataArr];
    [self initialConstraint:array];
}

- (NSMutableArray *)generateDataArr
{
    NSMutableArray *shareArr = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {
        ShareModule *model1 = [[ShareModule alloc] init];
        model1.name = @"微信";
        model1.imgName = @"share_icon_wechat_a";
        model1.imgNameH = @"share_icon_wechat";
        model1.shareType = kShareToFriend;
        [shareArr addObject:model1];
        
        ShareModule *model2 = [[ShareModule alloc] init];
        model2.name = @"朋友圈";
        model2.imgName = @"share_icon_wechatfriends";
        model2.imgNameH = @"share_icon_wechatfriends_a";
        model2.shareType = kShareToCircle;
        [shareArr addObject:model2];
    }
    
    //邮件
    ShareModule *model = [[ShareModule alloc] init];
    model.name = @"短信";
    model.imgName = @"share_icon_message";
    model.imgNameH = @"share_icon_message";
    model.shareType = kShareToSms;
    [shareArr addObject:model];
    
    return shareArr;
}

#pragma mark - Private Methods
- (void)initialConstraint:(NSArray *)array
{
    [self.topBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(@16);
    }];
    
    [self.topTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topBackView.mas_centerX);
        make.top.equalTo(@(80 * SCREEN_HEIGHT / 1334));
    }];
    
    [self.numLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topTipLab.mas_bottom).with.offset(16 * SCREEN_HEIGHT / 1334);
        make.centerX.equalTo(self.topBackView.mas_centerX);
    }];
    
    [self.bottomTipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.topBackView.mas_centerX);
        make.top.equalTo(self.numLab.mas_bottom).with.offset(16 * SCREEN_HEIGHT / 1334);
        make.bottom.equalTo(self.topBackView.mas_bottom).with.offset(-(60 * SCREEN_HEIGHT / 1334));
    }];
    
    [self.bottomBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBackView.mas_bottom).with.offset(90 * SCREEN_HEIGHT / 1334);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    
    UIView __block *lastView = nil;
    NSInteger __block count = [array count];
    @weakify(self);
    [array enumerateObjectsUsingBlock:^(ShareModule *model, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        //father
        UIView *tmpView = [UIView new];
        [self.bottomBackView addSubview:tmpView];
        [tmpView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right).with.offset(25);
            }
            else{
                make.left.equalTo(@0);
            }
            make.top.equalTo(self.bottomBackView.mas_top);
            make.width.equalTo(@50);
            make.height.equalTo(@(50 + 16));
            if (idx == count - 1) {
                make.right.equalTo(self.bottomBackView.mas_right);
                make.bottom.equalTo(self.bottomBackView.mas_bottom);
            }
        }];
        //btn
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:CREATE_IMG(model.imgName) forState:UIControlStateNormal];
        [btn setImage:CREATE_IMG(model.imgNameH) forState:UIControlStateHighlighted];
        [tmpView addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.and.left.and.right.equalTo(tmpView);
            make.height.equalTo(@50);
        }];
        [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
            [self shareToType:model.shareType];
        }];
        //lab
        UILabel *lab = [[UILabel alloc] init];
        [lab setText:model.name];
        [lab setTextColor:[UIColor blackColor]];
        [lab setFont:[UIFont systemFontOfSize:10]];
        [tmpView addSubview:lab];
        [lab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(tmpView.mas_bottom);
            make.centerX.equalTo(btn.mas_centerX);
        }];
        
        lastView = tmpView;
    }];
}

- (void)shareToType:(kShareType)shareType
{
    NSString *shareText = [GlobalManager shareInstance].userInfo.invitationCode;
    NSString *tipText = [GlobalManager shareInstance].appInit.driverShareApp;
    if (tipText.length > 0) {
        NSRange beginRange = [tipText rangeOfString:@"{"];
        NSRange endRange = [tipText rangeOfString:@"}"];
        if (beginRange.location != NSNotFound && endRange.location != NSNotFound) {
            shareText = [tipText stringByReplacingCharactersInRange:NSMakeRange(beginRange.location + 1, endRange.location - beginRange.location - 1) withString:shareText];
        }
    }
    
    NSString *type = (shareType == kShareToSms) ? UMShareToSms : ((shareType == kShareToFriend) ? UMShareToWechatSession : UMShareToWechatTimeline);
    
    //UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:@""];
    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:shareText image:nil location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
        if (shareResponse.responseCode == UMSResponseCodeSuccess) {
            NSLog(@"分享成功！");
        }
    }];
}

#pragma mark - lazy laod
- (UIView *)topBackView
{
    if (!_topBackView) {
        _topBackView = [UIView new];
        [_topBackView setBackgroundColor:[UIColor whiteColor]];
    }
    return _topBackView;
}

- (UILabel *)topTipLab
{
    if (!_topTipLab) {
        _topTipLab = [UILabel new];
        [_topTipLab setText:@"我的邀请码"];
        [_topTipLab setTextColor:BASELINE_COLOR];
        [_topTipLab setFont:[UIFont systemFontOfSize:20]];
    }
    return _topTipLab;
}

- (UILabel *)numLab
{
    if (!_numLab) {
        _numLab = [UILabel new];
        [_numLab setTextColor:BASELINE_COLOR];
        [_numLab setFont:[UIFont systemFontOfSize:20]];
        [_numLab setText:[GlobalManager shareInstance].userInfo.invitationCode];
    }
    return _numLab;
}

- (UILabel *)bottomTipLab
{
    if (!_bottomTipLab) {
        _bottomTipLab = [UILabel new];
        [_bottomTipLab setTextColor:[UIColor lightGrayColor]];
        [_bottomTipLab setText:@"好友注册时输入"];
        [_bottomTipLab setFont:SmallFont];
    }
    return _bottomTipLab;
}

- (UIView *)bottomBackView
{
    if (!_bottomBackView) {
        _bottomBackView = [UIView new];
    }
    return _bottomBackView;
}

@end
