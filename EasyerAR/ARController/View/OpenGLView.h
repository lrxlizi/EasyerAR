//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <GLKit/GLKView.h>

@interface OpenGLView : GLKView

/**
 开始摄像

 @param arArray 要识别的图片
 @param mode 0后置 1前置摄像头
 */
- (void)start:(NSArray *)arArray
         mode:(BOOL)mode;


/**
 设置相机缩放
 
 @param scale 倍率
 */
- (void)changeZoomScale:(float)scale;

/**
 打开手电筒
 
 @param mode @YES打开
 */
- (void)changeFlashMode:(BOOL)mode;

- (void)stop;
- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation;
- (void)setOrientation:(UIInterfaceOrientation)orientation;

@end
