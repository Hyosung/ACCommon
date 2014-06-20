//
//  NSObject+Property.h
//  ACCommon
//
//  Created by 曉星 on 13-12-8.
//  Copyright (c) 2013年 Alone Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Property)

/*
 将对象中的属性封装到字典中
 */
- (NSDictionary *)propertyDictionary;
@end
