//
//  ACNetworking.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ACNetworkRequest.h"
#import "ACNetworkUploadRequest.h"
#import "ACNetworkDownloadRequest.h"

@interface ACNetworking : NSObject

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

+ (instancetype)network;

- (void)cancelAllOperations;
- (void)cancelOperationWithIdentifier:(NSString *) identifier;

/**
 *  @author Stoney, 15-07-22 17:07:44
 *
 *  @brief  请求数据
 *
 *  @param request 封装的请求对象
 *
 *  @return operation identifier
 */
- (NSString *)fetchDataFromRequest:(ACNetworkRequest *) request;

/**
 *  @author Stoney, 15-07-22 17:07:54
 *
 *  @brief  上传文件
 *
 *  @param request 封装的上传文件的请求对象
 *
 *  @return operation identifier
 */
- (NSString *)uploadFileFromRequest:(ACNetworkUploadRequest *) request;

/**
 *  @author Stoney, 15-07-22 17:07:29
 *
 *  @brief  下载文件
 *
 *  @param request 封装的下载文件的请求对象
 *
 *  @return operation identifier
 */
- (NSString *)downloadFileFromRequest:(ACNetworkDownloadRequest *) request;

#pragma mark - 默认的baseURL

- (NSString *)fetchDataFromPath:(NSString *) path
                         method:(ACNetworkMethod) method
                     parameters:(NSDictionary *) parameters
                     completion:(ACNetworkCompletionHandler) completionBlock;

- (NSString *)GET_fetchDataFromPath:(NSString *) path
                         parameters:(NSDictionary *) parameters
                         completion:(ACNetworkCompletionHandler) completionBlock;

- (NSString *)POST_fetchDataFromPath:(NSString *) path
                          parameters:(NSDictionary *) parameters
                          completion:(ACNetworkCompletionHandler) completionBlock;

- (NSString *)uploadFileFromPath:(NSString *) path
                        fileInfo:(NSDictionary *) fileInfo
                      parameters:(NSDictionary *) parameters
                        progress:(ACNetworkProgressHandler) progressBlock;

- (NSString *)downloadFileFromPath:(NSString *) path
                          progress:(ACNetworkProgressHandler) progressBlock;

#pragma mark - 自定义请求链接

- (NSString *)fetchDataFromURLString:(NSString *) URLString
                              method:(ACNetworkMethod) method
                          parameters:(NSDictionary *) parameters
                          completion:(ACNetworkCompletionHandler) completionBlock;

- (NSString *)uploadFileFromURLString:(NSString *) URLString
                             fileInfo:(NSDictionary *) fileInfo
                           parameters:(NSDictionary *) parameters
                             progress:(ACNetworkProgressHandler) progressBlock;

- (NSString *)downloadFileFromURLString:(NSString *) URLString
                               progress:(ACNetworkProgressHandler) progressBlock;

#endif

@end
