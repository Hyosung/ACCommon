//
//  UIImageView+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "UIImageView+ACAdditions.h"

static char * kACTapGestureBlockKey = "kACTapGestureBlockKey";
static char * kACLongPressGestureBlockKey = "kACLongPressGestureBlockKey";

@implementation UIImageView (ACAdditions)

#pragma mark - TapGesture

- (void)addTapGesture:(void (^)(UIImageView *))tapBlock {
    [self addTapGesture:tapBlock forKey:_cmd];
}

- (void)addTapGesture:(void (^)(UIImageView *))tapBlock forKey:(const void *)key {
    objc_setAssociatedObject(self, kACTapGestureBlockKey, tapBlock, OBJC_ASSOCIATION_COPY);
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapGesture];
    if (key) {
        
        objc_setAssociatedObject(self, key, tapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer *) gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        
        void (^tapBlock)(UIImageView *imageView) = objc_getAssociatedObject(self, kACTapGestureBlockKey);
        if (tapBlock) {
            tapBlock(self);
        }
    }
}

- (void)addLongPressGesture:(void(^)(UIImageView *imageView)) longPressBlock {
    objc_setAssociatedObject(self, kACLongPressGestureBlockKey, longPressBlock, OBJC_ASSOCIATION_COPY);
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:longPressGesture];
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *) gesture {
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        void (^longPressBlock)(UIImageView *imageView) = objc_getAssociatedObject(self, kACLongPressGestureBlockKey);
        if (longPressBlock) {
            longPressBlock(self);
        }
    }
}

- (void)removeGestureForKey:(const void *)key {
    if (key) {
        UIGestureRecognizer *gesture = objc_getAssociatedObject(self, key);
        [self removeGestureRecognizer:gesture];
        gesture = nil;
    }
}

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)setACImageURLString:(NSString *)anURLString {
    NSURL *URL = [NSURL URLWithString:anURLString];
    UIImage *placeholderImage = [ACUtilitys drawPlaceholderWithSize:self.size];
    __weak typeof(self) weakSelf = self;
    [self setImageWithURL:URL
         placeholderImage:placeholderImage
                completed:^(UIImage *image,NSError *error,SDImageCacheType cacheType)
    {
        if (image && !error) {
            
            UIImage *newImage = [ACUtilitys zoomImageWithSize:weakSelf.size image:image];
            weakSelf.image = newImage;
        }
    }];
}
#endif

@end
