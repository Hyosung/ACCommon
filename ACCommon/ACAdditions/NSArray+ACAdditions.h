//
//  NSArray+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-8-9.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface NSMutableArray (ACAdditions)
//@end

@interface NSArray (ACAdditions)

#pragma mark - JSONString

- (NSString *)JSONString;
- (NSData *)JSONData;
@end
