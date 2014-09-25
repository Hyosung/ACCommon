//
//  ACLargerImageView.h
//  ACCommon
//
//  Created by i云 on 14-6-23.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ACLargerImageView : UIView
+ (instancetype)largeImageViewWithImageURLStrings:(NSArray *) URLStrings;

@property (nonatomic) NSInteger currentSelectIndex;

- (void)showWithView:(UIView *) view;
- (void)show;
- (void)hide;
@end
