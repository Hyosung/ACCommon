//
//  UIViewController+ACAdditions.m
//  ACCommon
//
//  Created by i云 on 14/9/25.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "UIViewController+ACAdditions.h"

@interface UIViewController ()
@property (nonatomic, strong) id <NSObject> observerWillShow;
@property (nonatomic, strong) id <NSObject> observerWillHide;
@end

@implementation UIViewController (ACAdditions)

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillHide];
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerWillShow];
}

- (void)touchViewDismissKeyboard {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handleTapGesture:)];
    tapGesture.delegate = self;
    tapGesture.cancelsTouchesInView = NO;

    __weak __typeof(&*self)weakSelf = self;
    self.observerWillShow = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification
                                                                              object:nil
                                                                               queue:[NSOperationQueue mainQueue]
                                                                          usingBlock:
     ^ (NSNotification *note) {
         
         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
         [strongSelf.view addGestureRecognizer:tapGesture];
     }];
    
    self.observerWillHide = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification
                                                                              object:nil
                                                                               queue:[NSOperationQueue mainQueue]
                                                                          usingBlock:
     ^ (NSNotification *note) {
         
         __strong __typeof(&*weakSelf)strongSelf = weakSelf;
         [strongSelf.view removeGestureRecognizer:tapGesture];
     }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTapGesture:(UITapGestureRecognizer *) gesture {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
//    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}


- (void)addRefreshHeaderWithScrollView:(UIScrollView *) scrollView refreshingBlock:(void (^)())block {
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
//        scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:block];
//        scrollView.header.lastUpdatedTimeKey = ACSSTR(@"kRefreshHeader%@%@%@", NSStringFromClass([self class]), self.navigationItem.title, @(scrollView.tag));
//        [(MJRefreshNormalHeader *)scrollView.header setTitle:@"下拉刷新"
//                                                    forState:MJRefreshStateIdle];
//        [(MJRefreshNormalHeader *)scrollView.header setTitle:@"松开刷新"
//                                                    forState:MJRefreshStatePulling];
//        [(MJRefreshNormalHeader *)scrollView.header setTitle:@"正在刷新..."
//                                                    forState:MJRefreshStateRefreshing];
    }
}

- (void)addRefreshFooterWithScrollView:(UIScrollView *) scrollView refreshingBlock:(void (^)())block {
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
//        scrollView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:block];
//        
//        // 初始化文字
//        [(MJRefreshAutoNormalFooter *)scrollView.footer setTitle:@"加载更多"
//                                                        forState:MJRefreshStateIdle];
//        [(MJRefreshAutoNormalFooter *)scrollView.footer setTitle:@"正在加载中..."
//                                                        forState:MJRefreshStateRefreshing];
//        [(MJRefreshAutoNormalFooter *)scrollView.footer setTitle:@"已全部加载"
//                                                        forState:MJRefreshStateNoMoreData];
    }
}

@end
