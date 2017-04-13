//
//  MapViewController.m
//  NetworkDriver
//
//  Created by szl on 16/10/13.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MapViewController.h"
#import "BNRoutePlanModel.h"
#import "BNCoreServices.h"
#import "OrderInformation.h"
#import "HomePageViewController.h"

@interface MapViewController ()<BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate,UIAlertViewDelegate>

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.showBack = YES;
    self.title = @"地图导航";
    [self startNavi];
}

- (void)startNavi
{
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    //起点 传入的是原始的经纬度坐标，若使用的是百度地图坐标，可以使用BNTools类进行坐标转化
    BMKUserLocation *location = ((HomePageViewController *)[self.navigationController.viewControllers firstObject]).locationManager.userLocation;
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = location.location.coordinate.longitude;
    startNode.pos.y = location.location.coordinate.latitude;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = [(_getOff ? _orderInfo.toLon : _orderInfo.fromLon) doubleValue];
    endNode.pos.y = [(_getOff ? _orderInfo.toLat : _orderInfo.fromLat) doubleValue];
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan setDisableOpenUrl:YES];//不调用百度地图应用
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    
    //路径规划成功，开始导航
    [BNCoreServices_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary*)userInfo
{
    NSString *tipStr = nil;
    switch ([error code] % 10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONFAILED:
            tipStr = @"暂时无法获取您的位置,请稍后重试";
            break;
        case BNAVI_ROUTEPLAN_ERROR_ROUTEPLANFAILED:
            tipStr = @"无法发起导航";
            break;
        case BNAVI_ROUTEPLAN_ERROR_LOCATIONSERVICECLOSED:
            tipStr = @"定位服务未开启,请到系统设置中打开定位服务。";
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:
            tipStr = @"起终点距离起终点太近";
            break;
        default:
            tipStr = @"算路失败";
            break;
    }
    
    
    Class actionClass = NSClassFromString(@"UIAlertController");
    if (actionClass) {
        UIAlertController *alertController = [actionClass alertControllerWithTitle:@"提示" message:tipStr preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[NSClassFromString(@"UIAlertAction") actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];

        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:tipStr delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}


#pragma mark - 安静退出导航
- (void)exitNaviUI
{
    [BNCoreServices_UI exitPage:EN_BNavi_ExitTopVC animated:YES extraInfo:nil];
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航页面回调
- (void)onExitPage:(BNaviUIType)pageType  extraInfo:(NSDictionary*)extraInfo
{
    if (pageType == BNaviUI_NormalNavi)
    {
        NSLog(@"退出导航");
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (pageType == BNaviUI_Declaration)
    {
        NSLog(@"退出导航声明页面");
    }
}

@end
