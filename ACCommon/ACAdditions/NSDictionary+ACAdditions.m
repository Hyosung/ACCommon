//
//  NSDictionary+ACAdditions.m
//  ACCommon
//
//  Created by i云 on 14-4-20.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSDictionary+ACAdditions.h"

//@implementation NSMutableDictionary (ACAdditions)
//
//- (void)setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key {
//    if (!obj || !key) {
//        return;
//    }
//    
//    [self setObject:obj forKey:key];
//}
//
//@end

@implementation NSDictionary (ACAdditions)

- (NSString *)JSONString {
    
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:nil];
    NSString *__autoreleasing JSONString = [[NSString alloc] initWithData:data
                                                                 encoding:NSUTF8StringEncoding];
    return JSONString;
}

- (NSData *)JSONData {
    if (![NSJSONSerialization isValidJSONObject:self]) return nil;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}

- (id)objectForKeyedSubscript:(id)key {
    if (!key) {
        return nil;
    }
    
    return [self objectForKey:key];
}

- (NSString *)stringForKey:(id)aKey {
    
    if (!aKey || !self[aKey] || ![self[aKey] isKindOfClass:[NSString class]] ) {
        return @"";
    }
    
    return self[aKey];
}

- (NSInteger)integerForKey:(id)aKey {
    
    if (!aKey || !self[aKey]) {
        return NSIntegerMin;
    }
    
    return [self[aKey] integerValue];
}

- (CGFloat)floatForKey:(id)aKey {
    if (!aKey || !self[aKey]) {
        return CGFLOAT_MIN;
    }
    
    return [self[aKey] floatValue];
}

- (NSArray *)arrayForKey:(id)aKey {
    if (!aKey || !self[aKey] || ![self[aKey] isKindOfClass:[NSArray class]]) {
        return @[];
    }
    
    return self[aKey];
}

- (NSDictionary *)dictionaryForKey:(id)aKey {
    if (!aKey || !self[aKey] || ![self[aKey] isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    
    return self[aKey];
}

@end
