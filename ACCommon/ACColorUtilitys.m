//
//  ACColorUtilitys.m
//  ACCommon
//
//  Created by 暁星 on 15/7/15.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <UIKit/UIColor.h>
#import "ACColorUtilitys.h"

UIColor * ACColorHexa(int hex, float alpha) {
   return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                          green:((float)((hex & 0x00FF00) >> 8 )) / 255.0
                           blue:((float)((hex & 0x0000FF) >> 0 )) / 255.0
                          alpha:alpha];
}

UIColor * ACColorHex(int hex) {
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0
                           green:((float)((hex & 0x00FF00) >> 8 )) / 255.0
                            blue:((float)((hex & 0x0000FF) >> 0 )) / 255.0
                           alpha:1.0];
}

UIColor * ACColorRGBA(float red, float green, float blue, float alpha) {
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:alpha];
}

UIColor * ACColorRGB(float red, float green, float blue) {
    return [UIColor colorWithRed:red / 255.0
                           green:green / 255.0
                            blue:blue / 255.0
                           alpha:1.0];
}

UIColor * ACColorRGBSamea(float value, float alpha) {
    return [UIColor colorWithRed:value / 255.0
                           green:value / 255.0
                            blue:value / 255.0
                           alpha:alpha];
}

UIColor * ACColorRGBSame(float value) {
    return [UIColor colorWithRed:value / 255.0
                           green:value / 255.0
                            blue:value / 255.0
                           alpha:1.0];
}