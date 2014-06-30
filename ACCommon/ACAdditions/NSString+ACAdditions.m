//
//  NSString+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "NSString+ACAdditions.h"

#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"

@interface NSString (Private)

- (BOOL)regularWithPattern:(NSString *) pattern;

@end

@implementation NSString (ACAdditions)

#pragma mark - md5

- (NSString *)md5 {
    const char *str = [self UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *md5Str = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return md5Str;
}

#pragma mark - Base64

- (NSString*)encodeBase64 {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

- (NSString*)decodeBase64 {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

#pragma mark - String Validate

- (BOOL)regularWithPattern:(NSString *)pattern {
    if (!pattern && ![pattern validateNotNull]) {
        return NO;
    }
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSMatchingOptions options = NSMatchingAnchored | NSMatchingReportProgress | NSMatchingReportCompletion;
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:options
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//验证是否不是空得
- (BOOL)validateNotNull {
    
    if (![self isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

- (BOOL)validateNumber {
    
    return [self regularWithPattern:@"^[0-9]+$"];
}

- (BOOL)validateFloatNumber {
    
    return [self regularWithPattern:@"^([-+]?([1-9]\\d*\\.\\d*))|([-+]?0\\.\\d*[1-9]\\d*)$"];
}

- (BOOL)validateEmail {

    return [self regularWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"];
}

- (BOOL)validateLandline {
 
    return [self regularWithPattern:@"^(0[1-9]{2})-\\d{8,10}$|^(0[1-9]{3}-(\\d{7,10}))$|^(0[1-9]{2})\\d{8,10}$|^(0[1-9]{3}(\\d{7,10}))$"];
}

//手机号码验证
- (BOOL)validateMobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
  
    return [self regularWithPattern:@"^((13[0-9])|(14[57])|(15[^4\\D])|(17[0678])|(18[0-9]))\\d{8}$"];
}

//车牌号验证
- (BOOL)validateCarNo {
 
    return [self regularWithPattern:@"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$"];
}

//车型
- (BOOL)validateCarType {
 
    return [self regularWithPattern:@"^[\u4E00-\u9FFF]+$"];
}

//用户名
- (BOOL)validateUserName {
   
    return [self regularWithPattern:@"^[A-Za-z0-9]{6,20}+$"];
}

//是否是汉字
- (BOOL)validateCharacters {
   
    return [self regularWithPattern:@"[\u4e00-\u9fa5]+"];
}

//匹配双字节字符（包括汉字）
- (BOOL)validateDoubleByte {
    return [self regularWithPattern:@"[^\\x00-\\xff]+"];
}

- (BOOL)validateURLString {

    return [self regularWithPattern:@"([a-zA-z]+://[^\\s]*)?"];
}

//身份证号
- (BOOL)validateIdentityCard {
    if (self.length <= 0) {
        return NO;
    }
 
    return [self regularWithPattern:@"^(\\d{14}|\\d{17})(\\d|[xX])$"];
}

#pragma mark - String Drawing

- (UIImage *)drawImageWithSize:(CGSize)size andFont:(UIFont *)font andColor:(UIColor *)color {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self drawInRect:(CGRect){.size = size, .origin = CGPointZero} withAttributes:@{NSFontAttributeName: font,NSForegroundColorAttributeName: color}];
#else
    [color set];
    [self drawInRect:(CGRect){.size = size, .origin = CGPointZero} withFont:font];
#endif
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - 字符串size计算

- (CGSize)computeSizeWithFont:(UIFont *)font {
    
    if (![self isKindOfClass:[NSString class]] || !font) {
        return CGSizeZero;
    }
    
    CGSize size = [self sizeWithFont:font];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_AND_LATER) {
        size = [self sizeWithAttributes:@{ NSFontAttributeName: font }];
    }
#endif
    return size;
}

- (CGFloat)computeWidthWithFont:(UIFont *) font height:(CGFloat) height {
    
    if (![self isKindOfClass:[NSString class]] || !font) {
        return 0.0;
    }
    
    CGSize size = [self sizeWithFont:font
                   constrainedToSize:CGSizeMake(MAXFLOAT, height)
                       lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat newHeight = size.height;
    CGFloat width = size.width;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_AND_LATER) {
        CGRect frame = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{ NSFontAttributeName: font }
                                          context:nil];
        
        newHeight = CGRectGetHeight(frame);
        width = CGRectGetWidth(frame);
    }
#endif
    if (height > newHeight) {
        
        NSInteger row = floor(height / newHeight);
        
        width = ceil(width / row) + 5.0;
    }
    
    return width;
}

- (CGFloat)computeHeightWithFont:(UIFont *) font width:(CGFloat) width {
    
    if (![self isKindOfClass:[NSString class]] || !font) {
        return 0.0;
    }
    
    CGFloat height = [self sizeWithFont:font
                      constrainedToSize:CGSizeMake(width, MAXFLOAT)
                          lineBreakMode:NSLineBreakByCharWrapping].height;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (IOS7_AND_LATER) {
        height = CGRectGetHeight([self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{ NSFontAttributeName: font }
                                                    context:nil]);
    }
#endif
    return height;
}

//引至ASIHTTPRequst #import <MobileCoreServices/MobileCoreServices.h>
- (NSString*)fileMIMEType:(NSString*) file {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file]) {
		return nil;
	}
    
	// Borrowed from http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[file pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
		return @"application/octet-stream";
	}
    return (__bridge NSString *)MIMEType;
}

#pragma mark - NSString To UIImage

- (UIImage *)stringConvertedImage {
    NSData *data = [GTMBase64 decodeString:self];
    return [UIImage imageWithData:data];
}

@end
