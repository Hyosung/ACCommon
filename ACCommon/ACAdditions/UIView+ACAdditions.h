//
//  UIView+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (ACAdditions)

#pragma mark - Frame Simplify

@property (nonatomic) CGSize size;
@property (nonatomic) CGPoint origin;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat left;

/**
 *  @author Stoney, 15-07-14 17:07:36
 *
 *  @brief  superView的顶部到view的底部的这段距离
 */
@property (nonatomic) CGFloat bottom;

/**
 *  @author Stoney, 15-07-14 17:07:28
 *
 *  @brief  superView的左边到view的右边的这段距离
 */
@property (nonatomic) CGFloat right;


/**
 *  @author Stoney, 15-07-14 17:07:33
 *
 *  @brief  左边和顶部的偏移
 */
@property (nonatomic) UIOffset leftTopOffset;

/**
 *  @author Stoney, 15-07-14 17:07:09
 *
 *  @brief  右边和底部的偏移
 */
@property (nonatomic) UIOffset rightBottomOffset;

#pragma mark - View Snapshot

- (UIImage *)snapshot;
- (void)saveSnapshotToPhotosAlbum;

#pragma mark - UIViewController

- (UIViewController *)viewController;
- (UIViewController *)rootViewController;

@end
