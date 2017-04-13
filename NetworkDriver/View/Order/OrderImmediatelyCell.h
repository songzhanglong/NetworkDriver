//
//  OrderImmediatelyCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "OrderDetailBaseCell.h"

@interface OrderImmediatelyCell : OrderDetailBaseCell

@property (nonatomic,strong)UILabel *distanceLab;
@property (nonatomic,strong)UILabel *routeLab;
//@property (nonatomic,strong)UILabel *priceLab;
@property (nonatomic,strong)UIImageView *bottomLineImg;

@end
