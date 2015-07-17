//
//  UINavigationController+ACSideslip.m
//  ACCommon
//
//  Created by 暁星 on 15/7/6.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "UINavigationController+ACSideslip.h"

#import "UIViewController+ACSideslip.h"
#import <objc/runtime.h>

@implementation UINavigationController (ACSideslip)

+ (void)load {
    
    //新增并交换interactivePopGestureRecognizer的回调方法
    Class _UINavigationInteractiveTransition = NSClassFromString(@"_UINavigationInteractiveTransition");
    Method custom_HandleNavigationTransition = class_getInstanceMethod([self class], @selector(acHandleNavigationTransition:));
    Method handleNavigationTransition = class_getInstanceMethod(_UINavigationInteractiveTransition, NSSelectorFromString(@"handleNavigationTransition:"));
    class_addMethod(_UINavigationInteractiveTransition, method_getName(custom_HandleNavigationTransition), method_getImplementation(custom_HandleNavigationTransition), method_getTypeEncoding(custom_HandleNavigationTransition));
    Method new_HandleNavigationTransition = class_getInstanceMethod(_UINavigationInteractiveTransition, @selector(acHandleNavigationTransition:));
    method_exchangeImplementations(handleNavigationTransition, new_HandleNavigationTransition);
    
    //交换pushViewController:animated:
    Method acNavigation_pushViewController = class_getInstanceMethod([self class], @selector(acNavigation_pushViewController:animated:));
    Method pushViewController = class_getInstanceMethod([self class], @selector(pushViewController:animated:));
    method_exchangeImplementations(pushViewController, acNavigation_pushViewController);
    
    //交换popViewControllerAnimated:
    Method acNavigation_popViewControllerAnimated = class_getInstanceMethod([self class], @selector(acNavigation_popViewControllerAnimated:));
    Method popViewControllerAnimated = class_getInstanceMethod([self class], @selector(popViewControllerAnimated:));
    method_exchangeImplementations(popViewControllerAnimated, acNavigation_popViewControllerAnimated);
    
    //替换viewDidLoad
    Method viewDidLoad = class_getInstanceMethod([self class], @selector(viewDidLoad));
    class_replaceMethod([self class], @selector(viewDidLoad), [self instanceMethodForSelector:@selector(acNavigation_viewDidLoad)], method_getTypeEncoding(viewDidLoad));
}

- (void)acHandleNavigationTransition:(UIGestureRecognizer *) gesture {
    UINavigationController *__weak navigationController = (UINavigationController *)[gesture.view nextResponder];
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)] && gesture.state == UIGestureRecognizerStateBegan) {
        if ([navigationController.viewControllers firstObject] != navigationController.topViewController) {
            
            navigationController.interactivePopGestureRecognizer.enabled = navigationController.topViewController.allowSideslipReturn;
        }
        else {
            navigationController.interactivePopGestureRecognizer.enabled = NO;
        }
    }
    
    [self acHandleNavigationTransition:gesture];
}

- (void)acNavigation_viewDidLoad {
    [super viewDidLoad];
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.delegate = self;
    }
}

- (void)acNavigation_pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    @synchronized(self) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
        if (self.viewControllers.count > 0) {
            
            [viewController addReturnsButton];
        }
        [self acNavigation_pushViewController:viewController animated:animated];
    }
}

- (UIViewController *)acNavigation_popViewControllerAnimated:(BOOL)animated {
    @synchronized(self) {
        return [self acNavigation_popViewControllerAnimated:animated];
    }
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    // Enable the gesture again once the new controller is shown
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if ([navigationController.viewControllers firstObject] != viewController) {
            
            self.interactivePopGestureRecognizer.enabled = viewController.allowSideslipReturn;
        }
        else {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}


@end
