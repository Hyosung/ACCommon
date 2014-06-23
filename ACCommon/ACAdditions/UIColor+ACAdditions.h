//
//  UIColor+ACAdditions.h
//  ACCommon
//
//  Created by i云 on 14-6-23.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ACAdditions)
#pragma mark - 比较颜色的相似度
- (BOOL)compareAreSimilar:(UIColor *) color;
- (BOOL)compareAreSimilar:(UIColor *) color andSimilarity:(CGFloat) s;
@end
