//
//  ACNetworkConfig.h
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACNetworkConfig : NSObject

+ (instancetype)config;

@property (nonatomic, copy) NSURL *baseURL;

/**
 *  @author Stoney, 15-07-22 10:07:22
 *
 *  @brief  下载文件的存放文件夹 默认 ~Document/Download
 */
@property (nonatomic, copy) NSString *downloadFolder;

/**
 *  @author Stoney, 15-07-22 10:07:10
 *
 *  @brief  请求超时时间 默认 30.0s
 */
@property (nonatomic) NSTimeInterval timeoutInterval;

/**
 *  @author Stoney, 15-07-22 10:07:59
 *
 *  @brief  缓存过期时间 默认 180.0s(3min)
 */
@property (nonatomic) NSTimeInterval cacheExpirationTimeInterval;

@end
