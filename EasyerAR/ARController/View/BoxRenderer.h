//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import <easyar/vector.oc.h>
#import <easyar/matrix.oc.h>

@interface BoxRenderer : NSObject

- (void)init_;
- (void)render:(easyar_Matrix44F *)projectionMatrix cameraview:(easyar_Matrix44F *)cameraview size:(easyar_Vec2F *)size;

@end
