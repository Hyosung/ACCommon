//
//  ACUtilitys.m
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACUtilitys.h"

#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>

@import ImageIO;

@interface ACUtilitys() {
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

@implementation ACUtilitys

#if defined(ACIMP_SINGLETON)
ACIMP_SINGLETON(ACUtilitys)
#endif

- (void)dealloc {
#if defined(__USE_Reachability__) && __USE_Reachability__
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    [hostReach stopNotifier];
#endif
}

inline NSString * UUID() {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    return [[NSUUID UUID] UUIDString];
#else
    
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDStr = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    NSString *uuidStr = (__bridge NSString *)(UUIDStr);
    CFRelease(UUID);
    CFRelease(UUIDStr);
    return uuidStr;
#endif
}

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);///-----get device struct info
    
    NSString *platform = [NSString stringWithUTF8String:machine];
    
    free(machine);
    return STRING_NULL_MSG([ACUtilitys deviceModels][platform], @"未知设备");
}

+ (NSDictionary *)deviceModels {
    static NSDictionary *info = nil;
    
    AC_EXEONCE_BEGIN(_models_)
    info = @{
             @"i386": @"iPhone Simulator",
             @"x86_64": @"iPhone Simulator",
             
             @"iPhone1,1": @"iPhone 2G",
             
             @"iPhone1,2": @"iPhone 3G",
             @"iPhone2,1": @"iPhone 3GS",
             
             @"iPhone3,1": @"iPhone 4(GSM)",
             @"iPhone3,2": @"iPhone 4(GSM Rev A)",
             @"iPhone3,3": @"iPhone 4(CDMA)",
             
             @"iPhone4,1": @"iPhone 4S",
             
             @"iPhone5,1": @"iPhone 5(GSM)",
             @"iPhone5,2": @"iPhone 5(GSM+CDMA)",
             
             @"iPhone5,3": @"iPhone 5c(GSM)",
             @"iPhone5,4": @"iPhone 5c(Global)",
             
             @"iPhone6,1": @"iPhone 5s(GSM)",
             @"iPhone6,2": @"iPhone 5s(Global)",
             
             @"iPhone7,2": @"iPhone 6",
             @"iPhone7,1": @"iPhone 6 Plus",
             
             @"iPod1,1": @"iPod Touch 1G",
             @"iPod2,1": @"iPod Touch 2G",
             @"iPod3,1": @"iPod Touch 3G",
             @"iPod4,1": @"iPod Touch 4G",
             @"iPod5,1": @"iPod Touch 5G",
             
             @"iPad1,1": @"iPad",
             
             @"iPad2,1": @"iPad 2(Wi-Fi)",
             @"iPad2,2": @"iPad 2(GSM)",
             @"iPad2,3": @"iPad 2(CDMA)",
             @"iPad2,4": @"iPad 2(Wi-Fi + New Chip)",
             
             @"iPad3,1": @"iPad 3(Wi-Fi)",
             @"iPad3,2": @"iPad 3(GSM+CDMA)",
             @"iPad3,3": @"iPad 3(GSM)",
             
             @"iPad3,4": @"iPad 4(Wi-Fi)",
             @"iPad3,5": @"iPad 4(GSM)",
             @"iPad3,6": @"iPad 4(GSM+CDMA)",
             
             @"iPad4,1": @"iPad Air(Wi-Fi)",
             @"iPad4,2": @"iPad Air(GSM+CDMA)",
             @"iPad4,3": @"iPad Air(GSM)",
             
             @"iPad4,4": @"iPad mini Retina(Wi-Fi)",
             @"iPad4,5": @"iPad mini Retina(GSM+CDMA)",
             @"iPad4,6": @"iPad mini Retina(GSM)",
             
             @"iPad2,5": @"iPad mini(Wi-Fi)",
             @"iPad2,6": @"iPad mini(GSM)",
             @"iPad2,7": @"iPad mini(GSM+CDMA)"
             
             };
    AC_EXEONCE_END
    
    return info;
}

