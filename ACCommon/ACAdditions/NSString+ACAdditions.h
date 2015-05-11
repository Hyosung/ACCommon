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
 验证邮箱
 */
- (BOOL)validateEmail;

/**
 验证车牌号
 */
- (BOOL)validateCarNo;

/**
 验证数字
 */
- (BOOL)validateNumber;

/**
 验证手机号
 */
- (BOOL)validateMobile;

/**
 验证字符串非空
 */
- (BOOL)validateNotNull;

/**
 验证车型
 */
- (BOOL)validateCarType;

/**
 验证移动号码
 */
- (BOOL)validateCMNumber;

/**
 验证联通号码
 */
- (BOOL)validateCUNumber;

/**
 验证电信号码
 */
- (BOOL)validateCTNumber;

/**
 验证固话
 */
- (BOOL)validateLandline;

/**
 验证用户名
 */
- (BOOL)validateUserName;

/**
 验证URL
 */
- (BOOL)validateURLString;

/**
 验证汉字
 */
- (BOOL)validateCharacters;

/**
 验证双字节字符（包括汉字）
 */
- (BOOL)validateDoubleByte;

/**
 验证浮点型
 */
- (BOOL)validateFloatNumber;

/**
 验证身份证
 */
- (BOOL)validateIdentityCard;

#pragma mark - String Drawing

/**
 字符串绘制成图片
 */
- (UIImage *)drawImageWithSize:(CGSize) size
                       andFont:(UIFont *) font
                      andColor:(UIColor *) color;

#pragma mark - 字符串size计算

/**
 计算文本size 只针对单行
 @param font 字体
 */
- (CGSize)computeSizeWithFont:(UIFont *) font;

/**
 计算文本宽度 只针对多行
 @param font 字体
 @param height 默认高度
 */
- (CGFloat)computeWidthWithFont:(UIFont *) font
                         height:(CGFloat) height;

/**
 计算文本的高度 只针对多行
 @param font 字体
 @param width 默认宽度
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

#pragma mark - NSString To UIImage
- (UIImage *)stringConvertedImage;

#pragma mark - 汉字 To PinYin
- (NSString *)transformToPinyin;


@end
