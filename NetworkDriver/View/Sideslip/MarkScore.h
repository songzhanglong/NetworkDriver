//
//  MarkScore.h
//  CallCar
//
//  Created by szl on 16/6/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkScore : UIView

@property (nonatomic,assign)CGFloat score;

- (instancetype)initWithMargin:(CGFloat)margin Name:(NSString *)normal Hli:(NSString *)hliStr;

@end
