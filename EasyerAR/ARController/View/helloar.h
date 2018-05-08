//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <Foundation/Foundation.h>

BOOL initialize(NSArray *arArray,bool mode);
void finalize(void);
BOOL start(void);
BOOL stop(void);
void initGL(void);
void resizeGL(int width, int height);
void render(void);


/**
 设置相机缩放

 @param scale 倍率
 */
void changeZoomScale(float scale);

/**
 打开手电筒

 @param mode @YES打开
 */
void changeFlashMode(bool mode);
