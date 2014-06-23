//
//  UIAlertView+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 13-12-26.
//  Copyright (c) 2013年 Alone Coding. All rights reserved.
//

#import "UIAlertView+ACAdditions.h"

static char * const kACCanelKey                        = "kACCanelKey";
static char * const kACDidPresentKey                   = "kACDidPresentKey";
static char * const kACDidDismissKey                   = "kACDidDismissKey";
static char * const kACWillDismissKey                  = "kACWillDismissKey";
static char * const kACWillPresentKey                  = "kACWillPresentKey";
static char * const kACClickedButtonKey                = "kACClickedButtonKey";
static char * const kACShouldEnableFirstOtherButtonKey = "kACShouldEnableFirstOtherButtonKey";

@implementation UIAlertView (ACAdditions)

#pragma mark - Delegate transform block

- (void)handlerClickedButton:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    self.delegate = self;
    objc_setAssociatedObject(self, kACClickedButtonKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerCancel:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACCanelKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerWillPresent:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACWillPresentKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerDidPresent:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACDidPresentKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerWillDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACWillDismissKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerDidDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACDidDismissKey, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerShouldEnableFirstOtherButton:(BOOL(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, kACShouldEnableFirstOtherButtonKey, anBlock, OBJC_ASSOCIATION_COPY);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, kACClickedButtonKey);
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, kACCanelKey);
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, kACWillPresentKey);
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, kACDidPresentKey);
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, kACWillDismissKey);
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, kACDidDismissKey);
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    BOOL (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, kACShouldEnableFirstOtherButtonKey);
    if (anBlock) {
        return anBlock(alertView);
    }
    return YES;
}

@end
