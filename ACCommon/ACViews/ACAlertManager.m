//
//  ACAlertManager.m
//  ACCommon
//
//  Created by 暁星 on 15/4/24.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACAlertManager.h"

#import <objc/runtime.h>

typedef NS_ENUM(NSUInteger, ACAlertManagerStyle) {
    ACAlertManagerStyleActionSheet = 0,
    ACAlertManagerStyleAlert
};

@interface ACAlertManager () <UIAlertViewDelegate, UIActionSheetDelegate>

+ (void)showAlertWithStyle:(ACAlertManagerStyle) style
                     title:(NSString *) title
                   message:(NSString *) message
                showObject:(id) object
         cancelButtonTitle:(NSString *) cancelButtonTitle
    destructiveButtonTitle:(NSString *) destructiveButtonTitle
        clickedButtonBlock:(void (^)(NSInteger index)) bblock
         otherButtonTitles:(NSArray *)otherButtonTitles;

@end

@implementation ACAlertManager

static char ACAlertButtonBlockKey;
static char ACActionSheetButtonBlockKey;

+ (void)showAlertWithStyle:(ACAlertManagerStyle)style
                     title:(NSString *)title
                   message:(NSString *)message
                showObject:(id) object
         cancelButtonTitle:(NSString *)cancelButtonTitle
    destructiveButtonTitle:(NSString *)destructiveButtonTitle
        clickedButtonBlock:(void (^)(NSInteger))bblock
         otherButtonTitles:(NSArray *)otherButtonTitles {
    
    if (NSClassFromString(@"UIAlertController") != NULL) {
        UIAlertControllerStyle alertStyle = (style == ACAlertManagerStyleAlert) ? UIAlertControllerStyleAlert : UIAlertControllerStyleActionSheet;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:message
                                                                          preferredStyle:alertStyle];
        if (cancelButtonTitle) {
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:^(UIAlertAction *action) {
                                                                     if (bblock != NULL) {
                                                                         bblock([alertController.actions indexOfObject:action]);
                                                                     }
                                                                 }];
            [alertController addAction:cancelAction];
        }
        
        if (destructiveButtonTitle) {
            
            
            UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:destructiveButtonTitle
                                                                        style:UIAlertActionStyleDestructive
                                                                      handler:^(UIAlertAction *action) {
                                                                          if (bblock != NULL) {
                                                                              bblock([alertController.actions indexOfObject:action]);
                                                                          }
                                                                      }];
            
            [alertController addAction:destructiveAction];
        }
        
        for (NSString *otherTitle in otherButtonTitles) {
            UIAlertAction *titleAction = [UIAlertAction actionWithTitle:otherTitle
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                                                                    if (bblock != NULL) {
                                                                        bblock([alertController.actions indexOfObject:action]);
                                                                    }
                                                                }];
            [alertController addAction:titleAction];
        }
        NSAssert([self rootController], @"请通过[ACAlertManager setupRootController:<#rootController#>] 设置根视图");
        [[self rootController] presentViewController:alertController
                                            animated:YES
                                          completion:NULL];
    }
    else {
        if (style == ACAlertManagerStyleAlert) {
            
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:message
                                                               delegate:self
                                                      cancelButtonTitle:cancelButtonTitle
                                                      otherButtonTitles:nil];
            for (NSString *otherTitle in otherButtonTitles) {
                [alertView addButtonWithTitle:otherTitle];
            }
            
            objc_setAssociatedObject(self, &ACAlertButtonBlockKey, bblock, OBJC_ASSOCIATION_COPY_NONATOMIC);
            
            [alertView show];
        }
        else {
            __weak id <UIActionSheetDelegate> delegate = (id <UIActionSheetDelegate>)self;
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:delegate
                                                            cancelButtonTitle:cancelButtonTitle
                                                       destructiveButtonTitle:destructiveButtonTitle
                                                            otherButtonTitles:nil];
            
            for (NSString *otherTitle in otherButtonTitles) {
                [actionSheet addButtonWithTitle:otherTitle];
            }
            
            objc_setAssociatedObject(self, &ACActionSheetButtonBlockKey, bblock, OBJC_ASSOCIATION_COPY_NONATOMIC);
            if (!object ||
                ![object isKindOfClass:[UIView class]] ||
                ![object isKindOfClass:[UIBarButtonItem class]]) {
                object = [self rootController].view;
                NSAssert(object, @"请通过[ACAlertManager setupRootController:<#rootController#>] 设置根视图");
            }
            
            if ([object isKindOfClass:[UITabBar class]]) {
                [actionSheet showFromTabBar:object];
            }
            else if ([object isKindOfClass:[UIToolbar class]]) {
                [actionSheet showFromToolbar:object];
            }
            else if ([object isKindOfClass:[UIBarButtonItem class]]) {
                [actionSheet showFromBarButtonItem:object animated:YES];
            }
            else {
                [actionSheet showInView:object];
            }
        }
    }
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle
        clickedButtonBlock:(void (^)(NSInteger index))bblock
         otherButtonTitles:(NSString *)otherButtonTitles, ... {

    va_list list;
    va_start(list, otherButtonTitles);
    NSMutableArray *otherTitles = [NSMutableArray array];
    for (NSString *constTitle = otherButtonTitles;
         constTitle != nil;
         constTitle = va_arg(list, NSString *)) {
        [otherTitles addObject:constTitle];
    }
    va_end(list);
    
    [self showAlertWithStyle:ACAlertManagerStyleAlert
                       title:title
                     message:message
                  showObject:nil
           cancelButtonTitle:cancelButtonTitle
      destructiveButtonTitle:nil
          clickedButtonBlock:bblock
           otherButtonTitles:otherTitles];
}

