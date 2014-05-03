//
//  ACUtils.m
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "ACUtils.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@interface ACUtils() {
#if defined(__USE_Reachability__) && __USE_Reachability__
    Reachability *hostReach;
    NetworkStatus curStatus;
#endif
}

#if defined(__USE_Reachability__) && __USE_Reachability__
- (void)reachabilityChanged:(NSNotification *)note;
#endif

+ (CGFloat)reckonWithSize:(CGSize) size
                 isHeight:(BOOL) flag
                   number:(CGFloat) number;
@end

@implementation ACUtils

#if defined(ACIMP_SINGLETON)
ACIMP_SINGLETON(ACUtils)
#endif

- (void)dealloc {
#if defined(__USE_Reachability__) && __USE_Reachability__
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [hostReach stopNotifier];
#endif
}

inline NSString * UUID() {
    
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDStr = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    NSString *uuidStr = (__bridge NSString *)(UUIDStr);
    CFRelease(UUID);
    CFRelease(UUIDStr);
    return uuidStr;
}

+ (UIImage *)imageNamed:(NSString *) name orType:(NSString *) ext {
    UIImage *image1x = nil;
    UIImage *image2x = nil;
    
    if (ext && ![ext isEqualToString:@""]) {
        image1x = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
        image2x = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@2x",name] ofType:ext]];
    } else {
        image1x = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
        NSRange range = [name rangeOfString:@"." options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            name = [name stringByReplacingCharactersInRange:range withString:@"@2x."];
        } else {
            name = [NSString stringWithFormat:@"%@@2x",name];
        }
        image2x = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:ext]];
    }
    
    if (isRetina && image2x) {
        return image2x;
    }
    
    if (!image1x) {
        return image2x;
    }
    
    return image1x;
}

+ (UIImage *)imageNamed:(NSString *) name {
    return [ACUtils imageNamed:name orType:@"png"];
}

+ (UIImage *)imageNamedExtJpg:(NSString *)name {
    return [ACUtils imageNamed:name orType:@"jpg"];
}

+ (UIImage *)imageCacheNamed:(NSString *)name {
    return [UIImage imageNamed:name];
}

/*
+ (UIImage *)getImageFromView:(UIView *)orgView {
    UIGraphicsBeginImageContextWithOptions(orgView.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}*/

+ (UIImage *)imageSynthesisWithImages:(NSArray *)images andSize:(CGSize)size {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImage *curImage = obj[@"image"];
        CGRect curRect = CGRectFromString(obj[@"rect"]);
        if (curImage) {
            [curImage drawInRect:curRect];
        }
    }];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/*+ (void)savePhotosAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
}*/

/*+ (void)saveImageFromToPhotosAlbum:(UIView*)view {
    UIImage *image = [view snapshot];
    [image savePhotosAlbum];
}*/

/*+ (void)imageSavedToPhotosAlbum:(UIImage *)image
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
}*/

+ (NSString *)getTimeDiffString:(NSTimeInterval) timestamp {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *todate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *today = [NSDate date];//当前时间
    unsigned int unitFlag = NSDayCalendarUnit | NSHourCalendarUnit |NSMinuteCalendarUnit;
    NSDateComponents *gap = [cal components:unitFlag fromDate:today toDate:todate options:0];//计算时间差
    
    if (ABS([gap day]) > 0)
    {
        return [NSString stringWithFormat:@"%ld天前", ABS((long)([gap day]))];
    }else if(ABS([gap hour]) > 0)
    {
        return [NSString stringWithFormat:@"%ld小时前", ABS((long)([gap hour]))];
    }else
    {
        return [NSString stringWithFormat:@"%ld分钟前",  ABS((long)([gap minute]))];
    }
}

+ (UIImage *)cutImageWithFrame:(CGRect)frame image:(UIImage *)image {
    
    CGFloat height = [ACUtils reckonWithSize:image.size width:CGRectGetWidth(frame)];
    if (image.size.width < CGRectGetWidth(frame)) {
        frame.size.width = image.size.width;
        if (image.size.height < CGRectGetHeight(frame)) {
            frame.size.height = image.size.height;
        }
    } else {
        UIImage *newImage1 = [ACUtils zoomImageWithSize:CGSizeMake(CGRectGetWidth(frame), height) image:image];
        if (newImage1.size.height < CGRectGetHeight(frame)) {
            frame.size.height = newImage1.size.height;
        }
    }
    CGImageRef cutImageRef = CGImageCreateWithImageInRect(image.CGImage, frame);
    UIImage *cutImage = [UIImage imageWithCGImage:cutImageRef];
    CGImageRelease(cutImageRef);
    return cutImage;
}

