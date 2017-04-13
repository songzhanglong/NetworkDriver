//
//  OrderPayCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/26.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderPayCell : UITableViewCell

@property (nonatomic,strong)UILabel *totalPrice;
@property (nonatomic,strong)UILabel *kilometrePrice;
@property (nonatomic,strong)UILabel *durationPrice;
@property (nonatomic,strong)UILabel *otherPrice;
@property (nonatomic,strong)UILabel *couponPrice;

@end
