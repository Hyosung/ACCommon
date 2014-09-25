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
- (void)setACImageURLString:(NSString *)anURLString {
    [self setACImageURLString:anURLString forState:UIControlStateNormal];
}

- (void)setACImageURLString:(NSString *)anURLString forState:(UIControlState)state {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtilitys drawPlaceholderWithSize:self.frame.size];
    
    __weak __typeof(&*self) weakSelf = self;
    [self setImageWithURL:URL forState:state
         placeholderImage:placeholderImage
                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
    {
        if (image && !error) {
            __strong __typeof(&*weakSelf) strongSelf = weakSelf;
            UIImage *newImage = [ACUtilitys zoomImageWithSize:strongSelf.frame.size image:image];
            [strongSelf setImage:newImage forState:state];
        }
    }];
}

- (void)setACBackgroundImageURLString:(NSString *) anURLString {
    [self setACBackgroundImageURLString:anURLString forState:UIControlStateNormal];
}

- (void)setACBackgroundImageURLString:(NSString *) anURLString forState:(UIControlState)state {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtilitys drawPlaceholderWithSize:self.frame.size];
    
    __weak __typeof(&*self) weakSelf = self;
    [self setBackgroundImageWithURL:URL
                           forState:state
                   placeholderImage:placeholderImage
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
     {
         if (image && !error) {
             __strong __typeof(&*weakSelf) strongSelf = weakSelf;
              UIImage *newImage = [ACUtilitys zoomImageWithSize:strongSelf.frame.size image:image];
              [strongSelf setBackgroundImage:newImage forState:state];
          }
     }];
}
#endif

@end
