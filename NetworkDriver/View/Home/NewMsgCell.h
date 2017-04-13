//
//  NewMsgCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/22.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewMsgCell : UITableViewCell

@property (nonatomic,strong)UILabel *contentLab;
@property (nonatomic,strong)UILabel *timeLab;

- (void)resetNewMessage:(NSString *)timer Content:(NSString *)content;

@end
