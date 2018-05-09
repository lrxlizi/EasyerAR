//
//  ToolClass.h
//  EasyerAR
//
//  Created by 栗子 on 2018/5/9.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ToolClass : NSObject
//提示框
+ (void)addTipsWithErrorMessage:(NSString *)errorMessage andTarget:(UINavigationController *)nav;

@end
