//
//  OrderDetailBaseCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailBaseCell : UITableViewCell

@property (nonatomic,strong)UILabel *orderNumberLab;
@property (nonatomic,strong)UILabel *orderStateLab;
@property (nonatomic,strong)UILabel *getOnLab;
@property (nonatomic,strong)UILabel *getOffLab;
@property (nonatomic,strong)UIImageView *marginLine;

#pragma mark - Public
- (void)initialSubViews;

- (void)initialConstraint;

@end
