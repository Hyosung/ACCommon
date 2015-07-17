//
//  NSDictionary+ACAdditions.h
//  ACCommon
//
//  Created by i云 on 14-4-20.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

//@interface NSMutableDictionary (ACAdditions)
//@end

@interface NSDictionary (ACAdditions)

#pragma mark - JSONString

- (NSString *)JSONString;
- (NSData *)JSONData;

- (NSDictionary *)dictionaryForKey:(id) aKey;
- (NSArray *)arrayForKey:(id) aKey;
- (NSString *)stringForKey:(id) aKey;
- (NSInteger)integerForKey:(id) aKey;
- (CGFloat)floatForKey:(id) aKey;

@end
