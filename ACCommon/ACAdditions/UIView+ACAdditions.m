//
//  UIView+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "UIView+ACAdditions.h"

@implementation UIView (ACAdditions)


#pragma mark - Frame Simplify

- (CGSize)size {
    return self.frame.size;
}

- (void)setSize:(CGSize)size {
    CGRect newFrame = self.frame;
    newFrame.size = size;
    self.frame = newFrame;
}

- (CGPoint)origin {
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin {
    
    CGRect newFrame = self.frame;
    newFrame.origin = origin;
    self.frame = newFrame;
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (void)setWidth:(CGFloat)width {
    
    CGRect newFrame = self.frame;
    newFrame.size.width = width;
    self.frame = newFrame;
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

- (void)setHeight:(CGFloat)height {
    
    CGRect newFrame = self.frame;
    newFrame.size.height = height;
    self.frame = newFrame;
}

- (CGFloat)top {
    return CGRectGetMinY(self.frame);
}

- (void)setTop:(CGFloat)top {
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = top;
    self.frame = newFrame;
}

- (CGFloat)left {
    return CGRectGetMinX(self.frame);
}

- (void)setLeft:(CGFloat)left {
    
    CGRect newFrame = self.frame;
    newFrame.origin.x = left;
    self.frame = newFrame;
}

- (CGFloat)bottom {
    return CGRectGetMaxY(self.frame);
}

- (void)setBottom:(CGFloat)bottom {
    
    CGRect newFrame = self.frame;
    newFrame.origin.y = bottom - CGRectGetHeight(self.frame);
    self.frame = newFrame;
}

- (CGFloat)right {
    return CGRectGetMaxX(self.frame);
}

- (void)setRight:(CGFloat)right {
    
    CGRect newFrame = self.frame;
    newFrame.origin.x = right - CGRectGetWidth(self.frame);
    self.frame = newFrame;
}

- (void)setLeftTopOffset:(UIOffset) offset {
    CGRect newFrame = self.frame;
    newFrame.origin.x = offset.horizontal;
    newFrame.origin.y = offset.vertical;
    self.frame = newFrame;
}

- (UIOffset)leftTopOffset {
    UIOffset offset = UIOffsetMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame));
    return offset;
}

- (void)setRightBottomOffset:(UIOffset) offset {
    CGRect newFrame = self.frame;
    newFrame.origin.x = offset.horizontal - CGRectGetWidth(self.frame);
    newFrame.origin.y = offset.vertical - CGRectGetHeight(self.frame);
    self.frame = newFrame;
}

- (UIOffset)rightBottomOffset {
    UIOffset offset = UIOffsetMake(CGRectGetMaxX(self.frame), CGRectGetMaxY(self.frame));
    return offset;
}

#pragma mark - View 

- (UIImage *)snapshot {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)saveSnapshotToPhotosAlbum {
    UIImage *image = [self snapshot];
    [self saveImageToPhotosAlbum:image];
}

- (void)saveImageToPhotosAlbum:(UIImage *) image {
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}

- (void)imageSavedToPhotosAlbum:(UIImage *)image
       didFinishSavingWithError:(NSError *)error
                    contextInfo:(void *) contextInfo {
    NSString *message;
    NSString *title;
    if (!error) {
        title = @"成功提示";
        message = @"成功保存到相册";
    } else {
        title = @"失败提示";
        message = [error description];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"知道了"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - UIViewController

- (UIViewController *)viewController {
    id result = nil;
    
    id nextResponder = [self nextResponder];
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UITabBarController class]]) {
            UITabBarController *tabBarController = nextResponder;
            result = tabBarController.selectedViewController;
            if ([result isKindOfClass:[UINavigationController class]]) {
                UINavigationController *navigationController = result;
                result = navigationController.visibleViewController;
            }
            break;
        }
        else if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = result;
            result = navigationController.visibleViewController;
            break;
        }
        else if ([nextResponder isKindOfClass:[UIViewController class]]) {
            result = nextResponder;
            break;
        }
        nextResponder = [nextResponder nextResponder];
    }
    
    return result;
}

- (UIViewController *)rootViewController {
    id result = nil;
    
    id nextResponder = [self nextResponder];
    while (nextResponder != nil) {
        if ([nextResponder isKindOfClass:[UITabBarController class]] ||
            [nextResponder isKindOfClass:[UINavigationController class]] ||
            [nextResponder isKindOfClass:[UIViewController class]]) {
            result = nextResponder;
            break;
        }
        nextResponder = [nextResponder nextResponder];
    }
    
    return result;
}

@end
