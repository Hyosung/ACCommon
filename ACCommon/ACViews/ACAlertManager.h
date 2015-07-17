//
//  ACAlertManager.h
//  ACCommon
//
//  Created by 暁星 on 15/4/24.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACAlertManager : NSObject

+ (void)showAlertWithTitle:(NSString *) title
                   message:(NSString *) message
         cancelButtonTitle:(NSString *) cancelButtonTitle
        clickedButtonBlock:(void (^)(NSInteger index)) bblock
         otherButtonTitles:(NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)showAlertWithMessage:(NSString *) message
           cancelButtonTitle:(NSString *) cancelButtonTitle
            otherButtonTitle:(NSString *) otherButtonTitle
          clickedButtonBlock:(void (^)(NSInteger index)) bblock;

+ (void)showActionSheetWithShowObject:(id) object
                                title:(NSString *) title
                    cancelButtonTitle:(NSString *) cancelButtonTitle
               destructiveButtonTitle:(NSString *) destructiveButtonTitle
                   clickedButtonBlock:(void (^)(NSInteger index)) bblock
                    otherButtonTitles:(NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)showActionSheetWithCancelButtonTitle:(NSString *) cancelButtonTitle
                          clickedButtonBlock:(void (^)(NSInteger index)) bblock
                           otherButtonTitles:(NSString *) otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

+ (void)setupRootController:(UIViewController *) controller;
+ (UIViewController *)rootController;

@end
