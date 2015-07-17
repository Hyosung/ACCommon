//
//  ACNetworking.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkingContent.h"

@interface ACNetworking : NSObject

+ (instancetype)network;

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

#pragma mark - 默认的baseURL
- (NSOperation *)fetchDataFromRequestContent:(ACNetworkingContent *) content;

- (NSOperation *)fetchDataFromPath:(NSString *) path
                            method:(ACNetworkMethod) method
                        parameters:(NSDictionary *) parameters
                        completion:(ACNetworkCompletionHandler) completionBlock;

- (NSOperation *)GET_fetchDataFromPath:(NSString *) path
                            parameters:(NSDictionary *) parameters
                            completion:(ACNetworkCompletionHandler) completionBlock;

- (NSOperation *)POST_fetchDataFromPath:(NSString *) path
                             parameters:(NSDictionary *) parameters
                             completion:(ACNetworkCompletionHandler) completionBlock;

- (NSOperation *)uploadFileFromPath:(NSString *) path
                           fileInfo:(NSDictionary *) fileInfo
                         parameters:(NSDictionary *) parameters
                           progress:(ACNetworkProgressHandler) progressBlock;

- (NSOperation *)downloadFileFromPath:(NSString *) path
                             progress:(ACNetworkProgressHandler) progressBlock;

#pragma mark - 自定义请求链接

- (NSOperation *)fetchDataFromURLString:(NSString *) URLString
                                 method:(ACNetworkMethod) method
                             parameters:(NSDictionary *) parameters
                             completion:(ACNetworkCompletionHandler) completionBlock;

- (NSOperation *)uploadFileFromURLString:(NSString *) URLString
                                fileInfo:(NSDictionary *) fileInfo
                              parameters:(NSDictionary *) parameters
                                progress:(ACNetworkProgressHandler) progressBlock;

- (NSOperation *)downloadFileFromURLString:(NSString *) URLString
                                  progress:(ACNetworkProgressHandler) progressBlock;

#endif

@end
