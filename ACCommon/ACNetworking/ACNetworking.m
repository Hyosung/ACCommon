//
//  ACNetworking.m
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACNetworking.h"

#import "AFNetworking.h"
#import "ACNetworkConfig.h"

@interface ACNetworking ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkConfig *config;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(ACCompletedCallback) callback;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(ACCompletedCallback) callback;

- (NSString *)requestMethod:(ACNetworkMethod) method;

@end

@implementation ACNetworking

+ (instancetype)network {
    static ACNetworking *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    return network;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.config = [ACNetworkConfig config];
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.config.baseURL];
        self.manager.requestSerializer.timeoutInterval = self.config.timeoutInterval;
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.rs = self.manager.requestSerializer;
    }
    return self;
}

- (NSString *)requestMethod:(ACNetworkMethod) method {
    static dispatch_once_t onceToken;
    static NSDictionary *methods = nil;
    dispatch_once(&onceToken, ^{
       methods = @{
                   @(ACNetworkMethodGET)   : @"GET",
                   @(ACNetworkMethodPUT)   : @"PUT",
                   @(ACNetworkMethodHEAD)  : @"HEAD",
                   @(ACNetworkMethodPOST)  : @"POST",
                   @(ACNetworkMethodPATCH) : @"PATCH",
                   @(ACNetworkMethodDELETE): @"DELETE"
                   };
    });
    return methods[@(method)];
}

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(ACCompletedCallback) callback {
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^ (AFHTTPRequestOperation *operation,
                                                            id responseObject) {
        NSError *error = nil;
        
        id resultObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
        if (callback != NULL) {
            callback(resultObject, error);
        }
    };
    return successBlock;
}

- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(ACCompletedCallback) callback {
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^ (AFHTTPRequestOperation *operation,
                                                                   NSError *error) {
        if (callback != NULL) {
            callback(nil, error);
        }
    };
    return failureBlock;
}

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

- (NSOperation *)fetchDataFromPath:(NSString *) path
                            method:(ACNetworkMethod) method
                        parameters:(NSDictionary *) parameters
                         completed:(ACCompletedCallback) callback {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    
    return [self fetchDataFromURLString:URL.absoluteString
                                 method:method
                             parameters:parameters
                              completed:callback];
}

- (NSOperation *)GET_fetchDataFromPath:(NSString *) path
                            parameters:(NSDictionary *) parameters
                             completed:(ACCompletedCallback) callback {
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodGET
                        parameters:parameters
                         completed:callback];
}

- (NSOperation *)POST_fetchDataFromPath:(NSString *) path
                             parameters:(NSDictionary *) parameters
                              completed:(ACCompletedCallback) callback {
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodPOST
                        parameters:parameters
                         completed:callback];
}

- (NSOperation *)uploadFileFromPath:(NSString *) path
                         parameters:(NSDictionary *) parameters
                           fileInfo:(NSDictionary *) fileInfo
                          completed:(ACCompletedCallback) completedCallback
                             upload:(ACUploadCallback) uploadCallback {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self uploadFileFromURLString:URL.absoluteString
                              parameters:parameters
                                fileInfo:fileInfo
                               completed:completedCallback
                                  upload:uploadCallback];
}

- (NSOperation *)downloadFileFromPath:(NSString *) path
                           parameters:(NSDictionary *) parameters
                            completed:(ACCompletedCallback) completedCallback
                             download:(ACDownloadCallback) downloadCallback {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self downloadFileFromURLString:URL.absoluteString
                                parameters:parameters
                                 completed:completedCallback
                                  download:downloadCallback];
}


- (NSOperation *)fetchDataFromURLString:(NSString *) URLString
                                 method:(ACNetworkMethod) method
                             parameters:(NSDictionary *) parameters
                              completed:(ACCompletedCallback) callback {
    
    NSMutableURLRequest *request = [self.rs requestWithMethod:[self requestMethod:method]
                                                    URLString:URLString
                                                   parameters:parameters
                                                        error:nil];
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self requestSuccess:callback]
                                                                              failure:[self requestFailure:callback]];
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)uploadFileFromURLString:(NSString *) URLString
                              parameters:(NSDictionary *) parameters
                                fileInfo:(NSDictionary *) fileInfo
                               completed:(ACCompletedCallback) completedCallback
                                  upload:(ACUploadCallback) uploadCallback {
    NSMutableURLRequest *request = [self.rs multipartFormRequestWithMethod:@"POST"
                                                                 URLString:URLString
                                                                parameters:parameters
                                                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                     __weak NSArray *allKeys = fileInfo.allKeys;
                                                     for (NSString *keyName in allKeys) {
                                                         id fileURL = fileInfo[keyName];
                                                         if ([fileURL isKindOfClass:[NSString class]]) {
                                                             fileURL = [NSURL URLWithString:fileURL];
                                                         }
                                                         [formData appendPartWithFileURL:fileURL
                                                                                    name:keyName
                                                                                   error:nil];
                                                     }
                                                 }
                                                                     error:nil];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self requestSuccess:completedCallback]
                                                                              failure:[self requestFailure:completedCallback]];
    [operation setUploadProgressBlock:uploadCallback];
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)downloadFileFromURLString:(NSString *) URLString
                                parameters:(NSDictionary *) parameters
                                 completed:(ACCompletedCallback) completedCallback
                                  download:(ACDownloadCallback) downloadCallback {
    NSMutableURLRequest *request = [self.rs requestWithMethod:@"GET"
                                                    URLString:URLString
                                                   parameters:parameters
                                                        error:nil];
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self requestSuccess:completedCallback]
                                                                              failure:[self requestFailure:completedCallback]];
    
    [operation setDownloadProgressBlock:downloadCallback];
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
}
#endif

@end
