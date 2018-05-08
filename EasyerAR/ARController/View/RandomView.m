//
//  RandomView.m
//  SnowAnim
//
//  Created by 栗子 on 2018/5/4.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import "RandomView.h"

@interface RandomView ()<CAAnimationDelegate>

/**
 展示的layer
 */
@property (strong, nonatomic) CAEmitterLayer *streamerLayer;

/**
 图片数组
 */
@property (nonatomic, strong) NSMutableArray *imagesArr;

/**
 cell的数组
 */
@property (nonatomic, strong) NSMutableArray *CAEmitterCellArr;

@property (nonatomic, strong) UIImageView *lightIV;


@end



@implementation RandomView
{
    NSTimer *_timer; //定时器
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

/**
 *  配置WclEmitterButton
 */
- (void)setup {
    
    self.lightIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [self addSubview:self.lightIV];
    self.lightIV.image = [UIImage imageNamed:@"bg"];
    self.lightIV.hidden = YES;
    
    //设置暂时的layer
    _streamerLayer               = [CAEmitterLayer layer];
    _streamerLayer.emitterSize   = CGSizeMake(30, 30);
    _streamerLayer.masksToBounds = NO;
    _streamerLayer.renderMode = kCAEmitterLayerAdditive;
    [self.layer addSublayer:_streamerLayer];
}
- (void)starAnimation{
    
    self.lightIV.hidden = NO;
    
    CAAnimationGroup *group = [self starIVAnimation];
    [self.lightIV.layer addAnimation:group forKey:@"anim"];

}

- (void)addAnimation{
    [self.imagesArr removeAllObjects];
    [self.CAEmitterCellArr removeAllObjects];
    
    for (int i = 1; i < 10; i++)
    {
        int x = arc4random() % 14 + 1;
        NSString * imageStr = [NSString stringWithFormat:@"icon_%d",x];
        [self.imagesArr addObject:imageStr];
    }
    
    //设置展示的cell
    for (NSString * imageStr in self.imagesArr) {
        CAEmitterCell * cell = [self emitterCell:[UIImage imageNamed:imageStr] Name:imageStr];
        [self.CAEmitterCellArr addObject:cell];
    }
    _streamerLayer.emitterCells  = self.CAEmitterCellArr;
    
    //_streamerLayer开始时间
    _streamerLayer.beginTime = CACurrentMediaTime();
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [_streamerLayer setValue:@40 forKeyPath:keyPathStr];
    }
    [self performSelector:@selector(stopAnimation) withObject:nil afterDelay:0.1];
}


- (void)stopAnimation{
    //让chareLayer每秒喷射的个数为0个
    for (NSString * imgStr in self.imagesArr) {
        NSString * keyPathStr = [NSString stringWithFormat:@"emitterCells.%@.birthRate",imgStr];
        [self.streamerLayer setValue:@0 forKeyPath:keyPathStr];
    }
    [_timer invalidate];
    _timer = nil;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    //设置发射点的位置
    _streamerLayer.position = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
    self.lightIV.center = CGPointMake(self.frame.size.width/2.0, self.frame.size.height/2.0);
}

/**
 创建发射的表情cell
 
 @param image 传入随机的图片
 @param name 图片的名字
 @return cell
 */
- (CAEmitterCell *)emitterCell:(UIImage *)image Name:(NSString *)name
{
    CAEmitterCell * smoke = [CAEmitterCell emitterCell];
    smoke.birthRate = 0;//每秒出现多少个粒子
    smoke.lifetime = 1;// 粒子的存活时间
    smoke.lifetimeRange = 1;
    smoke.scale = 0.2;
    
    smoke.alphaRange = 1;
    smoke.alphaSpeed = -1.0;//消失范围
    //    smoke.yAcceleration = 450;//可以有下落的效果
    
    CGImageRef image2 = image.CGImage;
    smoke.contents= (__bridge id _Nullable)(image2);
    smoke.name = name; //设置这个 用来展示喷射动画 和隐藏
    
    smoke.velocity = 300;//速度
    smoke.velocityRange = 30;// 平均速度
    smoke.emissionLongitude = 3 * M_PI / 2 ;
    smoke.emissionRange = M_PI *2 ;//粒子的发散范围
    smoke.spin = M_PI; // 粒子的平均旋转速度
    smoke.spinRange = M_PI * 2;// 粒子的旋转速度调整范围
    return smoke;
}


- (NSMutableArray *)imagesArr
{
    if (_imagesArr == nil) {
        _imagesArr = [NSMutableArray array];
    }
    return _imagesArr;
}

- (NSMutableArray *)CAEmitterCellArr
{
    if (_CAEmitterCellArr == nil) {
        _CAEmitterCellArr = [NSMutableArray array];
    }
    return _CAEmitterCellArr;
}
-(CAAnimationGroup *)starIVAnimation{
    CAKeyframeAnimation * rectangleTransformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    rectangleTransformAnim.values   = @[[NSValue valueWithCATransform3D:CATransform3DIdentity],
                                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(10, 10, 1)]];
    rectangleTransformAnim.keyTimes = @[@0, @1];
    rectangleTransformAnim.duration = 0.2;
    rectangleTransformAnim.repeatCount = 1;
    rectangleTransformAnim.removedOnCompletion = NO;
    rectangleTransformAnim.fillMode = kCAFillModeForwards;
    
    CAKeyframeAnimation * rectangleOpacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    rectangleOpacityAnim.values   = @[@0, @1];
    rectangleOpacityAnim.keyTimes = @[@0, @1];
    rectangleOpacityAnim.duration = 0.2;
    rectangleOpacityAnim.repeatCount = 1;
    rectangleOpacityAnim.removedOnCompletion = NO;
    rectangleOpacityAnim.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:rectangleTransformAnim,rectangleOpacityAnim, nil];
    animGroup.duration = 0.2;
    animGroup.repeatCount = 1;
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.delegate = self;
    [animGroup setValue:@"group" forKey:@"an"];
    return animGroup;
    
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
     if ([anim valueForKey:@"an"]) {
         CAAnimationGroup *group = [self samllIVAnimation];
         [self.lightIV.layer addAnimation:group forKey:@"anim"];
        [self addAnimation];
    }
    
}
-(CAAnimationGroup *)samllIVAnimation{
    CAKeyframeAnimation * rectangleTransformAnim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    rectangleTransformAnim.values   = @[
                                        [NSValue valueWithCATransform3D:CATransform3DMakeScale(10, 10, 1)],[NSValue valueWithCATransform3D:CATransform3DIdentity]];
    rectangleTransformAnim.keyTimes = @[@0, @1];
    rectangleTransformAnim.duration = 0.2;
    rectangleTransformAnim.repeatCount = 1;
    rectangleTransformAnim.removedOnCompletion = NO;
    rectangleTransformAnim.fillMode = kCAFillModeForwards;
    
    CAKeyframeAnimation * rectangleOpacityAnim = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    rectangleOpacityAnim.values   = @[@1, @0];
    rectangleOpacityAnim.keyTimes = @[@0, @1];
    rectangleOpacityAnim.duration = 0.2;
    rectangleOpacityAnim.repeatCount = 1;
    rectangleOpacityAnim.removedOnCompletion = NO;
    rectangleOpacityAnim.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *animGroup = [CAAnimationGroup animation];
    animGroup.animations = [NSArray arrayWithObjects:rectangleTransformAnim,rectangleOpacityAnim, nil];
    animGroup.duration = 0.2;
    animGroup.repeatCount = 1;
    animGroup.removedOnCompletion = NO;
    animGroup.fillMode = kCAFillModeForwards;
    return animGroup;
    
}

@end
