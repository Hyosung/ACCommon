//
//  UIColor+ACAdditions.m
//  ACCommon
//
//  Created by i云 on 14-6-23.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "UIColor+ACAdditions.h"


#define kSimilarity 0.9 // 相识度
#define kMaxABSPoor 1.732051

@implementation UIColor (ACAdditions)

- (BOOL)compareAreSimilar:(UIColor *)color {
    return [self compareAreSimilar:color andSimilarity:kSimilarity];
}

- (BOOL)compareAreSimilar:(UIColor *)color andSimilarity:(CGFloat)s {
    if (!color) {
        return NO;
    }
    
    if (s > 1 || s < 0) {
        s = kSimilarity;
    }
    
    CGFloat red1, green1, blue1, alpha1;
    CGFloat red2, green2, blue2, alpha2;
    
    [self getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [color getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    CGFloat absRed   = red1 - red2;
    CGFloat absGreen = green1 - green2;
    CGFloat absBlue  = blue1 - blue2;
    CGFloat absAlpha = alpha1 - alpha2;
    CGFloat absPoor  = sqrtf(powf(absRed, 2) + powf(absGreen, 2) + powf(absBlue, 2) + powf(absAlpha, 2));
    if ((absPoor / kMaxABSPoor) <= s) {
        return YES;
    }
    return NO;
}
@end
