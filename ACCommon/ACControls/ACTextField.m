//
//  ACTextField.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "ACTextField.h"

@implementation ACTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor {
	_placeholderTextColor = placeholderTextColor;
	
	if (!self.text && self.placeholder) {
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:@{NSForegroundColorAttributeName: placeholderTextColor,NSFontAttributeName: self.font}];
#else
		[self setNeedsDisplay];
#endif
	}
}


- (void)drawPlaceholderInRect:(CGRect)rect {
	if (!_placeholderTextColor) {
		[super drawPlaceholderInRect:rect];
		return;
	}
	
    [_placeholderTextColor setFill];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_6_0
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
#else
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
#endif
}

@end
