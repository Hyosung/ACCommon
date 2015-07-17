//
//  UIImage+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ACAdditions)

#pragma mark - Image Resize

/*
 缩放传入图片到指定大小
 */
- (UIImage *)zoomImageWithSize:(CGSize) size;

/*
 重置图片的大小，图片不变形，只压缩
 @number 高度或者宽度
 @flag 传入的number值是高度或者宽度 YES:高度，NO:宽度
 */
- (UIImage *)resizedImageWithNumber:(CGFloat)number
                           isHeight:(BOOL)flag;

/**
 重置图片的大小，图片不变形，只压缩,图片居中绘制
 @size 图片大小
 */
- (UIImage *)resizedImageWithSize:(CGSize)size;

/**
 重置图片的大小，图片不变形，只压缩
 @size 图片大小
 */
- (UIImage *)resizedFixedImageWithSize:(CGSize)size;

/*
 知道高度，重置图片大小
 */
- (UIImage *)resizedImageWithHeight:(CGFloat)height;
/*
 知道宽度，重置图片大小
 */
- (UIImage *)resizedImageWithWidth:(CGFloat)width;

/*
 从传入图片上截取指定区域的图片
 */
- (UIImage *)croppedImage:(CGRect)bounds;

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;

- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;

- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

- (UIImage *)fixOrientation;

- (UIImage *)rotatedByDegrees:(CGFloat)degrees;

- (UIImage *)gradientImage;

#pragma mark - Save Image To PhotosAlbum

- (void)savePhotosAlbum;

#pragma mark - Take the color specified point
- (UIColor *)pixelColorAtLocation:(CGPoint)point;

#pragma mark - ImageEffects
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

#pragma mark - 设置图片圆角
- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius;

#pragma mark - UIImage To NSString
- (NSString *)convertString;

#pragma mark Image Draw
- (UIImage *)convertGrayImage;

- (CGFloat)calculateWidthKnownHeight:(CGFloat) height;
- (CGFloat)calculateHeightKnownWidth:(CGFloat) width;
@end
