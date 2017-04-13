//
//  MarkScore.m
//  CallCar
//
//  Created by szl on 16/6/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "MarkScore.h"
#import <Masonry.h>

@implementation MarkScore
{
    CGFloat _itemMargin,_itemWei;
    NSMutableArray *_constraintArr;
}

- (instancetype)initWithMargin:(CGFloat)margin Name:(NSString *)normal Hli:(NSString *)hliStr
{
    self = [super init];
    if (self) {
        _itemMargin = margin;
        _constraintArr = [NSMutableArray array];
        UIImage *imgN = [UIImage imageNamed:normal],*imgH = [UIImage imageNamed:hliStr];
        _itemWei = imgN.size.width;
        UIImageView __block *firstImg = nil;
        for (NSInteger i = 0; i < 5; i++) {
            //normal
            UIImageView *downView = [[UIImageView alloc] initWithImage:imgN];
            [downView setTag:10 + i];
            [self addSubview:downView];
            [downView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (firstImg) {
                    make.left.equalTo(firstImg.mas_right).with.offset(margin);
                }
                else{
                    make.left.equalTo(self.mas_left);
                }
                make.centerY.equalTo(self.mas_centerY);
                if (i == 4) {
                    make.right.equalTo(self.mas_right);
                    make.bottom.equalTo(self.mas_bottom);
                }
            }];
            
            firstImg = downView;
            
            //front
            UIView *upView = [[UIView alloc] init];
            [upView setBackgroundColor:[UIColor clearColor]];
            [upView setTag:i + 1];
            upView.clipsToBounds = YES;
            [self addSubview:upView];
            [upView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.and.height.equalTo(downView);
                MASConstraint *constraint = make.width.equalTo(@(0));
                [_constraintArr addObject:constraint];
            }];
            
            //hlight
            UIImageView *upImg = [[UIImageView alloc] initWithImage:imgH];
            [upView addSubview:upImg];
            [upImg mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.and.top.equalTo(upView);
            }];
        }
    }
    return self;
}

- (void)setScore:(CGFloat)score
{
    if (_score != score) {
        _score = score;
        for (NSInteger i = 1; i < 6; i++) {
            MASConstraint *constraint = _constraintArr[i - 1];
            if (i <= score) {
                constraint.equalTo(@(_itemWei));
            }
            else{
                if (i - score > 1) {
                    constraint.equalTo(@(0));
                }
                else{
                    NSInteger suxTwo = (NSInteger)(score * 100) % 100;
                    constraint.equalTo(@(suxTwo * _itemWei / 100));
                }
            }
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    for (NSInteger i = 0; i < 5; i++) {
        UIImageView *imgView = (UIImageView *)[self viewWithTag:i + 10];
        if (CGRectContainsPoint(imgView.frame, point)) {
            CGFloat diff = (point.x - imgView.frameX) / imgView.frameWidth;
            if (diff <= 0.5) {
                diff = 0.5;
            }
            else{
                diff = 1;
            }
            self.score = i + diff;
            break;
        }
        else if (CGRectContainsPoint(CGRectMake(imgView.frameX - _itemMargin, imgView.frameY, _itemMargin, imgView.frameHeight), point)){
            self.score = i;
            break;
        }
    }
}

@end
