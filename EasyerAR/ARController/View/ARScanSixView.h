//
//  ARScanSixView.h
//  EasyerAR
//
//  Created by 栗子 on 2018/5/8.
//  Copyright © 2018年 http://www.cnblogs.com/Lrx-lizi/.     https://github.com/lrxlizi/. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ARScanSixView : UIView


/**
 开始动画
 */
- (void)starAnimation;

/**
 停止动画
 */
- (void)stopAnimtion;

/**
 扫描成功动画
 */
- (void)sucessAnimtion;


/**
 成功回调
 */
@property (nonatomic,  copy)voidBlock success;

@end
