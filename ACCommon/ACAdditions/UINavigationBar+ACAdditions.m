//
//  UINavigationBar+ACAdditions.m
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "UINavigationBar+ACAdditions.h"

@implementation UINavigationBar (ACAdditions)

- (void)ac_setBackgroundImage:(UIImage *)image {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 50000
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        [self setBackgroundImage:image forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
    #else
        [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    #endif
#else
    // Insert ImageView
    __autoreleasing UIImageView *_imgv = [[UIImageView alloc] initWithImage:image];
    _imgv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imgv.frame = self.bounds;
    
    [self ac_setContentView:_imgv];
#endif
}

- (void)ac_setContentView:(UIView *)view {
    // Insert View
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.frame = self.bounds;
    UIView *v = self.subviews.firstObject;
    v.layer.zPosition = -FLT_MAX;
    
    view.layer.zPosition = -FLT_MAX + 1;
    [self insertSubview:view atIndex:1];
}

@end
