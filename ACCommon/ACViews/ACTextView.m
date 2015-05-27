//
//  ACTextView.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACTextView.h"

@interface ACTextView () {
	BOOL shouldDrawPlaceholder;
}

- (void)initialize;
- (void)updateShouldDrawPlaceholder;
- (void)textChanged:(NSNotification *)notification;

@end

@implementation ACTextView

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if ((self = [super initWithCoder:aDecoder])) {
		[self initialize];
	}
	return self;
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        [self initialize];
	}
	return self;
}

- (void)setText:(NSString *)string {
	[super setText:string];
	[self updateShouldDrawPlaceholder];
}

- (void)setPlaceholder:(NSString *)string {
    if (![_placeholder isEqualToString:string]) {
        
        _placeholder = string;
        [self updateShouldDrawPlaceholder];
    }
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	if (shouldDrawPlaceholder) {
        
        if (shouldDrawPlaceholder) {
            
            CGSize placeholderSize = [_placeholder sizeWithAttributes:@{NSFontAttributeName: self.font}];
            CGFloat placeholderHeight = MIN(placeholderSize.height, self.height - 16.0f);
            if ([_placeholder respondsToSelector:@selector(drawInRect:withAttributes:)]) {
                
                [_placeholder drawInRect:CGRectMake(8.0f,
                                                    (self.height - placeholderHeight) / 2.0,
                                                    self.width - 16.0f,
                                                    placeholderHeight)
                          withAttributes:@{NSFontAttributeName: self.font, NSForegroundColorAttributeName: _placeholderTextColor}];
            }
            else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
                [_placeholderTextColor set];
                [_placeholder drawInRect:CGRectMake(8.0f,
                                                    (self.height - placeholderHeight) / 2.0,
                                                    self.width - 16.0f,
                                                    placeholderHeight)
                                withFont:self.font];
#endif
            }
            
        }
	}
}


#pragma mark - Private

- (void)initialize {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
	
	self.placeholderTextColor = [UIColor colorWithWhite:0.702f alpha:1.0f];
	shouldDrawPlaceholder = NO;
}

- (void)updateShouldDrawPlaceholder {
	BOOL prev = shouldDrawPlaceholder;
	shouldDrawPlaceholder = self.placeholder && self.placeholderTextColor && self.text.length == 0;
	
	if (prev != shouldDrawPlaceholder) {
		[self setNeedsDisplay];
	}
}

- (void)textChanged:(NSNotification *)notification {
	[self updateShouldDrawPlaceholder];
}

@end
