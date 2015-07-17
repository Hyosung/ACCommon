//
//  ACNetworkingConfig.m
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkingConfig.h"

@implementation ACNetworkingConfig

+ (instancetype)config {
    static dispatch_once_t onceToken;
    static ACNetworkingConfig *networkConfig = nil;
    dispatch_once(&onceToken, ^{
        networkConfig = [[self alloc] init];
    });
    return networkConfig;
}

@end
