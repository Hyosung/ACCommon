//
//  ACNetworking.m
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "ACNetworking.h"

NSString *const kACHTTPRequestBaseURLString = @"<#string#>";

@interface ACNetworking (Private)

#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__

/**
 创建一个ASIHTTPRequest请求
 */
+ (ASIHTTPRequest *)requestWithURLString:(NSString *) theURLString
                                  method:(NSString *) method
                                  params:(NSDictionary *) params;

#endif

@end

@implementation ACNetworking
#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__

static char * const kACASIRequestFinishKey       = "kACASIRequestFinishKey";
static char * const kACASINetworkQueueFinishKey  = "kACASINetworkQueueFinishKey";

static ASINetworkQueue *networkQueue = nil;

#endif

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
static AFHTTPRequestOperationManager *afOperation = nil;
#endif


- (void)dealloc
{
#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__
    networkQueue = nil;
#endif
    
#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
    afOperation = nil;
#endif
}

+ (void)initialize
{
    if (self == [ACNetworking class]) {
#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__
        networkQueue = [ASINetworkQueue queue];
        networkQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
        
        networkQueue.delegate = self;
        networkQueue.shouldCancelAllRequestsOnFailure = NO;
        networkQueue.requestDidFailSelector = @selector(requestDidFailSelector:);
        networkQueue.requestDidFinishSelector = @selector(requestDidFinishSelector:);
        networkQueue.queueDidFinishSelector = @selector(queueDidFinishSelector:);
#endif
      
        
#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
        afOperation = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kACHTTPRequestBaseURLString]];
#endif
    }
}

#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__

