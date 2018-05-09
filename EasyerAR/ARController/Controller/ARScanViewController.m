//
//  ARScanViewController.m
//  EasyerAR
//
//  Created by 栗子 on 2018/5/8.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import "ARScanViewController.h"
#import "ARScanSixView.h"
#import "OpenGLView.h"
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import "PopView.h"

@interface ARScanViewController ()<UIGestureRecognizerDelegate>

{
    OpenGLView  *glView;
    BOOL  isSuccess;
    float scale;//相机缩放倍数
    BOOL  isZoom;//已经放大了
}
@property (nonatomic, strong) ARScanSixView *aniView;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *flashButton;
@end

@implementation ARScanViewController

- (void)dealloc
{
    NSLog(@"ar销毁了");
}
- (void)loadView {
    glView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.view = glView;
}


- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true animated:false];
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false animated:false];
    [glView stop];
}

- (void)viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
    [glView resize:self.view.bounds orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [glView setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self ceateUI];
}
-(void)ceateUI{
    scale = 1.f;
    [glView setOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(recontitionSuccess) name:EASYAR_SCAN_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnimation) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.aniView = [[ARScanSixView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];;
    [self.view addSubview:self.aniView];
    [self.view bringSubviewToFront:self.aniView];
    [self.aniView starAnimation];
    @WeakObj(self);
    self.aniView.success = ^{

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            PopView *pop = [[PopView alloc]initWithFrame:CGRectMake((SCREEN_WIDTH-300)/2, (SCREEN_HEIGHT-300)/2, 300, 300)];
            [selfWeak.view addSubview:pop];
            [pop show:YES];
            pop.popBlock = ^{
                [selfWeak.navigationController popViewControllerAnimated:NO];
            };
        });
    };
    
    [self otherView];
    
    [self setUpGesture];
    [glView start:self.arArray mode:NO];
}

#pragma mark - 按下home键回来继续动画
- (void)addAnimation
{
    [self.aniView starAnimation];
}

#pragma mark 识别成功
-(void)recontitionSuccess
{
    if (!isSuccess) {
        isSuccess = true;
        [self.aniView sucessAnimtion];
    }
}
#pragma mark - 导航 tabber
- (void)otherView
{
    UIView *topView = [UIView new];
    topView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(64);
    }];
    
    UIImageView *img = [UIImageView new];
    img.image = [UIImage imageNamed:@"back_white"];
    [topView addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(32);
        make.left.mas_equalTo(15);
        make.size.mas_equalTo(CGSizeMake(10, 20));
    }];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(64, 64));
    }];
    
    UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [flashBtn setImage:[UIImage imageNamed:@"icon_shoudiantong"] forState:UIControlStateNormal];
    [flashBtn setImage:[UIImage imageNamed:@"icon_shoudiantong_r"] forState:UIControlStateSelected];
    flashBtn.backgroundColor = [UIColor clearColor];
    [flashBtn addTarget:self action:@selector(flash:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:flashBtn];
    [flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.top.mas_equalTo(0);
        make.width.mas_equalTo(42);
    }];
    flashBtn.imageEdgeInsets = UIEdgeInsetsMake(11,-10,-11,10);
    self.flashButton = flashBtn;
    
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraBtn setImage:[UIImage imageNamed:@"icon_xuanzhuan"] forState:UIControlStateNormal];
    cameraBtn.backgroundColor = [UIColor clearColor];
    [cameraBtn addTarget:self action:@selector(camera:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:cameraBtn];
    [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(flashBtn.mas_left).mas_offset(0);
        make.bottom.top.mas_equalTo(0);
        make.width.mas_equalTo(52);
    }];
    cameraBtn.imageEdgeInsets = UIEdgeInsetsMake(11,-5,-11,5);
    self.cameraButton = cameraBtn;
    
    UIView *botView = [UIView new];
    botView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:botView];
    [botView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(84);
    }];
    
    UIImageView *arImg = [UIImageView new];
    arImg.image = [UIImage imageNamed:@"icon_ar"];
    [botView addSubview:arImg];
    [arImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(34, 34));
        make.centerX.mas_equalTo(botView);
        make.top.mas_equalTo(15);
    }];
    
    UILabel *arLabel = [UILabel new];
    arLabel.font = [UIFont systemFontOfSize:15];
    arLabel.text = @"AR相机";
    arLabel.textColor = [UIColor redColor];
    arLabel.textAlignment = NSTextAlignmentCenter;
    [botView addSubview:arLabel];
    [arLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 21));
        make.centerX.mas_equalTo(botView);
        make.top.mas_equalTo(arImg.mas_bottom).mas_offset(3);
    }];
}
#pragma mark - 返回
- (void)back
{
    [self.navigationController popViewControllerAnimated:NO];
}
#pragma mark - 切换摄像头
- (void)camera:(UIButton *)sender
{
    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(camera2:)object:sender];
    [self performSelector:@selector(camera2:)withObject:sender afterDelay:0.2f];
}
- (void)camera2:(UIButton *)sender
{
    BOOL mode = NO;
    if (!sender.selected) {
        mode = YES;
    }
    [glView start:self.arArray mode:mode];
    if (mode)
    {
        self.flashButton.selected = NO;
        [UIView animateWithDuration:0.25 animations:^{
            [self.flashButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(42);
            }];
            [self.view layoutIfNeeded];
        }];
    }else
    {
        [UIView animateWithDuration:0.25 animations:^{
            [self.flashButton mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(0);
            }];
            [self.view layoutIfNeeded];
        }];
    }
    sender.selected = !sender.selected;
}
#pragma mark - 打开手电筒
- (void)flash:(UIButton*)btn
{
    [[self class]cancelPreviousPerformRequestsWithTarget:self selector:@selector(flash2:)object:btn];
    [self performSelector:@selector(flash2:)withObject:btn afterDelay:0.2f];
}
- (void)flash2:(UIButton*)btn
{
    btn.selected = !btn.selected;
    [self turnTorchOn:btn.selected];
}
-(void)turnTorchOn:(bool)on
{
    [glView changeFlashMode:on];
}

//添加手势
- (void)setUpGesture{
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchDetected:)];
    pinch.delegate = self;
    [glView addGestureRecognizer:pinch];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    [glView addGestureRecognizer:doubleTap];
}

//双击
-(void)handleDoubleTap:(UITapGestureRecognizer *)recogniser
{
    if (scale == 1)
    {
        scale = 4;
        isZoom = YES;
    }else
    {
        scale = 1;
        isZoom = NO;
    }
    [glView changeZoomScale:scale];
}

//双指触摸
- (void)pinchDetected:(UIPinchGestureRecognizer *)recogniser {
    float s = recogniser.scale;
    if (s < 1.f && scale > 1.f)
    {
        s = (scale - 1.f)*s + 1.f;
    }else if (s > 1.f && scale > 1.f && isZoom)
    {
        s += scale;
    }
    s = MAX(s, 1.f);
    s = MIN(s, 10.f);
    scale = s;
    [glView changeZoomScale:scale];
    
    if (recogniser.state == UIGestureRecognizerStateEnded)
    {
        if (scale > 1.f)
        {
            isZoom = YES;
        }else
        {
            isZoom = NO;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
