//
//  NSObject+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 13-12-8.
//  Copyright (c) 2013年 Crazy Stone. All rights reserved.
//

#import "NSObject+ACAdditions.h"
#import <objc/runtime.h>

@implementation NSObject (ACAdditions)

- (NSDictionary *)propertyDictionary{
    NSMutableDictionary *propertyDic = [NSMutableDictionary dictionary];
    
    //属性个数
    unsigned int outCount;
    
    //属性数组
    objc_property_t *property = class_copyPropertyList([self class], &outCount);
    
    //循环取出属性并存在字典中
    for (int i = 0; i < outCount; i++) {
        objc_property_t property_t = property[i];
        
        //获得属性的名称
        NSString *propertyName = [NSString stringWithCString:property_getName(property_t)
                                                    encoding:NSUTF8StringEncoding];
        
        //从对象中获得指定属性名的属性值
        id propertyValue = [self valueForKey:propertyName];
        
        //属性值不为空时，就封装进字典中
        if (propertyValue) {
            [propertyDic setObject:propertyValue forKey:propertyName];
        }
    }
    
    //释放掉属性数组
    free(property);
    return propertyDic;
}

- (NSDictionary *)methodDictionary {
    NSMutableDictionary *methodDic = [NSMutableDictionary dictionary];
    
    //方法个数
    unsigned int outCount;
    Method *methods = class_copyMethodList([self class], &outCount);
    for (int i = 0; i < outCount; i++) {
        Method method = methods[i];
        SEL selector = method_getName(method);
        
        [methodDic setObject:C_CONVERT_OC(selector) forKey:NSStringFromSelector(selector)];
    }
    
    free(methods);
    
    return methodDic;
}

- (NSDictionary *)instanceVariablesDictionary {
    NSMutableDictionary *ivarDic = [NSMutableDictionary dictionary];
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        Ivar ivar = ivars[i];
        NSString *ivarName = [NSString stringWithCString:ivar_getName(ivar)
                                                encoding:NSUTF8StringEncoding];
        
        id ivarValue = [self valueForKey:ivarName];
        if (ivarValue) {
            [ivarDic setObject:ivarValue forKey:ivarName];
        }
    }
    
    free(ivars);
    
    return ivarDic;
}

@end
