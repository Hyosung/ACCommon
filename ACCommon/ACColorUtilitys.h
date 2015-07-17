//
//  ACColorUtilitys.h
//  ACCommon
//
//  Created by 暁星 on 15/7/15.
//  Copyright (c) 2015年 Crazy Stone. All rights reserved.
//

#ifndef ACCommon_ACColorUtilitys_h
#define ACCommon_ACColorUtilitys_h

#import <UIKit/UIKitDefines.h>
@class UIColor;

UIKIT_EXTERN UIColor * ACColorHexa(int hex, float alpha);
UIKIT_EXTERN UIColor * ACColorHex(int hex);
UIKIT_EXTERN UIColor * ACColorRGBA(float red, float green, float blue, float alpha);
UIKIT_EXTERN UIColor * ACColorRGB(float red, float green, float blue);
UIKIT_EXTERN UIColor * ACColorRGBSamea(float value, float alpha);
UIKIT_EXTERN UIColor * ACColorRGBSame(float value);

#endif
