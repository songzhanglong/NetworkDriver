//
//  OrderAppraiseCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkScore.h"

@interface OrderAppraiseCell : UITableViewCell

@property (nonatomic,strong)UILabel *tipLab;
@property (nonatomic,strong)MarkScore *markScore;
@property (nonatomic,strong)UILabel *contentLab;
@property (nonatomic,strong)UIImageView *marginLineImg;

@end
