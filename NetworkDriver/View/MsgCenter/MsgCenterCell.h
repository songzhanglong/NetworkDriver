//
//  MsgCenterCell.h
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MsgItem;

@interface MsgCenterCell : UITableViewCell

- (void)resetMsgItem:(MsgItem *)item;

@end