+ (UIImage *)zoomImageWithSize:(CGSize)size image:(UIImage *)image {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(size,NO,[UIScreen mainScreen].scale);
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextDrawImage(
                       UIGraphicsGetCurrentContext(),
                       CGRectMake(0, 0, size.width, size.height),
                       [image CGImage]);
    newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image
                          isHeight:(BOOL)flag
                            number:(CGFloat)number {
    CGSize size;
    if (flag) {
        size = CGSizeMake([ACUtils reckonWithSize:image.size height:number], number);
    }else{
        size = CGSizeMake(number, [ACUtils reckonWithSize:image.size width:number]);
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image size:(CGSize)size {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGFloat newWidth = (image.size.width > size.width) ? size.width : image.size.width;
    CGFloat newHeight = [ACUtils reckonWithSize:image.size width:newWidth];
    newHeight = (newHeight > size.height) ? size.height : newHeight;
    [image drawInRect:CGRectMake(
                                 size.width / 2 - newWidth / 2,
                                 size.height / 2 - newHeight / 2,
                                 newWidth,
                                 newHeight)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image orHeight:(CGFloat)height {
    return [ACUtils resizedImageWithImage:image isHeight:YES number:height];
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image orWidth:(CGFloat)width {
    return [ACUtils resizedImageWithImage:image isHeight:NO number:width];
}

+ (CGFloat)reckonWithSize:(CGSize) size
                 isHeight:(BOOL) flag
                   number:(CGFloat) number {
    CGFloat newNumber = 0.0f;
    CGFloat scale = size.height / size.width;
    if (!flag) {
        newNumber = scale * number;
    }else{
        newNumber = number / scale;
    }
    return newNumber;
}

+ (CGFloat)reckonWithSize:(CGSize) size height:(CGFloat) height {
    return [ACUtils reckonWithSize:size isHeight:YES number:height];
}

+ (CGFloat)reckonWithSize:(CGSize) size width:(CGFloat) width {
    return [ACUtils reckonWithSize:size isHeight:NO number:width];
}

+ (UIImage *)drawMask:(UIColor *)maskColor
      foregroundColor:(UIColor *)foregroundColor
      imageNamedOrExt:(NSString *)nameOrExt {
    return [ACUtils drawMask:maskColor
            foregroundColor:foregroundColor
                      image:[ACUtils imageNamed:nameOrExt orType:nil]];
}

+ (UIImage *)drawMask:(UIColor *)maskColor
      foregroundColor:(UIColor *)foregroundColor
                image:(UIImage *)originImage {
    CGRect imageRect = CGRectMake(
                                  0,
                                  0,
                                  CGImageGetWidth(originImage.CGImage),
                                  CGImageGetHeight(originImage.CGImage)
                                  );
    
    // 创建位图上下文
    
    CGContextRef context = CGBitmapContextCreate(NULL, // 内存图片数据
                                                 
                                                 imageRect.size.width, // 宽
                                                 
                                                 imageRect.size.height, // 高
                                                 
                                                 8, // 色深
                                                 
                                                 0, // 每行字节数
                                                 
                                                 CGImageGetColorSpace(originImage.CGImage), // 颜色空间
                                                 
                                                 CGImageGetBitmapInfo(originImage.CGImage)/*kCGImageAlphaPremultipliedLast*/);// alpha通道，RBGA
    
    // 设置当前上下文填充色为白色（RGBA值）
    CGContextSetRGBFillColor(
                             context,
                             CGColorGetComponents([foregroundColor CGColor])[0],
                             CGColorGetComponents([foregroundColor CGColor])[1],
                             CGColorGetComponents([foregroundColor CGColor])[2],
                             CGColorGetAlpha([foregroundColor CGColor])
                             );
    
    CGContextFillRect(context,imageRect);
    
    // 用 originImage 作为 clipping mask（选区）
    
    CGContextClipToMask(context,imageRect, originImage.CGImage);
    
    // 设置当前填充色为黑色
    CGContextSetRGBFillColor(
                             context,
                             CGColorGetComponents([maskColor CGColor])[0],
                             CGColorGetComponents([maskColor CGColor])[1],
                             CGColorGetComponents([maskColor CGColor])[2],
                             CGColorGetAlpha([maskColor CGColor])
                             );
    
    // 在clipping mask上填充黑色
    
    CGContextFillRect(context,imageRect);
    
    CGImageRef newCGImage = CGBitmapContextCreateImage(context);
    UIImage* newImage = [UIImage imageWithCGImage:newCGImage
                                            scale:originImage.scale
                                      orientation:originImage.imageOrientation];
    
    // Cleanup
    
    CGContextRelease(context);
    
    CGImageRelease(newCGImage);
    
    //    [UIImagePNGRepresentation(newImage) writeToFile:[XW_Document stringByAppendingPathComponent:[NSString stringWithFormat:@"__%@",nameOrExt]] atomically:YES];
    
    return newImage;
}

+ (UIImage *)drawPlaceholderWithSize:(CGSize)size {
    return [ACUtils drawPlaceholderWithSize:size bgcolor:PLACEHOLDER_COLOR];
}

+ (UIImage *)drawPlaceholderWithSize:(CGSize)size bgcolor:(UIColor *)color {
    UIImage *oldImage = [UIImage imageNamed:PLACEHOLDER_NAME];
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(contextRef, CGRectMake(0, 0, size.width, size.height));
    
    CGSize newSize;
    if (size.height > oldImage.size.height) {
        newSize = CGSizeMake(oldImage.size.height - 20, oldImage.size.height - 20);
    } else {
        newSize = CGSizeMake(size.height - 20, size.height - 20);
    }
    
    if (newSize.width >= size.width) {
        newSize = CGSizeMake(size.width - 20, size.width - 20);
    }
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextDrawImage(contextRef,CGRectMake(
                                             size.width / 2 - newSize.width / 2,
                                             size.height / 2 - newSize.height / 2,
                                             newSize.width,
                                             newSize.height
                                             ), [oldImage CGImage]);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)drawingColor:(UIColor *)color {
    return [ACUtils drawingColor:color size:CGSizeMake(57, 57)];
}

+ (UIImage *)drawingColor:(UIColor *)color size:(CGSize)size {
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, size.width, size.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 * 绘制背景色渐变的矩形，p_colors渐变颜色设置，集合中存储UIColor对象（创建Color时一定用三原色来创建）
 **/
+ (UIImage *)drawGradientColor:(CGRect)p_clipRect
                       options:(CGGradientDrawingOptions)p_options
                        colors:(NSArray *)p_colors {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(p_clipRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef p_context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(p_context);// 保持住现在的context
    CGContextClipToRect(p_context, p_clipRect);// 截取对应的context
    NSUInteger colorCount = p_colors.count;
    int numOfComponents = 4;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[colorCount * numOfComponents];
    for (int i = 0; i < colorCount; i++) {
        UIColor *color = p_colors[i];
        CGColorRef temcolorRef = color.CGColor;
        const CGFloat *components = CGColorGetComponents(temcolorRef);
        for (int j = 0; j < numOfComponents; ++j) {
            colorComponents[i * numOfComponents + j] = components[j];
        }
    }
    CGGradientRef gradient =  CGGradientCreateWithColorComponents(rgb, colorComponents, NULL, colorCount);
    CGColorSpaceRelease(rgb);
    CGPoint startPoint = p_clipRect.origin;
    CGPoint endPoint = CGPointMake(CGRectGetMinX(p_clipRect), CGRectGetMaxY(p_clipRect));
    CGContextDrawLinearGradient(p_context, gradient, startPoint, endPoint, p_options);
    CGGradientRelease(gradient);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(p_context);// 恢复到之前的context
    UIGraphicsEndImageContext();
    
    //    [UIImagePNGRepresentation(newImage) writeToFile:[XW_Document stringByAppendingPathComponent:@"xw.png"] atomically:YES];
    return newImage;
}

/*
+ (CGSize)computeSizeWithString:(NSString *)aStr font:(UIFont *)font {
    
    if (!aStr || ![aStr isKindOfClass:[NSString class]] || !font) {
        return CGSizeZero;
    }
    
    CGSize size = [aStr sizeWithFont:font];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_AND_LATER) {
        size = [aStr sizeWithAttributes:@{ NSFontAttributeName: font }];
    }
#endif
    return size;
}

+ (CGFloat)computeWidthWithString:(NSString *) aStr font:(UIFont *) font height:(CGFloat) height {
    
    if (!aStr || ![aStr isKindOfClass:[NSString class]] || !font) {
        return 0.0;
    }
    
    CGSize size = [aStr sizeWithFont:font
                   constrainedToSize:CGSizeMake(MAXFLOAT, height)
                       lineBreakMode:NSLineBreakByCharWrapping];
    CGFloat newHeight = size.height;
    CGFloat width = size.width;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_AND_LATER) {
        CGRect frame = [aStr boundingRectWithSize:CGSizeMake(MAXFLOAT, height)
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

+ (CGFloat)computeHeightWithString:(NSString *) aStr font:(UIFont *) font width:(CGFloat) width {
    
    if (!aStr || ![aStr isKindOfClass:[NSString class]] || !font) {
        return 0.0;
    }
    
    CGFloat height = [aStr sizeWithFont:font
                      constrainedToSize:CGSizeMake(width, MAXFLOAT)
                          lineBreakMode:NSLineBreakByCharWrapping].height;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (IOS7_AND_LATER) {
        height = CGRectGetHeight([aStr boundingRectWithSize:CGSizeMake(width, MAXFLOAT)
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{ NSFontAttributeName: font }
                                                    context:nil]);
    }
#endif
    return height;
}*/
 

/*
//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:emailRegex
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    
    NSInteger numer = [regular numberOfMatchesInString:email
                                               options:NSMatchingAnchored
                                                 range:NSMakeRange(0, email.length)];
    
    return numer==1;
}*/

+ (BOOL)isOutNumber:(NSInteger)number
            objcect:(id)obj
             string:(NSString *)string
              range:(NSRange)range {
    //string就是此时输入的那个字符textField就是此时正在输入的那个输入框返回YES就是可以改变输入框的值NO相反
    
    if ([string isEqualToString:@"\n"]) { //按会车可以改变
        return YES;
    }
    id textField=nil;
    if ([obj isKindOfClass:[UITextField class]]) {
        textField = obj;
    } else if ([obj isKindOfClass:[UITextView class]]) {
        textField = obj;
    } else {
        NSAssert(textField, @"obj instead of UITextField nor UITextView");
    }
    
    NSString * toBeString = [[textField text] stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    //  if (self.myTextField == textField)  //判断是否时我们想要限定的那个输入框
    //  {
    if ([toBeString length] > number) { //如果输入框内容大于number则弹出警告
        [textField setText:[toBeString substringToIndex:number]];
        return NO;
    }
    //  }
    return YES;
}

+ (NSString *)formattedFileSize:(unsigned long long)size {
    NSString *formattedStr = nil;
    if (size == 0) {
        formattedStr = @"Empty";
    } else {
        if (size > 0 && size < 1024) {
            formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        } else {
            if (size >= 1024 && size < pow(1024, 2)) {
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            } else {
                if (size >= pow(1024, 2) && size < pow(1024, 3)) {
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                } else {
                    if (size >= pow(1024, 3)) {
                        formattedStr = [NSString stringWithFormat:@"%.3f GB", (size / pow(1024, 3))];
                    }
                }
            }
        }
    }
    return formattedStr;
}

+ (void)automaticCheckVersion:(void (^)(NSDictionary *))block url:(NSString *) url {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //CFShow((__bridge CFTypeRef)(infoDic));
    
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    NSString *URL = url;
    __autoreleasing NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(
                                               NSURLResponse *response,
                                               NSData *data,
                                               NSError *error
                                               ) {
                               
                               NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:NSJSONReadingAllowFragments
                                                                                     error:nil];
                               NSArray *infoArray = dic[@"results"];
                               if ([infoArray count]) {
                                   NSDictionary *releaseInfo = infoArray[0];
                                   NSString *lastVersion = releaseInfo[@"version"];
                                   
                                   if (![lastVersion isEqualToString:currentVersion]) {
                                       NSString *trackViewURL = releaseInfo[@"trackViewUrl"];
                                       NSString *releaseNotes = releaseInfo[@"releaseNotes"];
                                       
                                       if (block) {
                                           
                                           block(@{
                                                   @"trackViewUrl": trackViewURL,
                                                   @"version": lastVersion,
                                                   @"releaseNotes": releaseNotes
                                                   });
                                       }
                                   }
                               }
                           }];
}

+ (void)onCheckVersion:(NSString *) url {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //CFShow((__bridge CFTypeRef)(infoDic));
    
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    NSString *URL = url;
    __autoreleasing NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    if (recervedData) {
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:recervedData
                                                            options:NSJSONReadingAllowFragments
                                                              error:nil];
        NSArray *infoArray = dic[@"results"];
        if ([infoArray count]) {
            NSDictionary *releaseInfo = infoArray[0];
            NSString *lastVersion = releaseInfo[@"version"];
            
            if (![lastVersion isEqualToString:currentVersion]) {
                NSString *trackViewURL = releaseInfo[@"trackViewUrl"];
                NSString *releaseNotes = releaseInfo[@"releaseNotes"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAppUpdate"
                                                                    object:self
                                                                  userInfo:@{
                                                                             @"trackViewUrl": trackViewURL,
                                                                             @"version": lastVersion,
                                                                             @"releaseNotes": releaseNotes
                                                                             }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                                    message:@"当前版本已是最新版本"
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"确定"
                                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
        } else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                                message:@"当前软件还未上线"
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"确定"
                                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                            message:@"网络连接失败"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
            [alert show];
        });
    }
}

+ (void)applicationRatings:(NSString *) url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (NSString *)appStoreUrl:(NSString *) appid {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *displayName = info[@"CFBundleDisplayName"];
    //    NSString *displayName = [info objectForKey:@"CFBundleName"];
    //https://itunes.apple.com/us/app/bu-yi-li-ji/id647152789?mt=8&uo=4
    NSMutableArray *spliceArray = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i<displayName.length; i++) {
        NSString *spliceText = [NSString stringWithFormat:@"%C",[displayName characterAtIndex:i]];
        [spliceArray addObject:[ChineseToPinyin pinyinFromChiniseString:spliceText]];
    }
    
    NSString *appStoreURL = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/%@/id%@?mt=8",[spliceArray componentsJoinedByString:@"-"],appid];
    return [appStoreURL lowercaseString];
}

+ (void)setNavigationBar:(UINavigationBar *)navBar
         backgroundImage:(UIImage *)image {
    
    // Insert ImageView
    __autoreleasing UIImageView *_imgv = [[UIImageView alloc] initWithImage:image];
    _imgv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _imgv.frame = navBar.bounds;
    UIView *v = [navBar subviews][0];
    v.layer.zPosition = -FLT_MAX;
    
    _imgv.layer.zPosition = -FLT_MAX + 1;
    [navBar insertSubview:_imgv atIndex:1];
}

+ (void)setNavigationBar:(UINavigationBar *)navBar
             contentView:(UIView *)view {
    // Insert View
    view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.frame = navBar.bounds;
    UIView *v = [navBar subviews][0];
    v.layer.zPosition = -FLT_MAX;
    
    view.layer.zPosition = -FLT_MAX + 1;
    [navBar insertSubview:view atIndex:1];
}

+ (void)showNoContent:(BOOL) flag
          displayView:(UIView *) view
       displayContent:(NSString *) content {
    if (flag) {
        __block UILabel *label = nil;
        if (![view viewWithTag:1024]) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT / 4)];
            label.tag = 1024;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:17.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.center = view.center;
            
            [view addSubview:label];
        } else {
            label = (UILabel *)[view viewWithTag:1024];
        }
        label.alpha = 0;
        label.text = content;
        
        [UIView animateWithDuration:0.3 animations:^{
            label.alpha = 1;
        }];
    } else {
        if ([view viewWithTag:1024]) {
            UILabel *label = (UILabel *)[view viewWithTag:1024];
            [UIView animateWithDuration:0.3 animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }
    }
}

//半角中空格的ascii码为32（其余ascii码为33-126），全角中空格的ascii码为12288（其余ascii码为65281-65374）
//半角与全角之差为65248
//半角转全角
+ (NSString *)DBCToSBC:(NSString *)dbc {
    NSString *sbc = @"";
    for (int i=0; i<dbc.length; i++) {
        unichar temp = [dbc characterAtIndex:i];
        if (temp >= 33 && temp <= 126) {
            temp = temp + 65248;
            sbc = [NSString stringWithFormat:@"%@%C",sbc,temp];
        }else{
            if (temp == 32) {
                temp = 12288;
            }
            sbc = [NSString stringWithFormat:@"%@%C",sbc,temp];
        }
    }
    return sbc;
}

//全角转半角
+ (NSString *)SBCToDBC:(NSString *)sbc {
    NSString *dbc = @"";
    
    for (int i=0; i<sbc.length; i++) {
        unichar temp = [sbc characterAtIndex:i];
        if (temp >= 65281 && temp <= 65374) {
            temp = temp - 65248;
            dbc = [NSString stringWithFormat:@"%@%C",dbc,temp];
        }else{
            if (temp == 12288) {
                temp = 32;
            }
            dbc = [NSString stringWithFormat:@"%@%C",dbc,temp];
        }
    }
    
    return dbc;
}

+ (NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to {
    return (NSInteger)(from + (arc4random() % (to - from + 1)));
}

+ (NSInteger)getRandomNumberTo:(NSInteger)to{
    return [ACUtils getRandomNumber:0 to:to];
}

+ (double)getFloatRandomNumber:(double)from to:(double)to {
    double randomNumber = from + ((double)arc4random() / ARC4RANDOM_MAX) * to;
    return [[NSString stringWithFormat:@"%0.1f",randomNumber] doubleValue];
}

#if defined(__USE_ASIHttpRequest__) && __USE_ASIHttpRequest__

static char * const kACASIRequestSucceedKey      = "kACASIRequestSucceedKey";
static char * const kACASIRequestFailedKey       = "kACASIRequestFailedKey";
static char * const kACASINetworkQueueSucceedKey = "kACASINetworkQueueSucceedKey";

+ (ASIFormDataRequest *)startAsynchronousRequestWithURLString:(NSString *)theUrl
                                                    parameter:(NSDictionary *)param
                                                      succeed:(void (^)(ASIFormDataRequest *))blockSucceed
                                                       failed:(void (^)(ASIFormDataRequest *, NSError *))blockFailed {
    
    __weak ASIFormDataRequest *request = [ACUtils createAsynchronousRequestWithURLString:theUrl
                                                                              parameter:param];
    
    [request setCompletionBlock:^{
        if (blockSucceed) {
            blockSucceed(request);
        }
    }];
    
    [request setFailedBlock:^{
        NSError *error = request.error;
        if (blockFailed) {
            blockFailed(request,error);
        }
    }];
    
    [request startAsynchronous];
    
    return request;
}

+ (ASIFormDataRequest *)createAsynchronousRequestWithURLString:(NSString *) theUrl
                                                     parameter:(NSDictionary *) param {
    NSURL *tempURL = [NSURL URLWithString:theUrl];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:tempURL];
    if (param) {
        for (NSString *key in param.allKeys) {
            [request setPostValue:param[key] forKey:key];
        }
    }
    return request;
}

+ (ASINetworkQueue *)startNetworkQueueWithRequests:(NSArray *) requests
                                    requestSucceed:(void (^)(ASIHTTPRequest *request)) requestBlockSucceed
                                     requestFailed:(void (^)(ASIHTTPRequest *request, NSError *error)) requestBlockFailed
                                      queueSucceed:(void (^)(ASINetworkQueue *queue)) queueBlock {
    ASINetworkQueue *queue = [ASINetworkQueue queue];
    queue.delegate = self;
    queue.maxConcurrentOperationCount = 3;
    queue.shouldCancelAllRequestsOnFailure = NO;
    queue.requestDidFailSelector = @selector(requestDidFailSelector:);
    queue.requestDidFinishSelector = @selector(requestDidFinishSelector:);
    queue.queueDidFinishSelector = @selector(queueDidFinishSelector:);
    
    [requests enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[ASIHTTPRequest class]]) {
            [queue addOperation:obj];
        }
    }];
    
    objc_setAssociatedObject(self, kACASIRequestSucceedKey, requestBlockSucceed, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, kACASIRequestFailedKey, requestBlockFailed, OBJC_ASSOCIATION_COPY);
    objc_setAssociatedObject(self, kACASINetworkQueueSucceedKey, queueBlock, OBJC_ASSOCIATION_COPY);
    [queue go];
    
    return queue;
}

