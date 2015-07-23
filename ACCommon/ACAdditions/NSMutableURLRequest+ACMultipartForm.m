//
//  NSMutableURLRequest+ACMultipartForm.m
//  ACCommon
//
//  Created by 暁星 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "NSMutableURLRequest+ACMultipartForm.h"

@implementation NSMutableURLRequest (ACMultipartForm)

UIKIT_STATIC_INLINE NSString * ACCreateMultipartFormBoundary() {
    return [NSString stringWithFormat:@"1FB654A0BC6968FE+%08X%08x", arc4random(), arc4random()];
}

static NSString * const kACMultipartFormCRLF = @"\r\n";

/**
 *  @author Stoney, 15-07-23 15:07:16
 *
 *  @brief 开头的分界线
 *
 */
UIKIT_STATIC_INLINE NSString * ACMultipartFormInitiallyBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"--%@%@", boundary, kACMultipartFormCRLF];
}

/**
 *  @author Stoney, 15-07-23 15:07:34
 *
 *  @brief  内部的分界线
 *
 */
UIKIT_STATIC_INLINE NSString * ACMultipartFormInternalBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@%@", kACMultipartFormCRLF, boundary, kACMultipartFormCRLF];
}

/**
 *  @author Stoney, 15-07-23 15:07:52
 *
 *  @brief  结尾的分界线
 *
 */
UIKIT_STATIC_INLINE NSString * ACMultipartFormFinalityBoundary(NSString *boundary) {
    return [NSString stringWithFormat:@"%@--%@--%@", kACMultipartFormCRLF, boundary, kACMultipartFormCRLF];
}

@end
