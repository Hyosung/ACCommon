//
//  ACNetworking.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ACCompletedCallback)(NSDictionary *result, NSError *error);
typedef void(^ACUploadCallback)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);
typedef void(^ACDownloadCallback)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead);

typedef NS_ENUM(NSUInteger, ACNetworkMethod) {
    ACNetworkMethodGET = 0  ,
    ACNetworkMethodPOST     ,
    ACNetworkMethodHEAD     ,
    ACNetworkMethodPUT      ,
    ACNetworkMethodPATCH    ,
    ACNetworkMethodDELETE
};

@interface ACNetworking : NSObject

+ (instancetype)network;

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

#pragma mark - 默认的baseURL
- (NSOperation *)fetchDataFromPath:(NSString *) path
                            method:(ACNetworkMethod) method
                        parameters:(NSDictionary *) parameters
                         completed:(ACCompletedCallback) callback;

- (NSOperation *)GET_fetchDataFromPath:(NSString *) path
                            parameters:(NSDictionary *) parameters
                             completed:(ACCompletedCallback) callback;

- (NSOperation *)POST_fetchDataFromPath:(NSString *) path
                             parameters:(NSDictionary *) parameters
                              completed:(ACCompletedCallback) callback;

- (NSOperation *)uploadFileFromPath:(NSString *) path
                         parameters:(NSDictionary *) parameters
                           fileInfo:(NSDictionary *) fileInfo
                          completed:(ACCompletedCallback) completedCallback
                             upload:(ACUploadCallback) uploadCallback;

- (NSOperation *)downloadFileFromPath:(NSString *) path
                           parameters:(NSDictionary *) parameters
                            completed:(ACCompletedCallback) completedCallback
                             download:(ACDownloadCallback) downloadCallback;

#pragma mark - 自定义请求链接

- (NSOperation *)fetchDataFromURLString:(NSString *) URLString
                                 method:(ACNetworkMethod) method
                             parameters:(NSDictionary *) parameters
                              completed:(ACCompletedCallback) callback;

- (NSOperation *)uploadFileFromURLString:(NSString *) URLString
                              parameters:(NSDictionary *) parameters
                                fileInfo:(NSDictionary *) fileInfo
                               completed:(ACCompletedCallback) completedCallback
                                  upload:(ACUploadCallback) uploadCallback;

- (NSOperation *)downloadFileFromURLString:(NSString *) URLString
                                parameters:(NSDictionary *) parameters
                                 completed:(ACCompletedCallback) completedCallback
                                  download:(ACDownloadCallback) downloadCallback;

#endif

@end
