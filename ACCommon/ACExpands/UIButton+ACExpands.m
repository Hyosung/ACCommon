//
//  UIButton+ACExpands.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "UIButton+ACExpands.h"

@implementation UIButton (ACExpands)

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)setACImageURLString:(NSString *)anURLString {
    [self setACImageURLString:anURLString forState:UIControlStateNormal];
}

- (void)setACImageURLString:(NSString *)anURLString forState:(UIControlState)state {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtils drawPlaceholderWithSize:self.frame.size];
    
    __weak typeof(self) weakSelf = self;
    [self setImageWithURL:URL forState:state placeholderImage:placeholderImage
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                    
                    if (image && !error) {
                        UIImage *newImage = [ACUtils zoomImageWithSize:weakSelf.frame.size image:image];
                        [weakSelf setImage:newImage forState:state];
                    }
                }];
}

- (void)setACBackgroundImageURLString:(NSString *) anURLString {
    [self setACBackgroundImageURLString:anURLString forState:UIControlStateNormal];
}

- (void)setACBackgroundImageURLString:(NSString *) anURLString forState:(UIControlState)state {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtils drawPlaceholderWithSize:self.frame.size];
    
    __weak typeof(self) weakSelf = self;
    [self setBackgroundImageWithURL:URL forState:state placeholderImage:placeholderImage
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                              
                              if (image && !error) {
                                  UIImage *newImage = [ACUtils zoomImageWithSize:weakSelf.frame.size image:image];
                                  [weakSelf setBackgroundImage:newImage forState:state];
                              }
                          }];
}
#endif

@end
