//
//  AcceptCarCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AcceptCarCell : UITableViewCell

@property (nonatomic,strong)UILabel *orderNum;
@property (nonatomic,strong)UILabel *closeRate;

- (void)resetDriverOrderCount;

@end
