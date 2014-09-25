//
//  NSArray+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-8-9.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSArray+ACAdditions.h"

@implementation NSArray (ACAdditions)

- (NSString *)JSONString {
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}

@end
