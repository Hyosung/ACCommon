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

@interface NSString (Private)

- (BOOL)regularWithPattern:(NSString *) pattern;

@end

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

- (NSString *)MD5 {
    const char *str = [self UTF8String];
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    
    NSMutableString *md5Ciphertext = [NSMutableString stringWithString:@""];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Ciphertext appendFormat:@"%02X",r[i]];
    }
    return [md5Ciphertext copy];
}

#pragma mark - Base64

- (NSString*)encodeBase64 {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 encodeData:data];
    NSString *__autoreleasing base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

- (NSString*)decodeBase64 {
    
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    data = [GTMBase64 decodeData:data];
    NSString *__autoreleasing base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return base64String;
}

#pragma mark - String Validate

- (BOOL)regularWithPattern:(NSString *)pattern {
    if (!pattern ||
        ![pattern isKindOfClass:[NSString class]] ||
        [[pattern stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
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

- (BOOL)validateCMNumber {
    /**
     * 中国移动 China Mobile：
     * 134（不含1349）、135、136、137、138、139、147、150、151、
     * 152、157、158、159、182、183、184、187、188、1705(移动)、178(移动)
     **/
    return [self regularWithPattern:@"^1(((3[5-9]|47|5[012789]|8[23478]|78)[0-9])|34[0-8]|705)\\d{7}$"];
}

- (BOOL)validateCUNumber {
    
   /**
    * 中国联通 China Unicom：
    * 130、131、132、145（上网卡）、155、156、185、186、1709(联通)]、176(联通)
    **/
    return [self regularWithPattern:@"^1(((3[012]|45|5[56]|8[56]|76)[0-9])|709)\\d{7}$"];
}

- (BOOL)validateCTNumber {
    /** 
     * 中国电信 China Telecom：
     * 133、1349（卫星通信）、153、180、181、189、1700(电信)、177(电信)
     **/
    return [self regularWithPattern:@"^1(((33|53|8[019]|77)[0-9])|349|700)\\d{7}$"];
}

//手机号码验证
- (BOOL)validateMobile {
    /**
     * 中国移动 China Mobile：
     * 134（不含1349）、135、136、137、138、139、147、150、151、152、157、158、159、182、183、184、187、188
     *
     * 中国联通 China Unicom：
     * 130、131、132、145（上网卡）、155、156、185、186
     *
     * 中国电信 China Telecom：
     * 133、1349（卫星通信）、153、180、181、189
     *
     * 4G号段：170：[1700(电信)、1705(移动)、1709(联通)]、176(联通)、177(电信)、178(移动)
     * 未知号段：140、141、142、143、144、146、148、149、154
     **/
    return [self regularWithPattern:@"^1((([38][0-9])|(4[57])|(5[^4\\D])|(7[678]))[0-9]|(70[059]))\\d{7}$"];
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

- (UIImage *)drawImageWithSize:(CGSize)size font:(UIFont *)font color:(UIColor *)color {
    
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self drawInRect:(CGRect){.size = size, .origin = CGPointZero}
      withAttributes:@{NSFontAttributeName: font,NSForegroundColorAttributeName: color}];
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
    
    if (!font) {
        return CGSizeZero;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    CGSize size = [self sizeWithAttributes:@{ NSFontAttributeName: font }];
#else
    
    CGSize size = [self sizeWithFont:font];
#endif
    return size;
}

- (CGFloat)computeWidthWithFont:(UIFont *) font height:(CGFloat) height {
    
    if (!font) {
        return 0.0;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    CGRect frame = [self boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
                                      options:NSStringDrawingUsesLineFragmentOrigin
                                   attributes:@{ NSFontAttributeName: font }
                                      context:nil];
    
    CGFloat newHeight = CGRectGetHeight(frame);
    CGFloat width = CGRectGetWidth(frame);
#else
    CGSize size = [self sizeWithFont:font
                   constrainedToSize:CGSizeMake(MAXFLOAT, height)
                       lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat newHeight = size.height;
    CGFloat width = size.width;
#endif
    if (height > newHeight) {
        
        NSInteger row = floor(height / newHeight);
        
        width = ceil(width / row) + 5.0;
    }
    
    return width;
}

- (CGFloat)computeHeightWithFont:(UIFont *) font width:(CGFloat) width {
    
    if (!font) {
        return 0.0;
    }

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
   CGFloat height = CGRectGetHeight([self boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{ NSFontAttributeName: font }
                                                       context:nil]);
#else
    CGFloat height = [self sizeWithFont:font
                      constrainedToSize:CGSizeMake(width, MAXFLOAT)
                          lineBreakMode:NSLineBreakByCharWrapping].height;
#endif
    return height;
}

//引至ASIHTTPRequst #import <MobileCoreServices/MobileCoreServices.h>
- (NSString*)fileMIMEType {
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:self]) {
		return nil;
	}
    
	// Borrowed from http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[self pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType) {
		return @"application/octet-stream";
	}
    return CFBridgingRelease(MIMEType);
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

#pragma mark - NSString To UIImage

- (UIImage *)stringConvertedImage {
    NSData *data = [GTMBase64 decodeString:self];
    return [UIImage imageWithData:data];
}

#pragma mark - 汉字 To PinYin
- (NSString *)transformToPinyin {
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    //转换为带声调的拼音
    CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    //去掉声调
    //CFStringTransform((__bridge CFMutableStringRef)mutableString, NULL, kCFStringTransformStripDiacritics, false);
    NSString *transformText = [mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    return transformText;
}

- (NSString *)removeHTML {
    
    NSScanner *theScanner;
    
    NSString *text = nil;
    NSString *html = self;
    theScanner = [NSScanner scannerWithString:self];
    while ([theScanner isAtEnd] == NO) {
        
        // find start of tag
        [theScanner scanUpToString:@"<" intoString:NULL];
        // find end of tag
        [theScanner scanUpToString:@">" intoString:&text];
        
        // replace the found tag with a space
        
        //(you can filter multi-spaces out later if you wish)
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    
    return html;
}

- (BOOL)isEmpty {
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isEmpty:(NSString *)string {
    if (!string || ![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    return [string isEmpty];
}

//半角中空格的ascii码为32（其余ascii码为33-126），全角中空格的ascii码为12288（其余ascii码为65281-65374）
//半角与全角之差为65248
//半角转全角
- (NSString *)transformToFullWidth {
    NSString *fullWidth = @"";
    for (int i = 0; i < self.length; i++) {
        unichar temp = [self characterAtIndex:i];
        if (temp >= 33 && temp <= 126) {
            temp = temp + 65248;
            fullWidth = [NSString stringWithFormat:@"%@%C", fullWidth, temp];
        }
        else {
            if (temp == 32) {
                temp = 12288;
            }
            fullWidth = [NSString stringWithFormat:@"%@%C", fullWidth, temp];
        }
    }
    return fullWidth;
}

//全角转半角
- (NSString *)transformToHalfSize {
    NSString *halfSize = @"";
    for (int i = 0; i < self.length; i++) {
        unichar temp = [self characterAtIndex:i];
        if (temp >= 65281 && temp <= 65374) {
            temp = temp - 65248;
            halfSize = [NSString stringWithFormat:@"%@%C", halfSize, temp];
        }
        else {
            if (temp == 12288) {
                temp = 32;
            }
            halfSize = [NSString stringWithFormat:@"%@%C", halfSize, temp];
        }
    }
    
    return halfSize;
}

@end
