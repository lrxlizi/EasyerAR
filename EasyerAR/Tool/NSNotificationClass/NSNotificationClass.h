//
//  NSNotificationClass.h
//  EasyerAR
//
//  Created by 栗子 on 2018/5/8.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#ifndef NSNotificationClass_h
#define NSNotificationClass_h



#define EASYAR_SCAN_SUCCESS @"EASYAR_SCAN_SUCCESS"

typedef void(^voidBlock)(void);
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;


#endif /* NSNotificationClass_h */
