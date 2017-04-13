//
//  ShareModule.h
//  NetworkDriver
//
//  Created by szl on 16/9/23.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    kShareToFriend = 0,
    kShareToCircle,
    kShareToSms
}kShareType;

@interface ShareModule : NSObject

@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *imgName;
@property (nonatomic,strong)NSString *imgNameH;
@property (nonatomic,assign)kShareType shareType;

@end