+ (NSString *)currentDeviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    //    printf("sysname:%s\n",systemInfo.sysname);
    //    printf("nodename:%s\n",systemInfo.nodename);
    //    printf("release:%s\n",systemInfo.release);
    //    printf("version:%s\n",systemInfo.version);
    //    printf("machine:%s\n",systemInfo.machine);
    char *machines = strtok(systemInfo.machine, ",");
    if (machines == NULL) {
        return nil;
    }
    
    NSString *deviceString = [NSString stringWithCString:&machines[0] encoding:NSUTF8StringEncoding];
    return deviceString;
    //    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

+ (UIViewController *)currentViewController {
    
    id result = nil;
    
    UIApplication *sharedApplication = [UIApplication sharedApplication];
    UIWindow *topWindow = sharedApplication.keyWindow;
    
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        
        NSArray *windows = sharedApplication.windows;
        
        for(topWindow in windows) {
            
            if (topWindow.windowLevel == UIWindowLevelNormal && topWindow.subviews.count > 0) {
                break;
            }
        }
    }
    
    UIView *rootView = topWindow.subviews.firstObject;
    
    id nextResponder = [rootView nextResponder];
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
        else if ([nextResponder isKindOfClass:[UIViewController class]]) {
            result = nextResponder;
            break;
        }
        nextResponder = [nextResponder nextResponder];
    }
    
    return result;
}

+ (UIViewController *)currentRootViewController {
    
    UIViewController *result;
    
    // Try to find the root view controller programmically
    
    // Find the top window (that is not an alert view or other window)
    
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal) {
        
        NSArray *windows = [[UIApplication sharedApplication] windows];
        
        for(topWindow in windows) {
            
            if (topWindow.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    
    UIView *rootView = [[topWindow subviews] firstObject];
    
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        
        result = nextResponder;
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil) {
        
        result = topWindow.rootViewController;
    }
    else {
        
        NSAssert(NO, @"ACCommon: Could not find a root view controller.  You can assign one manually by calling [[SHK currentHelper] setRootViewController:YOURROOTVIEWCONTROLLER].");
    }
    
    return result;
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
    return [ACUtilitys imageNamed:name orType:@"png"];
}

+ (UIImage *)imageNamedExtJpg:(NSString *)name {
    return [ACUtilitys imageNamed:name orType:@"jpg"];
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

+ (UIImage *)imagesSynthesisWithImages:(NSArray *)images andSize:(CGSize)size {
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

+ (NSArray *)gifParseWithGifData:(NSData *)gifData {
    
    if (!gifData) {
        return nil;
    }
    
    //加载gif
    CGImageSourceRef gif = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, nil);

    //获取gif的各种属性
    CFDictionaryRef gifprops = CGImageSourceCopyPropertiesAtIndex(gif, 0, NULL);

    //获取gif中静态图片的数量
    size_t count = CGImageSourceGetCount(gif);

//    CFDictionaryRef gifDic = CFDictionaryGetValue(gifprops, kCGImagePropertyGIFDictionary);
//
//    CFDictionaryRef delay = CFDictionaryGetValue(gifDic, kCGImagePropertyGIFDelayTime);
//
//    [gifDic objectForKey:(NSString *)kCGImagePropertyGIFDelayTime];
//
//    NSNumber * w = CFDictionaryGetValue(gifprops, @"PixelWidth");
//
//    NSNumber * h =CFDictionaryGetValue(gifprops, @"PixelHeight");
//
//    float totalDuration = delay.doubleValue * count;
//
//    float pixelWidth = w.intValue;
//
//    float pixelHeight = h.intValue;

    //将gif解析成UIImage类型对象，并加进images数组中
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];

    for(size_t index = 0; index < count; index++) {
        CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, nil);

        UIImage *img = [UIImage imageWithCGImage:ref];

        if (img) {
            
            [images addObject:img];
        }

        CFRelease(ref);
    }

    CFRelease(gifprops);
    CFRelease(gif);
    
    return images;
}

