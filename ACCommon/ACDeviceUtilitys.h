//
//  ACDeviceUtilitys.h
//  ACCommon
//
//  Created by 暁星 on 15/7/15.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#ifndef ACCommon_ACDeviceUtilitys_h
#define ACCommon_ACDeviceUtilitys_h

@class NSString;
#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

CG_EXTERN CGSize ACScreenSize();
CG_EXTERN CGFloat ACScreenWidth();
CG_EXTERN CGFloat ACScreenHeight();
CG_EXTERN CGRect ACScreenBounds();

CG_EXTERN const CGFloat ACTabBarHeight;
CG_EXTERN const CGFloat ACToolBarHeight;
CG_EXTERN const CGFloat ACStatusBarHeight;
CG_EXTERN const CGFloat ACNavigationBarHeight;

CG_EXTERN CGFloat ACAppContentHeight();
CG_EXTERN CGFloat ACAppContentNoNavBar();
CG_EXTERN CGFloat ACAppContentNoTabBar();

CG_EXTERN CGFloat ACSystemVersion();
CG_EXTERN NSString * ACCurrentLanguage();
CG_EXTERN UIInterfaceOrientation ACStatusOrientation();
CG_EXTERN UIDeviceOrientation ACCurrentOrientation();

CG_EXTERN bool iOS7Above();
CG_EXTERN bool iOS8Above();
CG_EXTERN bool iOS9Above();
CG_EXTERN bool isiPad();
CG_EXTERN bool isiPhone4_4s(); //3.5in.
CG_EXTERN bool isiPhone5_5s(); //4.0in.
CG_EXTERN bool isiPhone6(); //4.7in.
CG_EXTERN bool isiPhone6Plus(); //5.5in.

CG_EXTERN CGFloat ACViewGetWidth(UIView *view);
CG_EXTERN CGFloat ACViewGetHeight(UIView *view);
CG_EXTERN CGFloat ACVCGetWidth(UIViewController *self);
CG_EXTERN CGFloat ACVCGetHeight(UIViewController *self);

CG_INLINE bool
__ACSizeNoLessThanSize(CGSize size1, CGSize size2) {
    return size1.width >= size2.width && size1.height >= size2.height;
}

#define ACSizeNoLessThanSize __ACSizeNoLessThanSize

/**
 *  @author Stoney, 15-07-28 13:07:08
 *
 *  @brief  版本号不大于当前版本
 *
 *  @param version 版本号
 *
 */
CG_EXTERN bool ACSystemVersionLessThanEqual(NSString *version);

/**
 *  @author Stoney, 15-07-28 13:07:34
 *
 *  @brief  版本号等于当前版本
 *
 *  @param version 版本号
 *
 */
CG_EXTERN bool ACSystemVersionEqualTo(NSString *version);

/**
 *  @author Stoney, 15-07-28 13:07:48
 *
 *  @brief  版本号不小于当前版本
 *
 *  @param version 版本号
 *
 */
CG_EXTERN bool ACSystemVersionGreaterThanEqual(NSString *version);

/**
 打印代码运行时间
 
 @param ^codeBlock 代码块
 */
CG_EXTERN void ACPrintRunTime(void (^codeBlock)(void));

#endif
