//
//  UIViewController+ACSideslip.h
//  ACCommon
//
//  Created by 暁星 on 15/7/6.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, ACBarButtonItemDirection) {
    ACBarButtonItemDirectionLeft = 0 ,
    ACBarButtonItemDirectionRight = 1 ,
};

@interface ACBarButtonItemProperty : NSObject

@property (nonatomic) ACBarButtonItemDirection direction;
@property (nonatomic) CGSize size;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *highlightImage;
@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, weak) id target;
@property (nonatomic) SEL action;

@property (nonatomic, copy) void (^handler)();

@property (nonatomic, copy) UIFont *font;
@property (nonatomic, copy) UIColor *titleColor;
@property (nonatomic, copy) UIColor *highlightTitleColor;

@end

@interface UIViewController (ACSideslip) <UIGestureRecognizerDelegate>

/**
 *  @author Stoney, 15-07-01 16:07:11
 *
 *  点击返回按钮时的回调方法
 */
- (void)returnsButtonCallbackMethods:(UIButton *) sender;

/**
 *  @author Stoney, 15-07-01 10:07:14
 *
 *  允许侧滑返回
 */
@property (nonatomic, readonly) BOOL allowSideslipReturn;
- (UIBarButtonItem *)addBarButtonItemProperty:(void (^)(ACBarButtonItemProperty *property))propertyBlock;
- (UIBarButtonItem *)addReturnsButton;

@end