/*
 ASINetworkQueue 的delegate
 */

+ (void)requestDidFinishSelector:(ASIHTTPRequest *) request {
    void (^block)(ASIHTTPRequest *request) = objc_getAssociatedObject(self, kACASIRequestSucceedKey);
    if (block) {
        block(request);
    }
}

+ (void)requestDidFailSelector:(ASIHTTPRequest *) request {
    void (^block)(ASIHTTPRequest *request,NSError *error) = objc_getAssociatedObject(self, kACASIRequestFailedKey);
    if (block) {
        block(request,request.error);
    }
}

+ (void)queueDidFinishSelector:(ASINetworkQueue *) queue {
    void (^block)(ASINetworkQueue *queue) = objc_getAssociatedObject(self, kACASINetworkQueueSucceedKey);
    if (block) {
        block(queue);
    }
}

#endif

#if defined(__USE_Reachability__) && __USE_Reachability__
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (curStatus != status) {
        switch (status) {
            case ReachableViaWiFi:
            {
                [SVProgressHUD showSuccessWithStatus:@"当前网络WiFi"];
            }
                break;
            case ReachableViaWWAN:
            {
                [SVProgressHUD showSuccessWithStatus:@"当前网络3G/2G"];
            }
                break;
            case NotReachable:
            {
                [SVProgressHUD showErrorWithStatus:@"当前网络不通畅"];
            }
                break;
            default:
                break;
        }
    }
    curStatus = status;
}

