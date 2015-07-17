//
//  UIButton+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "UIButton+ACAdditions.h"

@implementation UIButton (ACAdditions)

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)ac_setImageWithURLString:(NSString *) URLString {
    [self ac_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:nil completion:NULL];
}

- (void)ac_setImageWithURLString:(NSString *) URLString
                placeholderImage:(UIImage *) placeholderImage {
    
    [self ac_setImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setImageWithURLString:(NSString *) URLString
                        forState:(UIControlState) state
                placeholderImage:(UIImage *) placeholderImage {
    
    [self ac_setImageWithURLString:URLString forState:state placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setImageWithURLString:(NSString *) URLString
                        forState:(UIControlState) state
                placeholderImage:(UIImage *) placeholderImage
                      completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    
}

- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString {
    [self ac_setBackgroundImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:nil completion:NULL];
}

- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                          placeholderImage:(UIImage *) placeholderImage {
    
    [self ac_setBackgroundImageWithURLString:URLString forState:UIControlStateNormal placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                                  forState:(UIControlState) state
                          placeholderImage:(UIImage *) placeholderImage {
    
    [self ac_setBackgroundImageWithURLString:URLString forState:state placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                                  forState:(UIControlState) state
                          placeholderImage:(UIImage *) placeholderImage
                                completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    
}
#endif

@end