+ (ASIHTTPRequest *)requestWithURLString:(NSString *)theURLString
                                  method:(NSString *)method
                                  params:(NSDictionary *)params {
    
    NSAssert((method && [method isKindOfClass:[NSString class]]), @"网络请求方式不正确");
    
    if (!theURLString || ![theURLString isKindOfClass:[NSString class]]) {
        theURLString = @"";
    }
    
    method = [method uppercaseString];
    
    NSString *encodeURLString = [theURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *baseURL = [NSURL URLWithString:kACHTTPRequestBaseURLString];
    NSURL *tempURL = [NSURL URLWithString:encodeURLString relativeToURL:baseURL];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:tempURL];
    request.requestMethod = method;
    if (params && [params isKindOfClass:[NSDictionary class]] && [params count]) {
        
        if ([method isEqualToString:@"GET"] ||
            [method isEqualToString:@"HEAD"] ||
            [method isEqualToString:@"DELETE"]) {
            
            NSMutableArray *paramsArray = [NSMutableArray array];
            for (NSString *key in params.allKeys) {
                [paramsArray addObject:ACSTR(@"%@=%@",key,params[key])];
            }
            
            NSString *URLString = [[tempURL.absoluteString stringByAppendingFormat:([tempURL.absoluteString rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@"),[paramsArray componentsJoinedByString:@"&"]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            tempURL = [NSURL URLWithString:URLString];
            
            request.url = tempURL;
        }
        else if ([method isEqualToString:@"POST"]) {
            request = [ASIFormDataRequest requestWithURL:tempURL];
            for (NSString *key in params.allKeys) {
                [(ASIFormDataRequest *)request setPostValue:params[key] forKey:key];
            }
        }
        else {
            ACLog(@"其他请求暂不处理");
        }
    }
    return request;
}

+ (void)startACASIHTTPRequestWithParams:(NSDictionary *)params
                                 method:(NSString *)method
                               complete:(ACCompleteCallback)callback {
    __weak ASIHTTPRequest *request = [ACNetworking requestWithURLString:nil method:method params:params];
    [request setCompletionBlock:^{
        if (callback) {
            __autoreleasing NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
            callback(result, error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    
    [request setFailedBlock:^{
        if (callback) {
            callback(nil, request.error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    
    [request startAsynchronous];
}

+ (void)startACASIHTTPPostRequestWithParams:(NSDictionary *)params
                                   complete:(ACCompleteCallback)callback {
    [ACNetworking startACASIHTTPRequestWithParams:params method:@"POST" complete:callback];
}

+ (void)startACASIHTTPGetRequestWithParams:(NSDictionary *)params
                                  complete:(ACCompleteCallback)callback {
    [ACNetworking startACASIHTTPRequestWithParams:params method:@"GET" complete:callback];
}

+ (void)startACASIHTTPDownloadWithURLString:(NSString *)URLString
                                   complete:(ACCompleteCallback)completeCallback
                                   download:(ACDownloadCallback)downloadCallback {
    __weak ASIHTTPRequest *request = [ACNetworking requestWithURLString:URLString method:@"GET" params:nil];
    [request setAllowResumeForFileDownloads:YES];
    [request setDownloadDestinationPath:[APP_CACHES stringByAppendingString:@"ACDownload"]];
    [request setTemporaryFileDownloadPath:APP_TMP_ADDTO(@"ACTemp")];
    [request setCompletionBlock:^{
        if (completeCallback) {
            NSError __autoreleasing *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
            completeCallback(result, error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    [request setFailedBlock:^{
        if (completeCallback) {
            completeCallback(nil, request.error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    
    [request setDownloadSizeIncrementedBlock:^(long long size) {
        if (downloadCallback) {
            downloadCallback(size, request.partialDownloadSize);
        }
    }];
    [request startAsynchronous];
}

+ (void)startACASIHTTPUploadWithParams:(NSDictionary *)params
                              fileKeys:(NSArray *)fileKeys
                            fileValues:(NSArray *)fileValues
                              complete:(ACCompleteCallback)completeCallback
                                upload:(ACUploadCallback)uploadCallback {
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:kACHTTPRequestBaseURLString]];
    
    if (params && [params count]) {
        for (NSString *key in params.allKeys) {
            [request setValue:params[key] forKey:key];
        }
    }
    
    if (fileKeys && fileValues) {
        for (NSInteger i = 0; i < MIN([fileKeys count], [fileValues count]); i++) {
            [request addFile:fileValues[i] forKey:fileKeys[i]];
        }
    }
    
    [request setCompletionBlock:^{
        if (completeCallback) {
            NSError __autoreleasing *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
            completeCallback(result, error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    [request setFailedBlock:^{
        if (completeCallback) {
            completeCallback(nil, request.error);
        }
        
        [request clearDelegatesAndCancel];
    }];
    
    [request setUploadSizeIncrementedBlock:^(long long size) {
        if (uploadCallback) {
            uploadCallback(size, request.totalBytesRead);
        }
    }];
    [request startAsynchronous];
}

+ (void)requestLoadingFinish:(ACRequestCompleteCallback)requestBlock {
    objc_setAssociatedObject(self, kACASIRequestFinishKey, requestBlock, OBJC_ASSOCIATION_COPY);
}

+ (void)queueLoadingFinish:(ACQueueCompleteCallback) queueBlock {
    
    objc_setAssociatedObject(self, kACASINetworkQueueFinishKey, queueBlock, OBJC_ASSOCIATION_COPY);
}

+ (void)appendRequestToNetworkQueueWithParams:(NSDictionary *)params
                                    URLString:(NSString *)URLString
                                       method:(NSString *)method {
    ASIHTTPRequest *request = [ACNetworking requestWithURLString:URLString
                                                          method:method
                                                          params:params];
    [networkQueue addOperation:request];
    [networkQueue go];
}

/*
 ASINetworkQueue 的delegate
 */

+ (void)requestDidFinishSelector:(ASIHTTPRequest *) request {
    ACRequestCompleteCallback callback = objc_getAssociatedObject(self, kACASIRequestFinishKey);
    if (callback) {
        NSError __autoreleasing *error = nil;
        id result = [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingAllowFragments error:&error];
        callback(request, result, error);
    }
    [request clearDelegatesAndCancel];
}

+ (void)requestDidFailSelector:(ASIHTTPRequest *) request {
    ACRequestCompleteCallback callback = objc_getAssociatedObject(self, kACASIRequestFinishKey);
    if (callback) {
        callback(request, nil, request.error);
    }
    [request clearDelegatesAndCancel];
}

+ (void)queueDidFinishSelector:(ASINetworkQueue *) queue {
    ACQueueCompleteCallback callback = objc_getAssociatedObject(self, kACASINetworkQueueFinishKey);
    if (callback) {
        callback();
    }
    
    [queue reset];
}

#endif

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
+ (void)startACAFNHTTPRequestWithParams:(NSDictionary *) params
                                 method:(NSString *) method
                               complete:(ACCompleteCallback) callback {
    
}

+ (void)startACAFNHTTPPostRequestWithParams:(NSDictionary *) params
                                   complete:(ACCompleteCallback) callback {
    
}

+ (void)startACAFNHTTPGetRequestWithParams:(NSDictionary *) params
                                  complete:(ACCompleteCallback) callback {
    
}

+ (void)startACAFNHTTPUploadWithParams:(NSDictionary *) params
                              fileKeys:(NSArray *) fileKeys
                            fileValues:(NSArray *) fileValues
                              complete:(ACCompleteCallback) completeCallback
                                upload:(ACUploadCallback) uploadCallback {
    
}

+ (void)startACAFNHTTPDownloadWithURLString:(NSString *) URLString
                                   complete:(ACCompleteCallback) completeCallback
                                   download:(ACDownloadCallback) downloadCallback {
    
}
#endif

@end
