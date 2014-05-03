//
//  UIButton+ACExpands.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (ACExpands)

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)setACImageURLString:(NSString *) anURLString;
- (void)setACImageURLString:(NSString *) anURLString forState:(UIControlState)state;

- (void)setACBackgroundImageURLString:(NSString *) anURLString;
- (void)setACBackgroundImageURLString:(NSString *) anURLString forState:(UIControlState)state;
#endif

@end
