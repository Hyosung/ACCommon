//
//  NSString+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ACAdditions)

#pragma mark - md5

/**
 md5加密
 */
- (NSString *)md5;

#pragma mark - Base64

/**
 Base64加密
 */
- (NSString*)encodeBase64;

/**
 Base64解密
 */
- (NSString*)decodeBase64;

#pragma mark - String Validate

/**
 字符串验证
 */
- (BOOL)validateEmail;
- (BOOL)validateCarNo;
- (BOOL)validateNumber;
- (BOOL)validateMobile;
- (BOOL)validateNotNull;
- (BOOL)validateCarType;
- (BOOL)validateLandline;
- (BOOL)validateUserName;
- (BOOL)validateFloatNumber;
- (BOOL)validateIdentityCard;

#pragma mark - String Drawing

/**
 字符串绘制成图片
 */
- (UIImage *)drawImageWithSize:(CGSize) size andFont:(UIFont *) font andColor:(UIColor *) color;

#pragma mark - 字符串size计算

/**
 计算文本size 只针对单行
 @font 字体
 */
- (CGSize)computeSizeWithFont:(UIFont *) font;

/**
 计算文本宽度 只针对多行
 @font 字体
 @height 默认高度
 */
- (CGFloat)computeWidthWithFont:(UIFont *) font height:(CGFloat) height;

/**
 计算文本的高度 只针对多行
 @font 字体
 @width 默认宽度
 */
- (CGFloat)computeHeightWithFont:(UIFont *) font width:(CGFloat) width;

#pragma mark - MIME

/**
 返回指定路径下文件的MIME
 */
- (NSString*)fileMIMEType:(NSString*) file;

#pragma mark - JSON
- (id)JSON;
- (id)JSON:(NSError **) error;

@end
