//=============================================================================================================================
//
// Copyright (c) 2015-2018 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
// EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
// and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
//
//=============================================================================================================================

#import "helloar.h"

#import "BoxRenderer.h"

#import <easyar/types.oc.h>
#import <easyar/camera.oc.h>
#import <easyar/frame.oc.h>
#import <easyar/framestreamer.oc.h>
#import <easyar/imagetracker.oc.h>
#import <easyar/imagetarget.oc.h>
#import <easyar/renderer.oc.h>

#include <OpenGLES/ES2/gl.h>

easyar_CameraDevice * camera;
easyar_CameraFrameStreamer * streamer;
NSMutableArray<easyar_ImageTracker *> * trackers;
easyar_Renderer * videobg_renderer;
BoxRenderer * box_renderer;
bool viewport_changed = false;
int view_size[] = {0, 0};
int view_rotation = 0;
int viewport[] = {0, 0, 1280, 720};

void loadFromImage(easyar_ImageTracker * tracker, NSString * path)
{
    easyar_ImageTarget * target = [easyar_ImageTarget create];
    NSString * name = [[path componentsSeparatedByString:@"/"] lastObject];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-string-concatenation"
    NSString * jstr = [@[@"{\n"
                         "  \"images\" :\n"
                         "  [\n"
                         "    {\n"
                         "      \"image\" : \"", path, @"\",\n"
                         "      \"name\" : \"", name, @"\"\n"
                         "    }\n"
                         "  ]\n"
                         "}"] componentsJoinedByString:@""];
#pragma clang diagnostic pop
    [target setup:jstr storageType:(easyar_StorageType_Assets | easyar_StorageType_Json) name:@""];
    [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
    }];
}

void loadFromJsonFile(easyar_ImageTracker * tracker, NSString * path, NSString * targetname)
{
    easyar_ImageTarget * target = [easyar_ImageTarget create];
    [target setup:path storageType:easyar_StorageType_Assets name:targetname];
    [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
    }];
}

void loadAllFromJsonFile(easyar_ImageTracker * tracker, NSString * path)
{
    for (easyar_ImageTarget * target in [easyar_ImageTarget setupAll:path storageType:easyar_StorageType_Assets]) {
        [tracker loadTarget:target callback:^(easyar_Target * target, bool status) {
        }];
    }
}

BOOL initialize(NSArray *arArray,bool mode)
{
    camera = [easyar_CameraDevice create];
    streamer = [easyar_CameraFrameStreamer create];
    [streamer attachCamera:camera];
    bool status = true;
    if (mode) {
        status &= [camera open:easyar_CameraDeviceType_Front];
    }else
    {
        status &= [camera open:easyar_CameraDeviceType_Back];
    }
    [camera setSize:[easyar_Vec2I create:@[@1280, @720]]];

    if (!status) { return status; }
    easyar_ImageTracker * tracker = [easyar_ImageTracker create];
    [tracker attachStreamer:streamer];
//    loadFromJsonFile(tracker, @"targets.json", @"argame");
//    loadFromJsonFile(tracker, @"targets.json", @"idback");
//    loadAllFromJsonFile(tracker, @"targets2.json");
    for (NSString *path in arArray) {
        loadFromImage(tracker, path);
    }
    
    trackers = [[NSMutableArray<easyar_ImageTracker *> alloc] init];
    [trackers addObject:tracker];

    return status;
}

void changeZoomScale(float scale)
{
    [camera setZoomScale:scale];
}

void changeFlashMode(bool mode)
{
    [camera setFlashTorchMode:mode];
}

void finalize()
{
    [trackers removeAllObjects];
    box_renderer = nil;
    videobg_renderer = nil;
    streamer = nil;
    camera = nil;
}

BOOL start()
{
    bool status = true;
    status &= (camera != nil) && [camera start];
    status &= (streamer != nil) && [streamer start];
    [camera setFocusMode:easyar_CameraDeviceFocusMode_Continousauto];
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker start];
    }
    return status;
}

BOOL stop()
{
    bool status = true;
    for (easyar_ImageTracker * tracker in trackers) {
        status &= [tracker stop];
    }
    status &= (streamer != nil) && [streamer stop];
    status &= (camera != nil) && [camera stop];
    return status;
}

void initGL()
{
    videobg_renderer = [easyar_Renderer create];
    box_renderer = [BoxRenderer alloc];
    [box_renderer init_];
}

void resizeGL(int width, int height)
{
    view_size[0] = width;
    view_size[1] = height;
    viewport_changed = true;
}

void updateViewport()
{
    easyar_CameraCalibration * calib = camera != nil ? [camera cameraCalibration] : nil;
    int rotation = calib != nil ? [calib rotation] : 0;
    if (rotation != view_rotation) {
        view_rotation = rotation;
        viewport_changed = true;
    }
    if (viewport_changed) {
        int size[] = {1, 1};
        if (camera && [camera isOpened]) {
            size[0] = [[[camera size].data objectAtIndex:0] intValue];
            size[1] = [[[camera size].data objectAtIndex:1] intValue];
        }
        if (rotation == 90 || rotation == 270) {
            int t = size[0];
            size[0] = size[1];
            size[1] = t;
        }
        float scaleRatio = MAX((float)view_size[0] / (float)size[0], (float)view_size[1] / (float)size[1]);
        int viewport_size[] = {(int)roundf(size[0] * scaleRatio), (int)roundf(size[1] * scaleRatio)};
        int viewport_new[] = {(view_size[0] - viewport_size[0]) / 2, (view_size[1] - viewport_size[1]) / 2, viewport_size[0], viewport_size[1]};
        memcpy(&viewport[0], &viewport_new[0], 4 * sizeof(int));
        
        if (camera && [camera isOpened])
            viewport_changed = false;
    }
}

void render()
{
    glClearColor(1.f, 1.f, 1.f, 1.f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    if (videobg_renderer != nil) {
        int default_viewport[] = {0, 0, view_size[0], view_size[1]};
        easyar_Vec4I * oc_default_viewport = [easyar_Vec4I create:@[[NSNumber numberWithInt:default_viewport[0]], [NSNumber numberWithInt:default_viewport[1]], [NSNumber numberWithInt:default_viewport[2]], [NSNumber numberWithInt:default_viewport[3]]]];
        glViewport(default_viewport[0], default_viewport[1], default_viewport[2], default_viewport[3]);
        if ([videobg_renderer renderErrorMessage:oc_default_viewport]) {
            return;
        }
    }
    if (streamer == nil) { return; }
    easyar_Frame * frame = [streamer peek];
    updateViewport();
    glViewport(viewport[0], viewport[1], viewport[2], viewport[3]);

    if (videobg_renderer != nil) {
        [videobg_renderer render:frame viewport:[easyar_Vec4I create:@[[NSNumber numberWithInt:viewport[0]], [NSNumber numberWithInt:viewport[1]], [NSNumber numberWithInt:viewport[2]], [NSNumber numberWithInt:viewport[3]]]]];
    }
    if ([frame targetInstances].count==0) {// NSLog(@"图片识别失败");
       
    }else{
    for (easyar_TargetInstance * targetInstance in [frame targetInstances]) {
        easyar_TargetStatus status = [targetInstance status];
        if (status == easyar_TargetStatus_Tracked) {// NSLog(@"图片识别成功");
            
            [[NSNotificationCenter defaultCenter]postNotificationName:EASYAR_SCAN_SUCCESS object:nil];
        }
      }
    }
}
