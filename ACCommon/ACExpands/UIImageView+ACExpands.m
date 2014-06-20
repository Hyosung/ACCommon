//
//  UIImageView+ACExpands.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "UIImageView+ACExpands.h"

@implementation UIImageView (ACExpands)

#pragma mark - TapGesture

- (void)addTapGesture:(void (^)(UIImageView *))tapBlock {
    objc_setAssociatedObject(self, _cmd, tapBlock, OBJC_ASSOCIATION_COPY);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
}

- (void)handleTapGesture {
    void (^tapBlock)(UIImageView *imageView) = objc_getAssociatedObject(self, @selector(addTapGesture:));
    if (tapBlock) {
        tapBlock(self);
    }
}

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)setACImageURLString:(NSString *)anURLString {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtils drawPlaceholderWithSize:self.size];
    __weak typeof(self) weakSelf = self;
    [self setImageWithURL:URL
         placeholderImage:placeholderImage
                completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType)
    {
        if (image && !error) {
            
            UIImage *newImage = [ACUtils zoomImageWithSize:weakSelf.size image:image];
            weakSelf.image = newImage;
        }
    }];
}
#endif

@end
