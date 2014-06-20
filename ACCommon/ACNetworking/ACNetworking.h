//
//  ACNetworking.h
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ACCompleteCallback)(NSDictionary *result, NSError *error);
typedef void(^ACUploadCallback)(unsigned long long totalBytesWritten, unsigned long long totalBytesExpectedToWrite);
typedef void(^ACDownloadCallback)(unsigned long long size, unsigned long long total);
typedef void(^ACQueueCompleteCallback)(void);
typedef void(^ACRequestCompleteCallback)(ASIHTTPRequest *request, NSDictionary *result, NSError *error);

extern NSString *const kACHTTPRequestBaseURLString;

@interface ACNetworking : NSObject

#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__

+ (void)startACASIHTTPRequestWithParams:(NSDictionary *) params
                                 method:(NSString *) method
                               complete:(ACCompleteCallback) callback;

+ (void)startACASIHTTPPostRequestWithParams:(NSDictionary *) params
                                   complete:(ACCompleteCallback) callback;

+ (void)startACASIHTTPGetRequestWithParams:(NSDictionary *) params
                                  complete:(ACCompleteCallback) callback;

+ (void)startACASIHTTPUploadWithParams:(NSDictionary *) params
                              fileKeys:(NSArray *) fileKeys
                            fileValues:(NSArray *) fileValues
                              complete:(ACCompleteCallback) completeCallback
                                upload:(ACUploadCallback) uploadCallback;

+ (void)startACASIHTTPDownloadWithURLString:(NSString *) URLString
                                   complete:(ACCompleteCallback) completeCallback
                                   download:(ACDownloadCallback) downloadCallback;


/**
 首先调用这两个方法
 */
+ (void)requestLoadingFinish:(ACRequestCompleteCallback) requestBlock;
+ (void)queueLoadingFinish:(ACQueueCompleteCallback) queueBlock;

/**
 其次才使用这个方法
 */
+ (void)appendRequestToNetworkQueueWithParams:(NSDictionary *) params
                                    URLString:(NSString *) URLString
                                       method:(NSString *) method;
#endif

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
+ (void)startACAFNHTTPRequestWithParams:(NSDictionary *) params
                                 method:(NSString *) method
                               complete:(ACCompleteCallback) callback;

+ (void)startACAFNHTTPPostRequestWithParams:(NSDictionary *) params
                                   complete:(ACCompleteCallback) callback;

+ (void)startACAFNHTTPGetRequestWithParams:(NSDictionary *) params
                                  complete:(ACCompleteCallback) callback;

+ (void)startACAFNHTTPUploadWithParams:(NSDictionary *) params
                              fileKeys:(NSArray *) fileKeys
                            fileValues:(NSArray *) fileValues
                              complete:(ACCompleteCallback) completeCallback
                                upload:(ACUploadCallback) uploadCallback;

+ (void)startACAFNHTTPDownloadWithURLString:(NSString *) URLString
                                   complete:(ACCompleteCallback) completeCallback
                                   download:(ACDownloadCallback) downloadCallback;
#endif

@end
