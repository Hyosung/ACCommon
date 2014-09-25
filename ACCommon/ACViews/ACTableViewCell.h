//
//  ACTableViewCell.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef struct ACSeparatorSpaces {
    CGFloat left, right;
} ACSeparatorSpaces;

UIKIT_STATIC_INLINE ACSeparatorSpaces ACSeparatorSpacesMake(CGFloat left, CGFloat right) {
    ACSeparatorSpaces spaces = {left, right};
    return spaces;
}

UIKIT_STATIC_INLINE BOOL ACSeparatorSpacesEqualToSeparatorSpaces(ACSeparatorSpaces spaces1, ACSeparatorSpaces spaces2) {
    return spaces1.left == spaces2.left && spaces1.right == spaces2.right;
}

@interface ACTableViewCell : UITableViewCell

@property (nonatomic) BOOL showingSeparator;
@property (nonatomic) ACSeparatorSpaces separatorSpace;
@property (nonatomic, strong) UIColor *separatorColor;

@end
