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
}

@end
