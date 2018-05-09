//
//  ToolClass.m
//  EasyerAR
//
//  Created by 栗子 on 2018/5/9.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import "ToolClass.h"

@implementation ToolClass
//提示框
+ (void)addTipsWithErrorMessage:(NSString *)errorMessage andTarget:(UINavigationController *)nav
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [nav presentViewController:alertController animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [nav dismissViewControllerAnimated:YES completion:nil];
    });
}

@end
