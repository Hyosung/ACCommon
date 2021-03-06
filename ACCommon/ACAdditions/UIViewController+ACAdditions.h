//
//  UIViewController+ACAdditions.h
//  ACCommon
//
//  Created by i云 on 14/9/25.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ACAdditions) <UIGestureRecognizerDelegate>

- (UIViewController *)rootViewController;

- (void)touchViewDismissKeyboard;

- (void)addRefreshHeaderWithScrollView:(UIScrollView *) scrollView
                       refreshingBlock:(void (^)())block;
- (void)addRefreshFooterWithScrollView:(UIScrollView *) scrollView
                       refreshingBlock:(void (^)())block;

@end
