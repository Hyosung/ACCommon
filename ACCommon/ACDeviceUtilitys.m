//
//  ACDeviceUtilitys.m
//  ACCommon
//
//  Created by 暁星 on 15/7/15.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACDeviceUtilitys.h"

CGSize ACScreenSize() {
    return [UIScreen mainScreen].bounds.size;
}

CGFloat ACScreenWidth() {
    return [UIScreen mainScreen].bounds.size.width;
}

CGFloat ACScreenHeight() {
    return [UIScreen mainScreen].bounds.size.height;
}

CGRect ACScreenBounds() {
    return [UIScreen mainScreen].bounds;
}

const CGFloat ACTabBarHeight = 49.0;
const CGFloat ACToolBarHeight = 44.0;
const CGFloat ACStatusBarHeight = 20.0;
const CGFloat ACNavigationBarHeight = 44.0;

CGFloat ACAppContentHeight() {
    return [UIScreen mainScreen].bounds.size.height - 44.0 - 20.0 - 49.0;
}

CGFloat ACAppContentNoNavBar() {
    
    return [UIScreen mainScreen].bounds.size.height - 44.0 - 20.0;
}

CGFloat ACAppContentNoTabBar() {
    
    return [UIScreen mainScreen].bounds.size.height - 20.0 - 49.0;
}

CGFloat ACSystemVersion() {
    return [[UIDevice currentDevice].systemVersion floatValue];
}

NSString * ACCurrentLanguage() {
    return [NSLocale preferredLanguages].firstObject;
}

UIInterfaceOrientation ACStatusOrientation() {
    return [UIApplication sharedApplication].statusBarOrientation;
}

UIDeviceOrientation ACCurrentOrientation() {
    return [UIDevice currentDevice].orientation;
}

bool iOS7Above() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    return ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0);
#else
    return false;
#endif
}

bool iOS8Above() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    return ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0);
#else
    return false;
#endif
}

bool iOS9Above() {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    return ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0);
#else
    return false;
#endif
}

bool isiPad() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

bool isiPhone4_4s() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640.0, 960.0), [[UIScreen mainScreen] currentMode].size) : false);
}

bool isiPhone5_5s() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640.0, 1136.0), [[UIScreen mainScreen] currentMode].size) : false);
}

bool isiPhone6() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750.0, 1334.0), [[UIScreen mainScreen] currentMode].size) : false);
}

bool isiPhone6Plus() {
    return ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242.0, 2208.0), [[UIScreen mainScreen] currentMode].size) : false);
}

CGFloat ACViewGetWidth(UIView *view) {
    if (!view) return 0.0;
    return view.bounds.size.width;
}

CGFloat ACViewGetHeight(UIView *view) {
    if (!view) return 0.0;
    return view.bounds.size.height;
}

CGFloat ACVCGetWidth(UIViewController *self) {
    if (!self || !self.view) return 0.0;
    return self.view.bounds.size.width;
}

CGFloat ACVCGetHeight(UIViewController *self) {
    if (!self || !self.view) return 0.0;
    return self.view.bounds.size.height;
}

bool ACSystemVersionLessThan(NSString *version) {
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedDescending);
}

bool ACSystemVersionEqualTo(NSString *version) {
    
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedSame);
}

bool ACSystemVersionGreaterThan(NSString *version) {
    
    return ([[[UIDevice currentDevice] systemVersion] compare:version options:NSNumericSearch] == NSOrderedAscending);
}

