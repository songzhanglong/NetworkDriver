//
//  LocationManager.m
//  NetworkDriver
//
//  Created by szl on 16/10/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LocationManager.h"
#import "HttpClient.h"
#import "NSString+Common.h"
#import "GlobalManager.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LocationManager ()<BMKLocationServiceDelegate>

@property (nonatomic,strong)NSURLSessionTask *sessionTask;
@property (nonatomic,strong)RACDisposable *disposable;

@end

@implementation LocationManager

- (void)dealloc{
    //撤销网络请求
    if (_sessionTask && (_sessionTask.state == NSURLSessionTaskStateRunning)) {
        [_sessionTask cancel];
    }
    self.sessionTask = nil;
}

- (id)init{
    self = [super init];
    if (self) {
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc] init];
        _locService.delegate = self;
        _locService.distanceFilter = kCLLocationAccuracyNearestTenMeters;
        _locService.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        //启动LocationService
        [_locService startUserLocationService];
        
        UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
        @weakify(self);
        [RACObserve(detailInfo, orderNo) subscribeNext:^(NSString *orderNo) {
            @strongify(self);
            if (orderNo.length == 0) {
                [self endLocationUpload];
            }
        }];
    }
    return self;
}

#pragma mark - 定时器
- (void)beginLocationUpload
{
    _isCaculating = YES;
    _sumMiles = 0;
    _sumTimes = 0;
    [self performSelector:@selector(startTimeAdd) withObject:nil afterDelay:5];
}

- (void)startTimeAdd
{
    _sumMiles += 5;
    
    //文件存储
    NSString *file = [APPDocumentsDirectory stringByAppendingPathComponent:Order_Save_Plist];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[NSNumber numberWithDouble:_sumMiles] forKey:Save_Distance];
    [dic setObject:[NSNumber numberWithDouble:_userLocation.location.coordinate.latitude] forKey:Save_Lat];
    [dic setObject:[NSNumber numberWithDouble:_userLocation.location.coordinate.longitude] forKey:Save_Lon];
    [dic setObject:[NSDate date] forKey:Save_Date];
    [dic setObject:[NSNumber numberWithInteger:_sumTimes] forKey:Save_Timer];
    [dic setObject:[GlobalManager shareInstance].userInfo.orderNo ?: @"" forKey:Save_No];
    [dic writeToFile:file atomically:YES];
    
    [self performSelector:@selector(startTimeAdd) withObject:nil afterDelay:5];
}

- (void)endLocationUpload
{
    _isCaculating = NO;
    _sumMiles = 0;
    _sumTimes = 0;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startTimeAdd) object:nil];
    
    NSString *tmpPath = [APPDocumentsDirectory stringByAppendingPathComponent:Order_Save_Plist];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:tmpPath]) {
        [fileManager removeItemAtPath:tmpPath error:nil];
    }
}

