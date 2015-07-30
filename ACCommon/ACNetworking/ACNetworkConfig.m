//
//  ACNetworkConfig.m
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkConfig.h"

@implementation ACNetworkConfig

+ (instancetype)defaultConfig {
    static dispatch_once_t onceToken;
    static ACNetworkConfig *networkConfig = nil;
    dispatch_once(&onceToken, ^{
        networkConfig = [[self alloc] init];
        networkConfig.timeoutInterval = 30.0;
        networkConfig.cacheExpirationTimeInterval = 60.0 * 3;
        networkConfig.downloadFolder = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"Download"];
    });
    return networkConfig;
}

@end
