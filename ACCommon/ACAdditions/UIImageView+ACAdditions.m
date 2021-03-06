//
//  UIImageView+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
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
- (void)ac_setImageWithURLString:(NSString *) URLString {
    [self ac_setImageWithURLString:URLString placeholderImage:nil completion:NULL];
}

- (void)ac_setImageWithURLString:(NSString *) URLString placeholderImage:(UIImage *) placeholderImage {
    [self ac_setImageWithURLString:URLString placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setImageWithURLString:(NSString *) URLString completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    [self ac_setImageWithURLString:URLString placeholderImage:nil completion:completionBlock];
}

- (void)ac_setImageWithURLString:(NSString *) URLString placeholderImage:(UIImage *) placeholderImage completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    
}

- (void)ac_setGrayImageWithURLString:(NSString *) URLString {
    [self ac_setGrayImageWithURLString:URLString placeholderImage:nil completion:NULL];
}

- (void)ac_setGrayImageWithURLString:(NSString *) URLString placeholderImage:(UIImage *) placeholderImage {
    [self ac_setGrayImageWithURLString:URLString placeholderImage:placeholderImage completion:NULL];
}

- (void)ac_setGrayImageWithURLString:(NSString *) URLString completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    [self ac_setGrayImageWithURLString:URLString placeholderImage:nil completion:completionBlock];
}
- (void)ac_setGrayImageWithURLString:(NSString *) URLString placeholderImage:(UIImage *) placeholderImage completion:(void (^)(UIImage *image, BOOL isCachedData)) completionBlock {
    
}

- (void)ac_setRoundedImageWithURLString:(NSString *) URLString
                        placeholderImage:(UIImage *) placeholderImage {
    
}
#endif

@end
