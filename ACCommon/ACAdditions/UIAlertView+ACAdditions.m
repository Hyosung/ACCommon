//
//  UIAlertView+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 13-12-26.
//  Copyright (c) 2013年 Crazy Stone. All rights reserved.
//

#import "UIAlertView+ACAdditions.h"

@implementation UIAlertView (ACAdditions)

#pragma mark - Delegate transform block

- (void)handlerClickedButton:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerCancel:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerWillPresent:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerDidPresent:(void(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerWillDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerDidDismiss:(void(^)(UIAlertView *alertView, NSInteger buttonIndex)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}

- (void)handlerShouldEnableFirstOtherButton:(BOOL(^)(UIAlertView *alertView)) anBlock {
    
    self.delegate = self;
    objc_setAssociatedObject(self, _cmd, anBlock, OBJC_ASSOCIATION_COPY);
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, @selector(handlerClickedButton:));
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, @selector(handlerCancel:));
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, @selector(handlerWillPresent:));
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
    void (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, @selector(handlerDidPresent:));
    if (anBlock) {
        anBlock(alertView);
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, @selector(handlerWillDismiss:));
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    void (^anBlock)(UIAlertView *alertView, NSInteger buttonIndex) = objc_getAssociatedObject(self, @selector(handlerDidDismiss:));
    if (anBlock) {
        anBlock(alertView,buttonIndex);
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    BOOL (^anBlock)(UIAlertView *alertView) = objc_getAssociatedObject(self, @selector(handlerShouldEnableFirstOtherButton:));
    if (anBlock) {
        return anBlock(alertView);
    }
    return YES;
}

@end
