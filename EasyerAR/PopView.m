//
//  PopView.m
//  helloar
//
//  Created by 栗子 on 2018/4/26.
//  Copyright © 2018年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import "PopView.h"
#define kAngle(r) (r) * M_PI / 180

@implementation PopView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(30, (frame.size.height-40)/2, frame.size.width-60, 40)];
        btn.backgroundColor = [UIColor redColor];
        [self addSubview:btn];
        btn.layer.cornerRadius = 20;
        btn.layer.masksToBounds = YES;
        [btn setTitle:@"识别成功" forState:UIControlStateNormal];//RECOGNITION
        [btn addTarget:self action:@selector(recontitionSuccess) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
-(void)recontitionSuccess{
   
    if (self.popBlock) {
        self.popBlock();
    }
     [self removeFromSuperview];
}

- (void)show:(BOOL)animated
{
    if (animated)
    {

        __weak typeof(self) weakSelf = self;
        [UIView animateWithDuration:0.45 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
           
            weakSelf.layer.transform = CATransform3DMakeRotation(kAngle(-180), 0, 1, 0);
            [weakSelf.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.layer.transform = weakSelf.layer.transform;
            }];
            
            
        } completion:^(BOOL finished) {
           
        }];
        
        
    }
}


@end
