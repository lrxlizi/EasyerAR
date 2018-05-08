//
//  PopView.h
//  helloar
//
//  Created by 栗子 on 2018/4/26.
//  Copyright © 2018年 VisionStar Information Technology (Shanghai) Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopView : UIView

@property(nonatomic,copy)void(^popBlock)(void);
- (void)show:(BOOL)animated;

@end
