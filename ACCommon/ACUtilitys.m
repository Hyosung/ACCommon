//
//  ACUtilitys.m
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACUtilitys.h"

#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <sys/utsname.h>
#import <sys/sysctl.h>

@import ImageIO;

@implementation ACUtilitys

#if defined(ACIMP_SINGLETON)
ACIMP_SINGLETON(ACUtilitys)
#endif

inline NSString * UUID() {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    return [[NSUUID UUID] UUIDString];
#else
    
    CFUUIDRef UUID = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef UUIDStr = CFUUIDCreateString(kCFAllocatorDefault, UUID);
    CFRelease(UUID);
    return CFBridgingRelease(UUIDStr);
#endif
}

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);///-----get device struct info
    
    NSString *platform = [NSString stringWithUTF8String:machine];
    
    free(machine);
    return STRING_NULL_MSG([self deviceModels][platform], @"Apple 设备");
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
        
        NSAssert(NO, @"ACCommon: Could not find a root view controller. ");
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
    
    if ([UIScreen mainScreen].scale == 2 && image2x) {
        return image2x;
    }
   
    if (!image1x) {
        return image2x;
    }
    
    return image1x;
}

+ (UIImage *)imageNamed:(NSString *) name {
    return [self imageNamed:name orType:@"png"];
}

+ (UIImage *)imageNamedExtJpg:(NSString *)name {
    return [self imageNamed:name orType:@"jpg"];
}

+ (UIImage *)imageCacheNamed:(NSString *)name {
    return [UIImage imageNamed:name];
}

+ (UIImage *)imagesSynthesisWithImages:(NSArray *)images size:(CGSize)size {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    for (NSDictionary *info in images) {
        UIImage *curImage = info[@"image"];
        CGRect curRect = CGRectFromString(info[@"rect"]);
        if (curImage && CGRectGetWidth(curRect) > 0 && CGRectGetHeight(curRect) > 0) {
            [curImage drawInRect:curRect];
        }
    }
    
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
    
    NSString *ret = @"其他";
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    if (carrier == nil) {
        
        return ret;
    }
    
    NSString *code = [carrier mobileNetworkCode];
    
    if ([code isEqualToString:@""]) {
        
        return ret;
    }
    
    if ([code isEqualToString:@"00"] ||
        [code isEqualToString:@"02"] ||
        [code isEqualToString:@"07"]) {
        
        ret = @"移动";
    }
    
    if ([code isEqualToString:@"01"] ||
        [code isEqualToString:@"06"] ) {
        ret = @"联通";
    }
    
    if ([code isEqualToString:@"03"] ||
        [code isEqualToString:@"05"] ) {
        ret = @"电信";
    }
    
    return ret;
}