+ (void)showAlertWithMessage:(NSString *)message
           cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitle:(NSString *)otherButtonTitle
          clickedButtonBlock:(void (^)(NSInteger index))bblock {
    [self showAlertWithTitle:nil
                     message:message
           cancelButtonTitle:cancelButtonTitle
          clickedButtonBlock:bblock
           otherButtonTitles:otherButtonTitle, nil];
}

+ (void)showActionSheetWithShowObject:(id)object
                                title:(NSString *)title
                    cancelButtonTitle:(NSString *)cancelButtonTitle
               destructiveButtonTitle:(NSString *)destructiveButtonTitle
                   clickedButtonBlock:(void (^)(NSInteger))bblock
                    otherButtonTitles:(NSString *)otherButtonTitles, ... {
    va_list list;
    va_start(list, otherButtonTitles);
    NSMutableArray *otherTitles = [NSMutableArray array];
    for (NSString *constTitle = otherButtonTitles;
         constTitle != nil;
         constTitle = va_arg(list, NSString *)) {
        [otherTitles addObject:constTitle];
    }
    va_end(list);
    
    [self showAlertWithStyle:ACAlertManagerStyleActionSheet
                       title:title
                     message:nil
                  showObject:object
           cancelButtonTitle:cancelButtonTitle
      destructiveButtonTitle:destructiveButtonTitle
          clickedButtonBlock:bblock
           otherButtonTitles:otherTitles];
}

+ (void)showActionSheetWithCancelButtonTitle:(NSString *)cancelButtonTitle
                          clickedButtonBlock:(void (^)(NSInteger))bblock
                           otherButtonTitles:(NSString *)otherButtonTitles, ... {
    va_list list;
    va_start(list, otherButtonTitles);
    NSMutableArray *otherTitles = [NSMutableArray array];
    for (NSString *constTitle = otherButtonTitles;
         constTitle != nil;
         constTitle = va_arg(list, NSString *)) {
        [otherTitles addObject:constTitle];
    }
    va_end(list);
    
    [self showAlertWithStyle:ACAlertManagerStyleActionSheet
                       title:nil
                     message:nil
                  showObject:nil
           cancelButtonTitle:cancelButtonTitle
      destructiveButtonTitle:nil
          clickedButtonBlock:bblock
           otherButtonTitles:otherTitles];
}

+ (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^bblock)(NSInteger index) = objc_getAssociatedObject(self, &ACAlertButtonBlockKey);
    if (bblock != NULL) {
        bblock(buttonIndex);
        objc_setAssociatedObject(self, &ACAlertButtonBlockKey, NULL, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

+ (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^bblock)(NSInteger index) = objc_getAssociatedObject(self, &ACActionSheetButtonBlockKey);
    if (bblock != NULL) {
        bblock(buttonIndex);
        objc_setAssociatedObject(self, &ACActionSheetButtonBlockKey, NULL, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

+ (void)setupRootController:(UIViewController *)controller {
    objc_setAssociatedObject(self, _cmd, controller, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIViewController *)rootController {
    return objc_getAssociatedObject(self, @selector(setupRootController:));
}

@end
