//
//  UIViewController+ACSideslip.m
//  ACCommon
//
//  Created by 暁星 on 15/7/6.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "UIViewController+ACSideslip.h"

#import <objc/runtime.h>

@implementation ACBarButtonItemProperty
@end

@implementation UIViewController (ACSideslip)

/**
 *  @author Stoney, 15-07-03 19:07:00
 *
 *  移魂大法
 */
+ (void)load {
    
    Method ac_viewDidDisappear = class_getInstanceMethod([self class], @selector(ac_viewDidDisappear:));
    Method ac_viewDidAppear = class_getInstanceMethod([self class], @selector(ac_viewDidAppear:));
    
    Method viewDidDisappear = class_getInstanceMethod([self class], @selector(viewDidDisappear:));
    Method viewDidAppear = class_getInstanceMethod([self class], @selector(viewDidAppear:));
    
    method_exchangeImplementations(viewDidAppear, ac_viewDidAppear);
    method_exchangeImplementations(viewDidDisappear, ac_viewDidDisappear);
}

- (void)ac_viewDidDisappear:(BOOL)animated {
    [self ac_viewDidDisappear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (void)ac_viewDidAppear:(BOOL)animated {
    [self ac_viewDidAppear:animated];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        //在didAppear时置为NO
        isacs_Poping = NO;
    }
}

#pragma mark - Gesture Recognizer Delegate

static BOOL isacs_Poping;
/**
 *  是否正在手势返回中的标示状态
 */
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (!isacs_Poping) {
        isacs_Poping = YES;
        return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    [otherGestureRecognizer requireGestureRecognizerToFail:gestureRecognizer];
    return NO;
}


- (BOOL)allowSideslipReturn {
    return YES;
}

- (void)returnsButtonCallbackMethods:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIBarButtonItem *)addReturnsButton {
    __weak __typeof__(self) __weak_self = self;
    UIBarButtonItem *barButtonItem = [self addBarButtonItemProperty:^(ACBarButtonItemProperty *property) {
        __strong __typeof__(__weak_self) self = __weak_self;
        property.size = CGSizeMake(9.0, 16.5);
        property.image = [UIImage imageNamed:@"return_icon"];
        property.target = self;
        property.action = @selector(returnsButtonCallbackMethods:);
    }];
    return barButtonItem;
}

- (UIBarButtonItem *)addBarButtonItemProperty:(void (^)(ACBarButtonItemProperty *property))propertyBlock {
    ACBarButtonItemProperty *property = [[ACBarButtonItemProperty alloc] init];
    if (propertyBlock != NULL) {
        propertyBlock(property);
    }
    
    if (property.size.width <= 0 ||
        property.size.height <= 0) {
        if (property.title) {
            
            CGSize size = [property.title sizeWithAttributes:@{NSFontAttributeName: property.font}];
            property.size = CGSizeMake(MIN(size.width, 75.0), 30.0);
        }
        else {
            if (property.image || property.backgroundImage) {
                
                __weak UIImage *image = property.image ?: property.backgroundImage;
                
                CGFloat height = MIN(30.0, image.size.height);
                CGFloat scale = image.size.width / image.size.height;
                CGFloat width = scale * height;
                property.size = CGSizeMake(width, height);
            }
        }
    }
    
    UIButton *itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    itemButton.frame = CGRectMake(0.0, 0.0, property.size.width, property.size.height);
    itemButton.exclusiveTouch = YES;
    itemButton.titleLabel.font = property.font;
    itemButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -6.0, 0.0, 6.0);
    [itemButton setTitle:property.title
                forState:UIControlStateNormal];
    [itemButton setImage:property.image
                forState:UIControlStateNormal];
    [itemButton setImage:property.highlightImage
                forState:UIControlStateHighlighted];
    [itemButton setTitleColor:property.titleColor
                     forState:UIControlStateNormal];
    [itemButton setTitleColor:property.highlightTitleColor
                     forState:UIControlStateHighlighted];
    [itemButton setBackgroundImage:property.backgroundImage
                          forState:UIControlStateNormal];
    
    if (property.target == nil || property.action == NULL) {
        property.target = self;
        property.action  = ({
            BOOL isLeft = (property.direction == ACBarButtonItemDirectionLeft);
            isLeft ? @selector(leftBarButtonCallbackEvent:) : @selector(rightBarButtonCallbackEvent:);
        });
        
        if (property.handler != NULL) {
            
            objc_setAssociatedObject(self, property.action, property.handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    [itemButton addTarget:property.target
                   action:property.action
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemButton];
    
    if (property.direction == ACBarButtonItemDirectionLeft) {
        
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }
    else {
        
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    return barButtonItem;
}

- (void)leftBarButtonCallbackEvent:(UIButton *) sender {
    void (^bblock)(UIButton *sender) = objc_getAssociatedObject(self, _cmd);
    if (bblock != NULL) {
        bblock(sender);
    }
}

- (void)rightBarButtonCallbackEvent:(UIButton *) sender {
    void (^bblock)(UIButton *sender) = objc_getAssociatedObject(self, _cmd);
    if (bblock != NULL) {
        bblock(sender);
    }
}

@end