+ (NSString *)getTimeDiffString:(NSTimeInterval) timestamp {
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *todate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *today = [NSDate date];//当前时间
    unsigned int unitFlag = NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
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

+ (CGSize)calculateSize:(CGSize)originSize newSize:(CGSize)size {
  
    CGFloat newWidth = MIN(originSize.width, size.width);
    CGFloat newHeight = [self calculateHeightKnownWidth:newWidth originSize:originSize];
    if (newHeight > size.height) {
        newWidth = [self calculateWidthKnownHeight:size.height originSize:originSize];
        newHeight = size.height;
    }
//    newHeight = MIN(newHeight, originSize.height);
    return CGSizeMake(newWidth, newHeight);
}

+ (CGFloat)calculateHeightKnownWidth:(CGFloat)width originSize:(CGSize)size {
    return (size.height / size.width) * width;
}

+ (CGFloat)calculateWidthKnownHeight:(CGFloat)height originSize:(CGSize)size {
    return (size.width / size.height) * height;
}

+ (UIImage *)drawPlaceholderImage:(UIImage *) image size:(CGSize) size color:(UIColor *) color {
//    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
//                                                                  NSUserDomainMask,
//                                                                  YES) firstObject];
//    id scaleMark = ([UIScreen mainScreen].scale > 1) ? [NSString stringWithFormat:@"@%@x", @([UIScreen mainScreen].scale)] : @"";
//    NSString *newPath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"placeholder/placeholder_%@x%@%@.png", @((NSInteger)size.width), @((NSInteger)size.height), scaleMark]];
//    UIImage *newImage = [UIImage imageWithContentsOfFile:newPath];
//    
//    if (newImage) {
//        return newImage;
//    }
    
    if (!image || (size.width <= 0 || size.height <= 0)) {
        return nil;
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextFillRect(contextRef, CGRectMake(0, 0, size.width, size.height));
    
    CGFloat width = MAX(MIN(size.width - 60.0, image.size.width), image.size.width / 2.0);
    CGFloat scale = image.size.height / image.size.width;
    CGFloat height = scale * width;
    
    CGSize newSize = CGSizeMake(width, height);
    
    CGContextTranslateCTM(contextRef, 0, size.height);
    CGContextScaleCTM(contextRef, 1, -1);
    CGContextDrawImage(contextRef,CGRectMake(size.width / 2.0 - newSize.width / 2.0,
                                             size.height / 2.0 - newSize.height / 2.0,
                                             newSize.width,
                                             newSize.height), [image CGImage]);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
//    NSString *placeholderDirPath = [documentPath stringByAppendingPathComponent:@"placeholder"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:placeholderDirPath]) {
//        [[NSFileManager defaultManager] createDirectoryAtPath:placeholderDirPath
//                                  withIntermediateDirectories:YES
//                                                   attributes:nil
//                                                        error:nil];
//    }
//    
//    [UIImagePNGRepresentation(newImage) writeToFile:newPath atomically:YES];
    
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *)drawPureImage:(UIColor *)maskColor
                 forecolor:(UIColor *)forecolor
                 imagePath:(NSString *)imagePath {
    return [self drawPureImage:maskColor
                             forecolor:forecolor
                           originImage:[UIImage imageWithContentsOfFile:imagePath]];
}

+ (UIImage *)drawPureImage:(UIColor *)maskColor
                 forecolor:(UIColor *)forecolor
               originImage:(UIImage *)image {
    CGRect imageRect = CGRectMake(0.0,
                                  0.0,
                                  CGImageGetWidth(image.CGImage),
                                  CGImageGetHeight(image.CGImage));
    
    // 创建位图上下文
    
    CGContextRef context = CGBitmapContextCreate(NULL, // 内存图片数据
                                                 
                                                 imageRect.size.width, // 宽
                                                 
                                                 imageRect.size.height, // 高
                                                 
                                                 8, // 色深
                                                 
                                                 0, // 每行字节数
                                                 
                                                 CGImageGetColorSpace(image.CGImage), // 颜色空间
                                                 
                                                 CGImageGetBitmapInfo(image.CGImage)/*kCGImageAlphaPremultipliedLast*/);// alpha通道，RBGA
    
    // 设置当前上下文填充色为白色（RGBA值）
    CGContextSetRGBFillColor(context,
                             CGColorGetComponents([forecolor CGColor])[0],
                             CGColorGetComponents([forecolor CGColor])[1],
                             CGColorGetComponents([forecolor CGColor])[2],
                             CGColorGetAlpha([forecolor CGColor]));
    
    CGContextFillRect(context, imageRect);
    
    // 用 originImage 作为 clipping mask（选区）
    
    CGContextClipToMask(context, imageRect, image.CGImage);
    
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
    UIImage *newImage = [UIImage imageWithCGImage:newCGImage
                                            scale:image.scale
                                      orientation:image.imageOrientation];
    
    // Cleanup
    CGContextRelease(context);
    
    CGImageRelease(newCGImage);
    
    return newImage;
}

+ (UIImage *)drawPureColor:(UIColor *)color{
    return [self drawPureColor:color size:CGSizeMake(57.0, 57.0)];
}

+ (UIImage *)drawPureColor:(UIColor *)color size:(CGSize)size {
    UIImage *image = nil;
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [color setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0.0, 0.0, size.width, size.height));
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/**
 * 绘制背景色渐变的矩形，colors渐变颜色设置，集合中存储UIColor对象（创建Color时一定用三原色来创建）
 **/
+ (UIImage *)drawGradientColor:(CGRect) clipRect
                       options:(CGGradientDrawingOptions) options
                        colors:(NSArray *) colors {
    UIImage *newImage = nil;
    UIGraphicsBeginImageContextWithOptions(clipRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);// 保持住现在的context
    CGContextClipToRect(context, clipRect);// 截取对应的context
    
    NSUInteger colorCount = colors.count;
    int numOfComponents = 4;
    CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[colorCount * numOfComponents];
    
    int i = 0;
    for (UIColor *color in colors) {
        CGColorRef temcolorRef = color.CGColor;
        const CGFloat *components = CGColorGetComponents(temcolorRef);
        for (int j = 0; j < numOfComponents; ++j) {
            colorComponents[i * numOfComponents + j] = components[j];
        }
        i++;
    }
    
    CGGradientRef gradient =  CGGradientCreateWithColorComponents(rgb, colorComponents, NULL, colorCount);
    CGColorSpaceRelease(rgb);
    
    CGPoint startPoint = clipRect.origin;
    CGPoint endPoint = CGPointMake(CGRectGetMinX(clipRect), CGRectGetMaxY(clipRect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, options);
    CGGradientRelease(gradient);
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);// 恢复到之前的context
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (BOOL)limitInputWords:(NSUInteger) wordCount
                  input:(id) input
                 string:(NSString *) string
                  range:(NSRange) range {
    
    NSAssert(([input isKindOfClass:[UITextField class]] || [input isKindOfClass:[UITextView class]]), @"input对象必须是UITextField或者UITextView");
    
    if ([string isEqualToString:@"\n"]) { //按会车可以改变
        return YES;
    }
    
    NSString *currentText = [[input text] stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    
    if (currentText.length > wordCount) { //如果输入框内容大于wordCount则弹出警告
        [input setText:[currentText substringToIndex:wordCount]];
        return NO;
    }
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

+ (void)automaticallyDetectVersion:(void (^)(NSDictionary *))block url:(NSString *)url {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //CFShow((__bridge CFTypeRef)(infoDic));
    
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    __autoreleasing NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(
                                               NSURLResponse *response,
                                               NSData *data,
                                               NSError *error )
    {
                               
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                           options:NSJSONReadingAllowFragments
                                                             error:nil];
        NSArray *infoArray = dic[@"results"];
        if (infoArray.count) {
            NSDictionary *releaseInfo = infoArray.firstObject;
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

+ (void)checkWhetherUpdate:(NSString *)url {

    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    //CFShow((__bridge CFTypeRef)(infoDic));
    
    NSString *currentVersion = infoDic[@"CFBundleShortVersionString"];
    __autoreleasing NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.HTTPMethod = @"POST";
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    NSData *recervedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&error];
    
    if (!recervedData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                            message:@"网络连接失败"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
            [alert show];
        });
        return;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:recervedData
                                                        options:NSJSONReadingAllowFragments
                                                          error:nil];
    NSArray *infoArray = dic[@"results"];
    if (infoArray.count <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            __autoreleasing UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"软件更新"
                                                                            message:@"当前软件还未上线"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确定"
                                                                  otherButtonTitles:nil];
            [alert show];
        });
        return;
    }
    
    NSDictionary *releaseInfo = infoArray.firstObject;
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

+ (void)applicationRatings:(NSString *) url {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (NSURL *)appStoreURL:(NSString *)appid {
    static NSURL *appStoreURL = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *displayName = info[@"CFBundleDisplayName"];
        //    NSString *displayName = [info objectForKey:@"CFBundleName"];
        //https://itunes.apple.com/us/app/bu-yi-li-ji/id647152789?mt=8&uo=4
        NSMutableArray *spliceArray = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < displayName.length; i++) {
            NSMutableString *spliceText = [NSMutableString stringWithFormat:@"%C",[displayName characterAtIndex:i]];
            //转换为带声调的拼音
            CFStringTransform((__bridge CFMutableStringRef)spliceText, NULL, kCFStringTransformToLatin, false);
            NSString *transformText = [spliceText stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
            
            [spliceArray addObject:transformText];
        }
        
        NSString *appStoreURLText = [NSString stringWithFormat:@"https://itunes.apple.com/cn/app/%@/id%@?mt=8",[spliceArray componentsJoinedByString:@"-"], appid];
        appStoreURL = [NSURL URLWithString:[appStoreURLText lowercaseString]];
    });
    return appStoreURL;
}

+ (void)showNoContentWhenPrompted:(BOOL)visible
                    displayedView:(UIView *)view
                   displayContent:(NSString *)content {
    if (visible) {
        UILabel *label = (UILabel *)[view viewWithTag:2048];
        if (!label) {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds) / 4)];
            label.tag = 2048;
            label.font = [UIFont systemFontOfSize:17.0];
            label.center = view.center;
            label.textColor = [UIColor lightGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            [view addSubview:label];
        }
        label.text = content;
        label.alpha = 0.0;
        
        [UIView animateWithDuration:0.3 animations:^{
            label.alpha = 1.0;
        }];
    }
    else {
        UILabel *label = (UILabel *)[view viewWithTag:2048];
        if (label) {
            [UIView animateWithDuration:0.3 animations:^{
                label.alpha = 0.0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
            }];
        }
    }
}

+ (NSInteger)getRandomNumber:(NSInteger)from to:(NSInteger)to {
    
    NSAssert(to > from, @"from 不能大于等于 to");
    return from + arc4random() % (to - from);
}

+ (NSInteger)getRandomNumberTo:(NSInteger)to{
    return [self getRandomNumber:0 to:to];
}

+ (double)getFloatRandomNumber:(double)from to:(double)to {
    NSAssert(to > from, @"from 不能大于等于 to");
    double randomNumber = from + ((double)arc4random() / ARC4RANDOM_MAX) * (to - from);
    return [[NSString stringWithFormat:@"%0.1lf",randomNumber] doubleValue];
}

@end