- (void)setNetworkNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
    hostReach = [Reachability reachabilityWithHostName:@"http://www.baidu.com"];
    [hostReach startNotifier];
}

+ (BOOL)isNotNetwork {
    return (![ACUtils isEnable3G] && ![ACUtils isEnableWiFi]);
}

// 是否wifi
+ (BOOL)isEnableWiFi {
    return ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] != NotReachable);
}

// 是否3G
+ (BOOL)isEnable3G {
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}
#endif

#if defined(__USE_QuartzCore__) && __USE_QuartzCore__
/**********************************************常用动画************************************************/
/**
 *  首先推荐一个不错的网站.   http://www.raywenderlich.com
 */

#pragma mark - Custom Animation

+ (void)showAnimationType:(NSString *)type
              withSubType:(NSString *)subType
                 duration:(CFTimeInterval)duration
           timingFunction:(NSString *)timingFunction
                     view:(UIView *)theView
{
    /** CATransition
     *
     *  @see http://www.dreamingwish.com/dream-2012/the-concept-of-coreanimation-programming-guide.html
     *  @see http://geeklu.com/2012/09/animation-in-ios/
     *
     *  CATransition 常用设置及属性注解如下:
     */
    
    CATransition *animation = [CATransition animation];
    
    /** delegate
     *
     *  动画的代理,如果你想在动画开始和结束的时候做一些事,可以设置此属性,它会自动回调两个代理方法.
     *
     *  @see CAAnimationDelegate    (按下command键点击)
     */
    
    animation.delegate = self;
    
    /** duration
     *
     *  动画持续时间
     */
    
    animation.duration = duration;
    
    /** timingFunction
     *
     *  用于变化起点和终点之间的插值计算,形象点说它决定了动画运行的节奏,比如是均匀变化(相同时间变化量相同)还是
     *  先快后慢,先慢后快还是先慢再快再慢.
     *
     *  动画的开始与结束的快慢,有五个预置分别为(下同):
     *  kCAMediaTimingFunctionLinear            线性,即匀速
     *  kCAMediaTimingFunctionEaseIn            先慢后快
     *  kCAMediaTimingFunctionEaseOut           先快后慢
     *  kCAMediaTimingFunctionEaseInEaseOut     先慢后快再慢
     *  kCAMediaTimingFunctionDefault           实际效果是动画中间比较快.
     */
    
    /** timingFunction
     *
     *  当上面的预置不能满足你的需求的时候,你可以使用下面的两个方法来自定义你的timingFunction
     *  具体参见下面的URL
     *
     *  @see http://developer.apple.com/library/ios/#documentation/Cocoa/Reference/CAMediaTimingFunction_class/Introduction/Introduction.html
     *
     *  + (id)functionWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     *
     *  - (id)initWithControlPoints:(float)c1x :(float)c1y :(float)c2x :(float)c2y;
     */
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:timingFunction];
    
    /** fillMode
     *
     *  决定当前对象过了非active时间段的行为,比如动画开始之前,动画结束之后.
     *  预置为:
     *  kCAFillModeRemoved   默认,当动画开始前和动画结束后,动画对layer都没有影响,动画结束后,layer会恢复到之前的状态
     *  kCAFillModeForwards  当动画结束后,layer会一直保持着动画最后的状态
     *  kCAFillModeBackwards 和kCAFillModeForwards相对,具体参考上面的URL
     *  kCAFillModeBoth      kCAFillModeForwards和kCAFillModeBackwards在一起的效果
     */
    
    animation.fillMode = kCAFillModeForwards;
    
    /** removedOnCompletion
     *
     *  这个属性默认为YES.一般情况下,不需要设置这个属性.
     *
     *  但如果是CAAnimation动画,并且需要设置 fillMode 属性,那么需要将 removedOnCompletion 设置为NO,否则
     *  fillMode无效
     */
    
    //    animation.removedOnCompletion = NO;
    
    /** type
     *
     *  各种动画效果  其中除了'fade', `moveIn', `push' , `reveal' ,其他属于似有的API(我是这么认为的,可以点进去看下注释).
     *  ↑↑↑上面四个可以分别使用'kCATransitionFade', 'kCATransitionMoveIn', 'kCATransitionPush', 'kCATransitionReveal'来调用.
     *  @"cube"                     立方体翻滚效果
     *  @"moveIn"                   新视图移到旧视图上面
     *  @"reveal"                   显露效果(将旧视图移开,显示下面的新视图)
     *  @"fade"                     交叉淡化过渡(不支持过渡方向)             (默认为此效果)
     *  @"pageCurl"                 向上翻一页
     *  @"pageUnCurl"               向下翻一页
     *  @"suckEffect"               收缩效果，类似系统最小化窗口时的神奇效果(不支持过渡方向)
     *  @"rippleEffect"             滴水效果,(不支持过渡方向)
     *  @"oglFlip"                  上下左右翻转效果
     *  @"rotate"                   旋转效果
     *  @"push"
     *  @"cameraIrisHollowOpen"     相机镜头打开效果(不支持过渡方向)
     *  @"cameraIrisHollowClose"    相机镜头关上效果(不支持过渡方向)
     */
    
    /** type
     *
     *  kCATransitionFade            交叉淡化过渡
     *  kCATransitionMoveIn          新视图移到旧视图上面
     *  kCATransitionPush            新视图把旧视图推出去
     *  kCATransitionReveal          将旧视图移开,显示下面的新视图
     */
    
    animation.type = type;
    
    /** subtype
     *
     *  各种动画方向
     *
     *  kCATransitionFromRight;      同字面意思(下同)
     *  kCATransitionFromLeft;
     *  kCATransitionFromTop;
     *  kCATransitionFromBottom;
     */
    
    /** subtype
     *
     *  当type为@"rotate"(旋转)的时候,它也有几个对应的subtype,分别为:
     *  90cw    逆时针旋转90°
     *  90ccw   顺时针旋转90°
     *  180cw   逆时针旋转180°
     *  180ccw  顺时针旋转180°
     */
    
    /**
     *  type与subtype的对应关系(必看),如果对应错误,动画不会显现.
     *
     *  @see http://iphonedevwiki.net/index.php/CATransition
     */
    
    animation.subtype = subType;
    
    /**
     *  所有核心动画和特效都是基于CAAnimation,而CAAnimation是作用于CALayer的.所以把动画添加到layer上.
     *  forKey  可以是任意字符串.
     */
    
    [theView.layer addAnimation:animation forKey:nil];
}

