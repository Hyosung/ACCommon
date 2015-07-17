//
//  ACTextField.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
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
	
	if ((!self.text || [self.text isEqualToString:@""]) && self.placeholder) {
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder
                                                                     attributes:@{NSForegroundColorAttributeName: placeholderTextColor,
                                                                                  NSFontAttributeName: self.font}];
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
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.placeholder drawInRect:rect withAttributes:@{NSFontAttributeName: self.font,
                                                       NSForegroundColorAttributeName: self.placeholderTextColor}];
#else
    [_placeholderTextColor setFill];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 60000
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingTail alignment:self.textAlignment];
#else
    [self.placeholder drawInRect:rect withFont:self.font lineBreakMode:UILineBreakModeTailTruncation alignment:self.textAlignment];
#endif
#endif
}

@end
