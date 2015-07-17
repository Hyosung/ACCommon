//
//  ACTableViewCell.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACTableViewCell.h"

@implementation ACTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _showingSeparator = YES;
    _separatorLineWidth = 0.5;
    _separatorColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
    _separatorSpace = ACSeparatorSpacesMake(15.0, 0.0);
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (_showingSeparator && _separatorLineWidth > 0) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetStrokeColorWithColor(context, [_separatorColor CGColor]);
        CGContextSetLineWidth(context, _separatorLineWidth);
        CGPoint p1 = CGPointMake(_separatorSpace.left, CGRectGetHeight(rect) - 0.5);
        CGPoint p2 = CGPointMake(CGRectGetWidth(rect) - _separatorSpace.right, CGRectGetHeight(rect) - 0.5);
        
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextStrokePath(context);
    }
}

- (void)setSeparatorLineWidth:(CGFloat)separatorLineWidth {
    if (_separatorLineWidth != separatorLineWidth) {
        _separatorLineWidth = separatorLineWidth;
        [self setNeedsDisplay];
    }
}

- (void)setShowingSeparator:(BOOL)showingSeparator {
    if (_showingSeparator != showingSeparator) {
        _showingSeparator = showingSeparator;
        [self setNeedsDisplay];
    }
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    if (_separatorColor != separatorColor) {
        _separatorColor = separatorColor;
        [self setNeedsDisplay];
    }
}

- (void)setSeparatorSpace:(ACSeparatorSpaces)separatorSpace {
    if (!ACSeparatorSpacesEqualToSeparatorSpaces(_separatorSpace, separatorSpace)) {
        _separatorSpace = separatorSpace;
        [self setNeedsDisplay];
    }
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
