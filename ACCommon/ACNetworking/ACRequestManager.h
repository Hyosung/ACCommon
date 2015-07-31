//
//  ACRequestManager.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ACHTTPRequest.h"
#import "ACFileUploadRequest.h"
#import "ACFileDownloadRequest.h"

@interface ACRequestManager : NSObject

+ (instancetype)sharedManager;

- (void)cancelAllOperations;
- (void)cancelOperationWithIdentifier:(NSString *) identifier;
- (void)pauseOperationWithIdentifier:(NSString *) identifier;
- (void)resumeOperationWithIdentifier:(NSString *) identifier;
- (BOOL)isPausedOperationWithIdentifier:(NSString *) identifier;
- (BOOL)isExecutingOperationWithIdentifier:(NSString *) identifier;

/**
 *  @author Stoney, 15-07-22 17:07:44
 *
 *  @brief  请求数据
 *
 *  @param request 封装的请求对象
 *
 *  @return operation identifier 当返回nil时，说明有缓存可用
 */
- (NSString *)fetchDataFromRequest:(ACHTTPRequest *) request;

/**
 *  @author Stoney, 15-07-22 17:07:54
 *
 *  @brief  上传文件
 *
 *  @param request 封装的上传文件的请求对象
 *
 *  @return operation identifier
 */
- (NSString *)uploadFileFromRequest:(ACFileUploadRequest *) request;

/**
 *  @author Stoney, 15-07-22 17:07:29
 *
 *  @brief  下载文件
 *
 *  @param request 封装的下载文件的请求对象
 *
 *  @return operation identifier 当返回nil时，说明有缓存可用
 */
- (NSString *)downloadFileFromRequest:(ACFileDownloadRequest *) request;

#pragma mark - 默认的baseURL

- (NSString *)fetchDataFromPath:(NSString *) path
                         method:(ACRequestMethod) method
                     parameters:(NSDictionary *) parameters
                     completion:(ACRequestCompletionHandler) completionBlock;

- (NSString *)GET_fetchDataFromPath:(NSString *) path
                         parameters:(NSDictionary *) parameters
                         completion:(ACRequestCompletionHandler) completionBlock;

- (NSString *)POST_fetchDataFromPath:(NSString *) path
                          parameters:(NSDictionary *) parameters
                          completion:(ACRequestCompletionHandler) completionBlock;

- (NSString *)uploadFileFromPath:(NSString *) path
                        fileInfo:(NSDictionary *) fileInfo
                      parameters:(NSDictionary *) parameters
                        progress:(ACRequestProgressHandler) progressBlock;

- (NSString *)downloadFileFromPath:(NSString *) path
                          progress:(ACRequestProgressHandler) progressBlock;

#pragma mark - 自定义请求链接

- (NSString *)fetchDataFromURLString:(NSString *) URLString
                              method:(ACRequestMethod) method
                          parameters:(NSDictionary *) parameters
                          completion:(ACRequestCompletionHandler) completionBlock;

- (NSString *)uploadFileFromURLString:(NSString *) URLString
                             fileInfo:(NSDictionary *) fileInfo
                           parameters:(NSDictionary *) parameters
                             progress:(ACRequestProgressHandler) progressBlock;

- (NSString *)downloadFileFromURLString:(NSString *) URLString
                               progress:(ACRequestProgressHandler) progressBlock;

@end
