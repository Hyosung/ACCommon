//
//  ACRequestProtocol.h
//  ACCommon
//
//  Created by 暁星 on 15/7/22.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACRequestProtocol <NSObject>

/**
 *  @author Stoney, 15-07-31 09:07:48
 *
 *  @brief  响应的结果的类型 默认data
 */
@property ACResponseType responseType;

/**
 *  @author Stoney, 15-07-31 09:07:46
 *
 *  @brief  请求的URL
 */
@property (copy) NSURL *URL;

/**
 *  @author Stoney, 15-07-31 09:07:13
 *
 *  @brief  请求的路径 
 */
@property (copy) NSString *path;

/**
 *  @author Stoney, 15-07-31 09:07:02
 *
 *  @brief  请求方式
 */
@property ACRequestMethod method;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *) operationManager;

@end
