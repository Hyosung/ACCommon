//
//  UINavigationBar+ACAdditions.h
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (ACAdditions)

/**
 *  @author Stoney, 15-07-16 15:07:21
 *
 *  @brief  设置导航栏的背景 支持大部分iOS版本
 *
 *  @param image 背景图
 */
- (void)ac_setBackgroundImage:(UIImage *)image;

/**
 *  @author Stoney, 15-07-16 15:07:07
 *
 *  @brief  给导航栏添加一个view覆盖在上面
 *
 */
- (void)ac_setContentView:(UIView *)view;

@end
