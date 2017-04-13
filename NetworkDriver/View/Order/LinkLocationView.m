//
//  LinkLocationView.m
//  NetworkDriver
//
//  Created by szl on 16/9/25.
//  Copyright © 2016年 szl. All rights reserved.
//

#import "LinkLocationView.h"
#import "UIColor+Hex.h"
#import <Masonry.h>

@implementation LinkLocationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImage *imgN = [UIColor createImageWithColor:[UIColor blackColor] Size:CGSizeMake(6, 6)],*imgH = [UIColor createImageWithColor:[UIColor whiteColor] Size:CGSizeMake(6, 6)];
        UIImageView __block *firstImg = nil;
        CGFloat margin = 2;
        for (NSInteger i = 0; i < 5; i++) {
            //normal
            UIImageView *downView = [[UIImageView alloc] initWithImage:imgN];
            [downView setHighlightedImage:imgH];
            [self addSubview:downView];
            [downView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (firstImg) {
                    make.top.equalTo(firstImg.mas_bottom).with.offset(margin);
                }
                else{
                    make.top.equalTo(@0);
                }
                make.left.equalTo(@0);
                make.width.and.height.equalTo(@2);
                if (i == 4) {
                    make.right.equalTo(self.mas_right);
                    make.bottom.equalTo(self.mas_bottom);
                }
            }];
            
            firstImg = downView;
        }
    }
    return self;
}

@end
