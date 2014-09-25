//
//  NSString+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSString+ACAdditions.h"

#import <CommonCrypto/CommonDigest.h>
#import "GTMBase64.h"

@implementation NSString (ACAdditions)

#pragma mark - md5

- (NSString *)md5 {
    const char *str = [self UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    NSMutableString *md5Ciphertext = [NSMutableString stringWithString:@""];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Ciphertext appendFormat:@"%02x",r[i]];
    }
    return [md5Ciphertext copy];
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
    NSString *numberRegex = @"^[0-9]+$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:numberRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

- (BOOL)validateFloatNumber {
    
    NSString *numberRegex = @"^0\\.[0-9]{0,1}$|^[0-9]+$|^[1-9][0-9]*\\.[0-9]{0,1}$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:numberRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

- (BOOL)validateEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:emailRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

- (BOOL)validateLandline {
    NSString *phoneRegex = @"^(0[1-9]{2})-\\d{8,10}$|^(0[1-9]{3}-(\\d{7,10}))$|^(0[1-9]{2})\\d{8,10}$|^(0[1-9]{3}(\\d{7,10}))$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//手机号码验证
- (BOOL)validateMobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:phoneRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//车牌号验证
- (BOOL)validateCarNo {
    NSString *carRegex = @"^[\\u4e00-\\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\\u4e00-\\u9fa5]$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:carRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//车型
- (BOOL)validateCarType {
    NSString *carTypeRegex = @"^[\\u4E00-\\u9FFF]+$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:carTypeRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//用户名
- (BOOL)validateUserName {
    NSString *userNameRegex = @"^[A-Za-z0-9]{6,20}+$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:userNameRegex
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
}

//身份证号
- (BOOL)validateIdentityCard {
    if (self.length <= 0) {
        return NO;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regex2
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSInteger number = [regex numberOfMatchesInString:self
                                              options:NSMatchingAnchored
                                                range:NSMakeRange(0, self.length)];
    return (number == 1);
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

#pragma mark - JSON
- (id)JSON {
    return [self JSON:nil];
}

- (id)JSON:(NSError *__autoreleasing *)error {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
    return result;
}

@end
