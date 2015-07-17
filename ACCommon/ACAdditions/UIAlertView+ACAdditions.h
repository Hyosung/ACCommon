//
//  UIAlertView+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 13-12-26.
//  Copyright (c) 2013年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (ACAdditions) <UIAlertViewDelegate>

#pragma mark - Delegate transform block

- (void)handlerClickedButton:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock;
- (void)handlerCancel:(void(^)(UIAlertView *alertView)) anBlock;
- (void)handlerWillPresent:(void(^)(UIAlertView *alertView)) anBlock;
- (void)handlerDidPresent:(void(^)(UIAlertView *alertView)) anBlock;
- (void)handlerWillDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock;
- (void)handlerDidDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock;
- (void)handlerShouldEnableFirstOtherButton:(BOOL(^)(UIAlertView *alertView)) anBlock;

@end