//用来辨别设备所使用网络的运营商
+ (NSString*)checkCarrier {
    
    NSString *ret = @"";
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    if (carrier == nil) {
        
        return ret;
    }
    
    NSString *code = [carrier mobileNetworkCode];
    
    if ([code isEqualToString:@""]) {
        
        return ret;
    }
    
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        
        ret = @"移动";
    }
    
    if ([code isEqualToString:@"01"]|| [code isEqualToString:@"06"] ) {
        ret = @"联通";
    }
    
    if ([code isEqualToString:@"03"]|| [code isEqualToString:@"05"] ) {
        ret = @"电信";
    }
    
    return ret;
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
    
    if (ABS([gap day]) > 0) {
        return [NSString stringWithFormat:@"%ld天前", ABS((long)([gap day]))];
    }
    else if (ABS([gap hour]) > 0) {
        return [NSString stringWithFormat:@"%ld小时前", ABS((long)([gap hour]))];
    }
    else {
        return [NSString stringWithFormat:@"%ld分钟前",  ABS((long)([gap minute]))];
    }
}

+ (UIImage *)cutImageWithFrame:(CGRect)frame image:(UIImage *)image {
    
    CGFloat height = [ACUtilitys reckonWithSize:image.size width:CGRectGetWidth(frame)];
    if (image.size.width < CGRectGetWidth(frame)) {
        frame.size.width = image.size.width;
        if (image.size.height < CGRectGetHeight(frame)) {
            frame.size.height = image.size.height;
        }
    } else {
        UIImage *newImage1 = [ACUtilitys zoomImageWithSize:CGSizeMake(CGRectGetWidth(frame), height) image:image];
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
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image
                          isHeight:(BOOL)flag
                            number:(CGFloat)number {
    CGSize size;
    if (flag) {
        size = CGSizeMake([ACUtilitys reckonWithSize:image.size height:number], number);
    }else{
        size = CGSizeMake(number, [ACUtilitys reckonWithSize:image.size width:number]);
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
    CGSize newSize = [ACUtilitys reckonWithSize:image.size andNewSize:size];
    [image drawInRect:CGRectMake(
                                 size.width / 2 - newSize.width / 2,
                                 size.height / 2 - newSize.height / 2,
                                 newSize.width,
                                 newSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)resizedFixedImageWithImage:(UIImage *)image size:(CGSize)size {
    
    UIImage *newImage = nil;
    CGSize newSize = [ACUtilitys reckonWithSize:image.size andNewSize:size];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [UIScreen mainScreen].scale);
    
    [image drawInRect:CGRectMake(0.0,
                                 0.0,
                                 newSize.width,
                                 newSize.height)];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (CGSize)reckonWithSize:(CGSize) oldSize andNewSize:(CGSize) newSize {
    CGFloat newWidth = MIN(oldSize.width, newSize.width);
    CGFloat newHeight = [ACUtilitys reckonWithSize:oldSize width:newWidth];
    if (newHeight > newSize.height) {
        newWidth = [ACUtilitys reckonWithSize:oldSize height:newSize.height];
        newHeight = newSize.height;
    }
    newHeight = MIN(newHeight, oldSize.height);
    return CGSizeMake(newWidth, newHeight);
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image toHeight:(CGFloat)height {
    return [ACUtilitys resizedImageWithImage:image isHeight:YES number:height];
}

+ (UIImage *)resizedImageWithImage:(UIImage *)image toWidth:(CGFloat)width {
    return [ACUtilitys resizedImageWithImage:image isHeight:NO number:width];
}

+ (CGFloat)reckonWithSize:(CGSize) size
                 isHeight:(BOOL) flag
                   number:(CGFloat) number {
    CGFloat newNumber = 0.0f;
    CGFloat scale1 = size.height / size.width;
    CGFloat scale2 = size.width / size.height;
    if (!flag) {
        newNumber = scale1 * number;
    }else{
        newNumber = scale2 * number;
    }
    return newNumber;
}

+ (CGFloat)reckonWithSize:(CGSize) size height:(CGFloat) height {
    return [ACUtilitys reckonWithSize:size isHeight:YES number:height];
}

+ (CGFloat)reckonWithSize:(CGSize) size width:(CGFloat) width {
    return [ACUtilitys reckonWithSize:size isHeight:NO number:width];
}

+ (UIImage *)drawMask:(UIColor *)maskColor
      foregroundColor:(UIColor *)foregroundColor
      imageNamedOrExt:(NSString *)nameOrExt {
    return [ACUtilitys drawMask:maskColor
             foregroundColor:foregroundColor
                       image:[ACUtilitys imageNamed:nameOrExt orType:nil]];
}

+ (UIImage *)drawMask:(UIColor *)maskColor
      foregroundColor:(UIColor *)foregroundColor
                image:(UIImage *)originImage {
    CGRect imageRect = CGRectMake(
                                  0,
                                  0,
                                  CGImageGetWidth(originImage.CGImage),
                                  CGImageGetHeight(originImage.CGImage));
    
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
                             CGColorGetAlpha([foregroundColor CGColor]));
    
    CGContextFillRect(context,imageRect);
    
    // 用 originImage 作为 clipping mask（选区）
    
    CGContextClipToMask(context,imageRect, originImage.CGImage);
    
    // 设置当前填充色为黑色
    CGContextSetRGBFillColor(
                             context,
                             CGColorGetComponents([maskColor CGColor])[0],
                             CGColorGetComponents([maskColor CGColor])[1],
                             CGColorGetComponents([maskColor CGColor])[2],
                             CGColorGetAlpha([maskColor CGColor]));
    
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
    return [ACUtilitys drawPlaceholderWithSize:size bgcolor:PLACEHOLDER_COLOR];
}

+ (UIImage *)drawPlaceholderWithSize:(CGSize)size bgcolor:(UIColor *)color {
    UIImage *oldImage = [UIImage imageNamed:PLACEHOLDER_NAME];
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(contextRef, CGRectMake(0, 0, size.width, size.height));
    CGFloat height = MIN(size.height, oldImage.size.height);
    CGSize newSize = CGSizeMake(height - 20.0, height - 20.0);
    
    if (newSize.width >= size.width) {
        newSize = CGSizeMake(size.width - 20, size.width - 20);
    }
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1, -1);
    CGContextDrawImage(contextRef,CGRectMake(
                                             size.width / 2.0 - newSize.width / 2.0,
                                             size.height / 2.0 - newSize.height / 2.0,
                                             newSize.width,
                                             newSize.height), [oldImage CGImage]);
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)drawingColor:(UIColor *)color {
    return [ACUtilitys drawingColor:color size:CGSizeMake(57, 57)];
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
    id textField = nil;
    if ([obj isKindOfClass:[UITextField class]] ||
        [obj isKindOfClass:[UITextView class]]) {
        textField = obj;
    }
    else {
        NSAssert(textField, @"对象必须是UITextField或者UITextView");
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
        formattedStr = NSLocalizedString(@"Empty", "");
    }
    else {
        if (size > 0 && size < 1024) {
            formattedStr = [NSString stringWithFormat:@"%qu bytes", size];
        }
        else {
            if (size >= 1024 && size < pow(1024, 2)) {
                formattedStr = [NSString stringWithFormat:@"%.1f KB", (size / 1024.)];
            }
            else {
                if (size >= pow(1024, 2) && size < pow(1024, 3)) {
                    formattedStr = [NSString stringWithFormat:@"%.2f MB", (size / pow(1024, 2))];
                }
                else {
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
                           completionHandler:^( NSURLResponse *response,
                                                NSData *data,
                                                NSError *error )
    {
                               
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
        NSArray *infoArray = dic[@"results"];
        if ([infoArray count]) {
            NSDictionary *releaseInfo = infoArray[0];
            NSString *lastVersion = releaseInfo[@"version"];
           
            if ([lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                NSString *trackViewURL = releaseInfo[@"trackViewUrl"];
                NSString *releaseNotes = releaseInfo[@"releaseNotes"];
               
                if (block) {
                   
                    block(@{@"trackViewUrl": trackViewURL,
                            @"version": lastVersion,
                            @"releaseNotes": releaseNotes});
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
            
            if ([lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
                NSString *trackViewURL = releaseInfo[@"trackViewUrl"];
                NSString *releaseNotes = releaseInfo[@"releaseNotes"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationAppUpdate"
                                                                    object:self
                                                                  userInfo:@{@"trackViewUrl": trackViewURL,
                                                                             @"version": lastVersion,
                                                                             @"releaseNotes": releaseNotes}];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                                    message:@"当前版本已是最新版本"
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"确定"
                                                                          otherButtonTitles:nil];
                    [alert show];
                });
            }
        }
        else {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                                message:@"当前软件还未上线"
                                                                               delegate:nil
                                                                      cancelButtonTitle:@"确定"
                                                                      otherButtonTitles:nil];
                [alert show];
            });
        }
    }
    else {
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
    for (int i = 0; i < displayName.length; i++) {
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

    [ACUtilitys setNavigationBar:navBar contentView:_imgv];
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
        UILabel *label = nil;
        if (![view viewWithTag:1024]) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT / 4)];
            label.tag = 1024;
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor lightGrayColor];
            label.font = [UIFont systemFontOfSize:17.0];
            label.textAlignment = NSTextAlignmentCenter;
            label.center = view.center;
            
            [view addSubview:label];
        }
        else {
            label = (UILabel *)[view viewWithTag:1024];
        }
        label.alpha = 0;
        label.text = content;
        
        [UIView animateWithDuration:0.3 animations:^{
            label.alpha = 1;
        }];
    }
    else {
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
        }
        else {
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
    
    for (int i = 0; i < sbc.length; i++) {
        unichar temp = [sbc characterAtIndex:i];
        if (temp >= 65281 && temp <= 65374) {
            temp = temp - 65248;
            dbc = [NSString stringWithFormat:@"%@%C",dbc,temp];
        }
        else {
            if (temp == 12288) {
                temp = 32;
            }
            dbc = [NSString stringWithFormat:@"%@%C",dbc,temp];
        }
    }
    
    return dbc;
}

+ (NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to {
    
    NSAssert(to > from, @"from 不能大于等于 to");
    return from + arc4random() % (to - from);
}

+ (NSInteger)getRandomNumberTo:(NSInteger)to{
    return [ACUtilitys getRandomNumber:0 to:to];
}

+ (double)getFloatRandomNumber:(double)from to:(double)to {
    NSAssert(to > from, @"from 不能大于等于 to");
    double randomNumber = from + ((double)arc4random() / ARC4RANDOM_MAX) * (to - from);
    return [[NSString stringWithFormat:@"%0.1lf",randomNumber] doubleValue];
}

#if defined(__USE_Reachability__) && __USE_Reachability__
- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus status = [curReach currentReachabilityStatus];
    if (curStatus != status) {
        switch (status) {
            case ReachableViaWiFi: {
                [SVProgressHUD showSuccessWithStatus:@"当前网络WiFi"];
            }
                break;
            case ReachableViaWWAN: {
                [SVProgressHUD showSuccessWithStatus:@"当前网络3G/2G"];
            }
                break;
            case NotReachable: {
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
    return (![ACUtilitys isEnable3G] && ![ACUtilitys isEnableWiFi]);
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

@end
