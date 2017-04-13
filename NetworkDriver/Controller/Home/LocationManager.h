//
//  LocationManager.h
//  NetworkDriver
//
//  Created by szl on 16/10/11.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface LocationManager : NSObject

@property (nonatomic,strong)BMKLocationService *locService;
@property (nonatomic,strong)BMKUserLocation *userLocation;
@property (nonatomic,assign)CLLocationDistance sumMiles;           //里程
@property (nonatomic,assign)NSInteger sumTimes;
@property (nonatomic,assign)BOOL isCaculating;          //控制距离和时间的计算

#pragma mark - 定时器
- (void)beginLocationUpload;
- (void)endLocationUpload;

@end