#pragma mark - Preset Animation

+ (void)animationRevealFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromBottom];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromTop];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRevealFromRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionReveal];
    [animation setSubtype:kCATransitionFromRight];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}


+ (void)animationEaseIn:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationEaseOut:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setType:kCATransitionFade];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    [view.layer addAnimation:animation forKey:nil];
}


/**
 *  UIViewAnimation
 *
 *  @see    http://www.cocoachina.com/bbs/read.php?tid=110168
 *
 *  @brief  UIView动画应该是最简单便捷创建动画的方式了,详解请猛戳URL.
 *
 *  @method beginAnimations:context 第一个参数用来作为动画的标识,第二个参数给代理代理传递消息.至于为什么一个使用
 *                                  nil而另外一个使用NULL,是因为第一个参数是一个对象指针,而第二个参数是基本数据类型.
 *  @method setAnimationCurve:      设置动画的加速或减速的方式(速度)
 *  @method setAnimationDuration:   动画持续时间
 *  @method setAnimationTransition:forView:cache:   第一个参数定义动画类型，第二个参数是当前视图对象，第三个参数是是否使用缓冲区
 *  @method commitAnimations        动画结束
 */

+ (void)animationFlipFromLeft:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationFlipFromRigh:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:view cache:NO];
    [UIView commitAnimations];
}


