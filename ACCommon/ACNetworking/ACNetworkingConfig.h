//
//  ACNetworkingConfig.h
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACNetworkingConfig : NSObject

+ (instancetype)config;

@property (nonatomic, copy) NSURL *baseURL;
@property (nonatomic, copy) NSString *downloadFolder;
@property NSTimeInterval timeoutInterval;

@end