#pragma mark - 提交位置
- (void)commitAddressInfoToBackground
{
    if (self.sessionTask) {
        return;
    }
    
    UserDetailInfo *detailInfo = [GlobalManager shareInstance].userInfo;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"2" forKey:@"mapType"];      //定位方式:2是百度地图定位的,1是GPS定位的
    [params setObject:[[NSNumber numberWithDouble:_userLocation.heading.trueHeading] stringValue] forKey:@"posDirection"];      //方向
    [params setObject:[[NSNumber numberWithDouble:_userLocation.location.coordinate.latitude] stringValue] forKey:@"posLatitude"];
    [params setObject:[[NSNumber numberWithDouble:_userLocation.location.coordinate.longitude] stringValue] forKey:@"posLongitude"];
    [params setObject:@"2" forKey:@"posMethod"];    //地图经纬度类型:2是百度地图定位的,1是GPS定位的
    [params setObject:[[NSNumber numberWithDouble:_userLocation.location.course] stringValue] forKey:@"posPrecision"];     //半径
    [params setObject:[[NSNumber numberWithDouble:_userLocation.location.speed] stringValue] forKey:@"posSpeed"];       //
    [params setObject:detailInfo.userId forKey:@"userId"];
    [params setObject:detailInfo.bindVehicleId forKey:@"vehicleId"];
    [params setObject:[[NSNumber numberWithDouble:floor([_userLocation.location.timestamp timeIntervalSince1970] * 1000)] stringValue] forKey:@"posTime"];        //定位时间
    if (detailInfo.orderNo.length > 0) {
        [params setObject:detailInfo.orderNo forKey:@"orderNo"];
        [params setObject:@"4" forKey:@"driverStatus"];
    }
    else{
        [params setObject:@"2" forKey:@"driverStatus"];
    }
    if (_isCaculating) {
        [params setObject:[[NSNumber numberWithDouble:_sumMiles] stringValue] forKey:@"sumMiles"];      //累计行驶的里程
        [params setObject:[[NSNumber numberWithDouble:_sumTimes] stringValue] forKey:@"sumTimes"];     //累计行驶的时间
    }
    
    NSDictionary *dic = [NSString convertDicToStr:params];
    __weak typeof(self)weakSelf = self;
    self.sessionTask = [HttpClient asynchronousNormalRequest:G_INTERFACE_DSE parameters:dic complateBlcok:^(NSError *error, id data) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf commitFinish:error Data:data];
        });
    }];
}

- (void)commitFinish:(NSError *)error Data:(id)result
{
    self.sessionTask = nil;
    [self performSelector:@selector(commitAddressInfoToBackground) withObject:nil afterDelay:5];
}

#pragma mark - BMKLocationServiceDelegate
//实现相关delegate 处理位置信息更新
//处理方向变更信息
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    NSLog(@"heading is %@",userLocation.heading);
//    NSLog(@"最小更新距离:%f,定位精度:%f,最小更新角度:%f",_locService.distanceFilter,_locService.desiredAccuracy,_locService.headingFilter);
//}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    if (!_userLocation) {
        self.userLocation = userLocation;
    }
    else if (_isCaculating){
        CLLocationDistance distance = fabs([_userLocation.location distanceFromLocation:userLocation.location]);
        if (distance >= 30) {
            _sumMiles += distance;
            self.userLocation = userLocation;
        }
    }
    
    if (!_disposable) {
        UserDetailInfo *detail = [GlobalManager shareInstance].userInfo;
        _disposable = [RACObserve(detail, bindVehicleId) subscribeNext:^(NSString *bindVehicleId) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commitAddressInfoToBackground) object:nil];
            if (bindVehicleId.length > 0) {
                [self commitAddressInfoToBackground];
            }
        }];
        
        //上次路程
        if (detail.orderNo.length > 0) {
            NSString *file = [APPDocumentsDirectory stringByAppendingPathComponent:Order_Save_Plist];
            NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:file];
            NSString *orderNo = [dic valueForKey:Save_No];
            if (orderNo && [orderNo isEqualToString:detail.orderNo]) {
                //相同的订单
                double distance = [[dic valueForKey:Save_Distance] doubleValue];
                double lat = [[dic valueForKey:Save_Lat] doubleValue],lon = [[dic valueForKey:Save_Lon] doubleValue];
                CLLocation *tmpLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
                distance += [userLocation.location distanceFromLocation:tmpLoc] / 1000;
                _sumMiles = distance;
                
                NSDate *date = [dic valueForKey:Save_Date];
                double timer = [[dic valueForKey:Save_Timer] doubleValue];
                _sumTimes = timer + floor([[NSDate date] timeIntervalSinceDate:date]);
                
                _isCaculating = YES;
                [self performSelector:@selector(startTimeAdd) withObject:nil afterDelay:5];
            }
        }
    }
}

//定位失败后
- (void)didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"%@",error);
}

@end