+ (void)animationCurlUp:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationCurlDown:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.35f];
    [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:view cache:NO];
    [UIView commitAnimations];
}

+ (void)animationPushUp:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromTop];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushDown:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromBottom];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationPushRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    
    [view.layer addAnimation:animation forKey:nil];
}

// presentModalViewController
+ (void)animationMoveUp:(UIView *)view duration:(CFTimeInterval)duration
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:duration];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromTop];
    
    [view.layer addAnimation:animation forKey:nil];
}

// dissModalViewController
+ (void)animationMoveDown:(UIView *)view duration:(CFTimeInterval)duration
{
    CATransition *transition = [CATransition animation];
    transition.duration =0.4;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [view.layer addAnimation:transition forKey:nil];
}

+ (void)animationMoveLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromLeft];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationMoveRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:kCATransitionMoveIn];
    [animation setSubtype:kCATransitionFromRight];
    
    [view.layer addAnimation:animation forKey:nil];
}

+(void)animationRotateAndScaleEffects:(UIView *)view
{
    [UIView animateWithDuration:0.35f animations:^
     {
         /**
          *  @see       http://donbe.blog.163.com/blog/static/138048021201061054243442/
          *
          *  @param     transform   形变属性(结构体),可以利用这个属性去对view做一些翻转或者缩放.详解请猛戳↑URL.
          *
          *  @method    valueWithCATransform3D: 此方法需要一个CATransform3D的结构体.一些非详细的讲解可以看下面的URL
          *
          *  @see       http://blog.csdn.net/liubo0_0/article/details/7452166
          *
          */
         
         view.transform = CGAffineTransformMakeScale(0.001, 0.001);
         
         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
         
         // 向右旋转45°缩小到最小,然后再从小到大推出.
         animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.70, 0.40, 0.80)];
         
         /**
          *     其他效果:
          *     从底部向上收缩一半后弹出
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.0, 1.0, 0.0)];
          *
          *     从底部向上完全收缩后弹出
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0.0)];
          *
          *     左旋转45°缩小到最小,然后再从小到大推出.
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.50, -0.50, 0.50)];
          *
          *     旋转180°缩小到最小,然后再从小到大推出.
          *     animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0.1, 0.2, 0.2)];
          */
         
         animation.duration = 0.45;
         animation.repeatCount = 1;
         [view.layer addAnimation:animation forKey:nil];
         
     }
                     completion:^(BOOL finished)
     {
         [UIView animateWithDuration:0.35f animations:^
          {
              view.transform = CGAffineTransformMakeScale(1.0, 1.0);
          }];
     }];
}

