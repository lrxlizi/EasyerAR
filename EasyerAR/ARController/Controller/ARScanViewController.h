//
//  ARScanViewController.h
//  EasyerAR
//
//  Created by 栗子 on 2018/5/8.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface ARScanViewController : GLKViewController

@property (nonatomic, strong) NSArray *arArray;

@property (nonatomic,  copy)voidBlock success;

@end
