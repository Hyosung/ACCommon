//
//  UIButton+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ACAdditions)

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__

- (void)ac_setImageWithURLString:(NSString *) URLString;
- (void)ac_setImageWithURLString:(NSString *) URLString
                placeholderImage:(UIImage *) placeholderImage;
- (void)ac_setImageWithURLString:(NSString *) URLString
                        forState:(UIControlState) state
                placeholderImage:(UIImage *) placeholderImage;
- (void)ac_setImageWithURLString:(NSString *) URLString
                        forState:(UIControlState) state
                placeholderImage:(UIImage *) placeholderImage
                      completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock;

- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString;
- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                          placeholderImage:(UIImage *) placeholderImage;
- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                                  forState:(UIControlState) state
                          placeholderImage:(UIImage *) placeholderImage;
- (void)ac_setBackgroundImageWithURLString:(NSString *) URLString
                                  forState:(UIControlState) state
                          placeholderImage:(UIImage *) placeholderImage
                                completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock;
#endif

@end