/** CABasicAnimation
 *
 *  @see https://developer.apple.com/library/mac/#documentation/cocoa/conceptual/CoreAnimation_guide/Articles/KVCAdditions.html
 *
 *  @brief                      便利构造函数 animationWithKeyPath: KeyPath需要一个字符串类型的参数,实际上是一个
 *                              键-值编码协议的扩展,参数必须是CALayer的某一项属性,你的代码会对应的去改变该属性的效果
 *                              具体可以填写什么请参考上面的URL,切勿乱填!
 *                              例如这里填写的是 @"transform.rotation.z" 意思就是围绕z轴旋转,旋转的单位是弧度.
 *                              这个动画的效果是把view旋转到最小,再旋转回来.
 *                              你也可以填写@"opacity" 去修改透明度...以此类推.修改layer的属性,可以用这个类.
 *
 *  @param toValue              动画结束的值.CABasicAnimation自己只有三个属性(都很重要)(其他属性是继承来的),分别为:
 *                              fromValue(开始值), toValue(结束值), byValue(偏移值),
 !                              这三个属性最多只能同时设置两个;
 *                              他们之间的关系如下:
 *                              如果同时设置了fromValue和toValue,那么动画就会从fromValue过渡到toValue;
 *                              如果同时设置了fromValue和byValue,那么动画就会从fromValue过渡到fromValue + byValue;
 *                              如果同时设置了byValue  和toValue,那么动画就会从toValue - byValue过渡到toValue;
 *
 *                              如果只设置了fromValue,那么动画就会从fromValue过渡到当前的value;
 *                              如果只设置了toValue  ,那么动画就会从当前的value过渡到toValue;
 *                              如果只设置了byValue  ,那么动画就会从从当前的value过渡到当前value + byValue.
 *
 *                              可以这么理解,当你设置了三个中的一个或多个,系统就会根据以上规则使用插值算法计算出一个时间差并
 *                              同时开启一个Timer.Timer的间隔也就是这个时间差,通过这个Timer去不停地刷新keyPath的值.
 !                              而实际上,keyPath的值(layer的属性)在动画运行这一过程中,是没有任何变化的,它只是调用了GPU去
 *                              完成这些显示效果而已.
 *                              在这个动画里,是设置了要旋转到的弧度,根据以上规则,动画将会从它当前的弧度专旋转到我设置的弧度.
 *
 *  @param duration             动画持续时间
 *
 *  @param timingFunction       动画起点和终点之间的插值计算,也就是说它决定了动画运行的节奏,是快还是慢,还是先快后慢...
 */

