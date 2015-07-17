//
//  NSArray+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-8-9.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSArray+ACAdditions.h"

//@implementation NSMutableArray (ACAdditions)
//
//- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
//    if (!obj || idx >= self.count) {
//        return;
//    }
//    
//    [self replaceObjectAtIndex:idx withObject:obj];
//}
//
//@end

@implementation NSArray (ACAdditions)

- (NSString *)JSONString {
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString *__autoreleasing JSONStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return JSONStr;
}

- (NSData *)JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    if (idx >= self.count) {
        return nil;
    }
    return [self objectAtIndex:idx];
}

@end
