//
//  ACAnimation.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACAnimation : NSObject

#if defined(__USE_QuartzCore__) && __USE_QuartzCore__
/**********************************************常用动画************************************************/
#pragma mark - Custom Animation

/**
 *   @brief 快速构建一个你自定义的动画,有以下参数供你设置.
 *
 *   @note  调用系统预置Type需要在调用类引入下句
 *
 *          #import <QuartzCore/QuartzCore.h>
 *
 *   @param type                动画过渡类型
 *   @param subType             动画过渡方向(子类型)
 *   @param duration            动画持续时间
 *   @param timingFunction      动画定时函数属性
 *   @param theView             需要添加动画的view.
 *
 *
 */

+ (void)showAnimationType:(NSString *)type
              withSubType:(NSString *)subType
                 duration:(CFTimeInterval)duration
           timingFunction:(NSString *)timingFunction
                     view:(UIView *)theView;

#pragma mark - Preset Animation

/**
 *  下面是一些常用的动画效果
 */

// reveal
+ (void)animationRevealFromBottom:(UIView *)view;
+ (void)animationRevealFromTop:(UIView *)view;
+ (void)animationRevealFromLeft:(UIView *)view;
+ (void)animationRevealFromRight:(UIView *)view;

// 渐隐渐消
+ (void)animationEaseIn:(UIView *)view;
+ (void)animationEaseOut:(UIView *)view;

// 翻转
+ (void)animationFlipFromLeft:(UIView *)view;
+ (void)animationFlipFromRigh:(UIView *)view;

// 翻页
+ (void)animationCurlUp:(UIView *)view;
+ (void)animationCurlDown:(UIView *)view;

// push
+ (void)animationPushUp:(UIView *)view;
+ (void)animationPushDown:(UIView *)view;
+ (void)animationPushLeft:(UIView *)view;
+ (void)animationPushRight:(UIView *)view;

// move
+ (void)animationMoveUp:(UIView *)view duration:(CFTimeInterval)duration;
+ (void)animationMoveDown:(UIView *)view duration:(CFTimeInterval)duration;
+ (void)animationMoveLeft:(UIView *)view;
+ (void)animationMoveRight:(UIView *)view;

// 旋转缩放

/**
 *  @author Stoney, 15-07-14 17:07:49
 *
 *  @brief  各种旋转缩放效果
 *
 */
+ (void)animationRotateAndScaleEffects:(UIView *)view;

/**
 *  @author Stoney, 15-07-14 17:07:12
 *
 *  @brief  旋转同时缩小放大效果
 *
 */
+ (void)animationRotateAndScaleDownUp:(UIView *)view;

/**
 *  @author Stoney, 15-07-14 17:07:25
 *
 *  @brief  旋转加缩放
 *
 */
+ (void)animationRotateAndScale:(UIView *) view;

/**
 *  @author Stoney, 15-07-14 17:07:39
 *
 *  @brief  旋转
 *
 */
+ (void)animationRotate:(UIView *) view;

/**
 *  @author Stoney, 15-07-14 17:07:51
 *
 *  @brief  抖动
 *
 */
+ (void)animationShake:(UIView *) view;

/**
 *  @author Stoney, 15-07-14 17:07:07
 *
 *  @brief  抛物线
 *
 */
+ (void)animationCurve:(UIView *) view;

/**
 *  @author Stoney, 15-07-14 17:07:24
 *
 *  @brief  发光的动画
 *
 */
+ (void)animationShine:(UIView *) view
   andHighlightedImage:(UIImage *) highlightedImage
          andMaskImage:(UIImage *) maskImage;

/**
 *  @author Stoney, 15-04-07 13:04:38
 *
 *  永久闪烁的动画
 *
 *  @param duration 动画时间
 *
 *  @return 动画对象
 */
+ (CABasicAnimation *)animationForeverFlashing:(CFTimeInterval)duration;

/**
 *  @author Stoney, 15-04-07 14:04:34
 *
 *  有闪烁次数的动画
 *
 *  @param duration    动画时间
 *  @param repeatCount 动画次数
 *
 *  @return 动画对象
 */
+ (CABasicAnimation *)animationFlashing:(CFTimeInterval)duration
                            repeatCount:(CGFloat)repeatCount;

/**
 *  @author Stoney, 15-04-07 14:04:20
 *
 *  横向移动
 *
 *  @param duration 动画时间
 *  @param x        x
 *
 *  @return 动画对象
 */
+ (CABasicAnimation *)animationHorizontalMove:(CFTimeInterval)duration
                                            x:(CGFloat) x;

/**
 *  @author Stoney, 15-04-07 14:04:44
 *
 *  纵向移动
 *
 *  @param duration 动画时间
 *  @param y        y
 *
 *  @return 动画对象
 */
+ (CABasicAnimation *)animationVerticalMove:(CFTimeInterval)duration
                                          y:(CGFloat)y;

/**
 *  @author Stoney, 15-04-07 14:04:10
 *
 *  缩放动画
 *
 *  @param duration    动画时间
 *  @param scale       缩放系数
 *  @param orginScale  旧的缩放系数
 *  @param repeatCount 动画次数
 *
 *  @return 动画对象
 */
+ (CABasicAnimation *)animationScale:(CFTimeInterval)duration
                               scale:(CGFloat) scale
                          orginScale:(CGFloat) orginScale
                         repeatCount:(CGFloat) repeatCount;

/**
 *  @author Stoney, 15-04-07 14:04:05
 *
 *  路径动画
 *
 *  @param duration    动画时间
 *  @param path        东华路径
 *  @param repeatCount 动画次数
 *
 *  @return 动画对象
 */
+ (CAKeyframeAnimation *)animationKeyframe:(CFTimeInterval) duration
                                      path:(CGPathRef)path
                               repeatCount:(CGFloat)repeatCount;

/**
 *  @author Stoney, 15-04-07 15:04:35
 *
 *  旋转动画
 *
 *  @param duration    动画时间
 *  @param degree      旋转度数
 *  @param direction   旋转方向
 *  @param repeatCount 动画次数
 *
 *  @return 动画对象
 */
+(CABasicAnimation *)animationRotation:(CFTimeInterval)duration
                                degree:(CGFloat)degree
                             direction:(CGFloat)direction
                           repeatCount:(CGFloat)repeatCount;

#pragma mark - Private API

/**
 *  下面动画里用到的某些属性在当前API里是不合法的,但是也可以用.
 */

+ (void)animationFlipFromTop:(UIView *)view;
+ (void)animationFlipFromBottom:(UIView *)view;

+ (void)animationCubeFromLeft:(UIView *)view;
+ (void)animationCubeFromRight:(UIView *)view;
+ (void)animationCubeFromTop:(UIView *)view;
+ (void)animationCubeFromBottom:(UIView *)view;

+ (void)animationSuckEffect:(UIView *)view;

+ (void)animationRippleEffect:(UIView *)view;

+ (void)animationCameraOpen:(UIView *)view;
+ (void)animationCameraClose:(UIView *)view;
#endif

@end
