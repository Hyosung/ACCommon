//
//  UIImageView+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (ACAdditions)

#pragma mark - Gesture
- (void)addTapGesture:(void(^)(UIImageView *imageView)) tapBlock forKey:(const void *) key;
- (void)addTapGesture:(void(^)(UIImageView *imageView)) tapBlock;
- (void)addLongPressGesture:(void(^)(UIImageView *imageView)) longPressBlock;

- (void)removeGestureForKey:(const void *) key;

#pragma mark - WebImage Loading

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
- (void)setACImageURLString:(NSString *) anURLString;
#endif

@end
