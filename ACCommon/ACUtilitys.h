//
//  ACUtilitys.h
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 常用工具类
 */

/*
 用于生成浮点型的随机数
 */
#define ARC4RANDOM_MAX 0x100000000

@interface ACUtilitys : NSObject

#if defined(AC_SINGLETON)
AC_SINGLETON(ACUtilitys)
#endif

extern inline NSString * UUID();

/**
 获取当前设备的名称如iPhone/iPod/iPad
 */
+ (NSString *)currentDeviceName;

+ (NSString *)platform;

/**
 当前视图控制器
 */
+ (UIViewController *)currentViewController;

/**
 当前根视图控制器
 */
+ (UIViewController *)currentRootViewController;

/*
 无缓存取图
 */
+ (UIImage *)imageNamed:(NSString *) name
                 orType:(NSString *) ext;
+ (UIImage *)imageNamed:(NSString *) name;
+ (UIImage *)imageNamedExtJpg:(NSString *) name;

/*
 有缓存取图
 */
+ (UIImage *)imageCacheNamed:(NSString *) name;

/*
 将多张图片合成一张
 @images 例:@[ @{ @"image": image1,@"rect": @"{{0,0},{120,120}}" },@{ @"image": image2,@"rect": @"{{120,0},{120,120}}" }]
 @size 合成图片的大小
 @return 合成的图片
 */
+ (UIImage *)imagesSynthesisWithImages:(NSArray *) images size:(CGSize) size;

/**
 gif图片解析
 */
+ (NSArray *)gifParseWithGifData:(NSData *) gifData;

+ (NSString*)checkCarrier;

/**
 将图片合成gif
 */
//+ (NSString *)imagesSynthesisGif:(NSArray *) images;

+ (NSString *)getTimeDiffString:(NSTimeInterval) timestamp;

/**
 传入原来的size与要转换的size，计算出新的size
 */
+ (CGSize)calculateSize:(CGSize) originSize newSize:(CGSize) size;

/*
 根据高度计算对应的宽度
 */
+ (CGFloat)calculateWidthKnownHeight:(CGFloat) height
                          originSize:(CGSize) size;
/*
 根据宽度计算对应的高度
 */
+ (CGFloat)calculateHeightKnownWidth:(CGFloat) width
                          originSize:(CGSize) size;

/**
 *  @author Stoney, 15-07-16 10:07:51
 *
 *  @brief  绘制占位图
 *
 *  @param image 原图
 *  @param size  绘制的大小
 *  @param color 绘制的底色
 *
 */
+ (UIImage *)drawPlaceholderImage:(UIImage *) image
                             size:(CGSize) size
                            color:(UIColor *) color;

/**
 *  @author Stoney, 15-07-16 11:07:34
 *
 *  @brief 给纯色图片重绘颜色
 *  @note  注:只对纯色图片有效
 *
 *  @param maskColor 罩遮色
 *  @param forecolor 前景色
 *  @param imagePath 图片路径
 *
 */
+ (UIImage *)drawPureImage:(UIColor *) maskColor
                 forecolor:(UIColor *) forecolor
                 imagePath:(NSString *) imagePath;

/**
 *  @author Stoney, 15-07-16 11:07:59
 *
 *  @brief  给纯色图片重绘颜色  
 *  @note   注:只对纯色图片有效
 *
 *  @param maskColor 罩遮色
 *  @param forecolor 前景色
 *  @param image     图片对象
 *
 */
+ (UIImage *)drawPureImage:(UIColor *) maskColor
                 forecolor:(UIColor *) forecolor
               originImage:(UIImage *) image;

/*
 根据传入的颜色绘制纯色图片 默认大小 {57，57}
 */
+ (UIImage *)drawPureColor:(UIColor *) color;

/*
 绘制纯色图片
 @param color 要绘制的颜色
 @param size  图片大小
 */
+ (UIImage *)drawPureColor:(UIColor *) color
                      size:(CGSize) size;

/*
 绘制渐变图
 */
+ (UIImage *)drawGradientColor:(CGRect) clipRect
                       options:(CGGradientDrawingOptions) options
                        colors:(NSArray *) colors;

/**
 限制UITextView或者UITextField的输入字数
 @wordCount 能输入的字数
 @input UITextView对象或者UITextField对象
 @string 当前对象中的字符串
 @range 当前对象的范围大小
 */
+ (BOOL)limitInputWords:(NSUInteger) wordCount
                  input:(id) input
                 string:(NSString *) string
                  range:(NSRange) range;

/*
 格式化文件大小
 @size 文件大小 字节（bytes）
 */
+ (NSString *)formattedFileSize:(unsigned long long)size;

/**
 *  @author Stoney, 15-07-16 11:07:59
 *
 *  @brief  自动检查版本是否可更新，并提示
 *
 *  @param block 字典中包含了应用在Apple Store上的下载地址和更新的信息、最新版本号，对应的key是trackViewUrl、releaseNotes、version
 *  @param url   在Apple Store 上请求的链接
 */
+ (void)automaticallyDetectVersion:(void (^)(NSDictionary *releaseInfo)) block
                               url:(NSString *) url;

/**
 *  @author Stoney, 15-07-16 11:07:03
 *
 *  @brief   检查是否有最新版本 有最新版本就从消息中心发出消息 消息名称是 NotificationAppUpdate
 *  @note    注意此方法为同步操作
 *
 *  @param url 请求Apple
 */
+ (void)checkWhetherUpdate:(NSString *) url;

/*
 跳转到App Store应用的评分页面
 @url 默认 SCORE_URL
 */
+ (void)applicationRatings:(NSString *) url;

/*
 应用在 App Store的下载地址
 @appid 应用的Apple ID
 */
+ (NSURL *)appStoreURL:(NSString *) appid;

/**
 *  @author Stoney, 15-07-16 14:07:35
 *
 *  @brief  显示无内容时的提示
 *
 *  @param visible 是否显示
 *  @param view    显示在的视图
 *  @param content 显示的内容
 */
+ (void)showNoContentWhenPrompted:(BOOL) visible
                    displayedView:(UIView *) view
                   displayContent:(NSString *) content;

/*
 生成from到to之间的随机数
 范围是[from,to) 包含from,不包含to
 */
+ (NSInteger)getRandomNumber:(NSInteger) from to:(NSInteger) to;

/*
 生成0-to之间的随机数
 范围是[0,to) 包含0,不包含to
 */
+ (NSInteger)getRandomNumberTo:(NSInteger) to;

/*
 生成浮点型的随机数
 范围[from,to) 包含from,包含to
 默认随机数一位小数点
 */
+ (double)getFloatRandomNumber:(double) from to:(double) to;

@end