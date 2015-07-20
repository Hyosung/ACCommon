//
//  ACNetworkCache.m
//  ACCommon
//
//  Created by 上海易凡 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkCache.h"

@implementation ACNetworkCache

+ (instancetype)cache {
    static dispatch_once_t onceToken;
    static ACNetworkCache *networkCache = nil;
    dispatch_once(&onceToken, ^{
        networkCache = [[self alloc] init];
    });
    return networkCache;
}

@end
