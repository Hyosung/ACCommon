//
//  NSObject+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 13-12-8.
//  Copyright (c) 2013年 Alone Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ACAdditions)

/**
 将对象中的属性封装到字典中
 */
- (NSDictionary *)propertyDictionary;

/**
 将对象的方法封装到字典中
 */
- (NSDictionary *)methodDictionary;

/**
 将对象的实例变量封装到字典中
 */
- (NSDictionary *)instanceVariablesDictionary;
@end