/** CAAnimationGroup
 *
 *  @brief                      顾名思义,这是一个动画组,它允许多个动画组合在一起并行显示.比如这里设置了两个动画,
 *                              把他们加在动画组里,一起显示.例如你有几个动画,在动画执行的过程中需要同时修改动画的某些属性,
 *                              这时候就可以使用CAAnimationGroup.
 *
 *  @param duration             动画持续时间,值得一提的是,如果添加到group里的子动画不设置此属性,group里的duration会统一
 *                              设置动画(包括子动画)的duration属性;但是如果子动画设置了duration属性,那么group的duration属性
 *                              的值不应该小于每个子动画中duration属性的值,否则会造成子动画显示不全就停止了动画.
 *
 *  @param autoreverses         动画完成后自动重新开始,默认为NO.
 *
 *  @param repeatCount          动画重复次数,默认为0.
 *
 *  @param animations           动画组(数组类型),把需要同时运行的动画加到这个数组里.
 *
 *  @note  addAnimation:forKey  这个方法的forKey参数是一个字符串,这个字符串可以随意设置.
 *
 *  @note                       如果你需要在动画group执行结束后保存动画效果的话,设置 fillMode 属性,并且把
 *                              removedOnCompletion 设置为NO;
 */

+ (void)animationRotateAndScaleDownUp:(UIView *)view
{
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:(2 * M_PI) * 2];
    rotationAnimation.duration = 0.35f;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.duration = 0.35f;
    scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.35f;
    animationGroup.autoreverses = YES;
    animationGroup.repeatCount = 1;
    animationGroup.animations =[NSArray arrayWithObjects:rotationAnimation, scaleAnimation, nil];
    [view.layer addAnimation:animationGroup forKey:@"animationGroup"];
}



#pragma mark - Private API

+ (void)animationFlipFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"oglFlip"];
    [animation setSubtype:@"fromTop"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationFlipFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"oglFlip"];
    [animation setSubtype:@"fromBottom"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromLeft:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromLeft"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromRight:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromTop:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromTop"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCubeFromBottom:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cube"];
    [animation setSubtype:@"fromBottom"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationSuckEffect:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"suckEffect"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationRippleEffect:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"rippleEffect"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCameraOpen:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cameraIrisHollowOpen"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}

+ (void)animationCameraClose:(UIView *)view
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.35f];
    [animation setFillMode:kCAFillModeForwards];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animation setType:@"cameraIrisHollowClose"];
    [animation setSubtype:@"fromRight"];
    
    [view.layer addAnimation:animation forKey:nil];
}
#endif

@end
