//
//  ACNetworking.m
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACNetworking.h"

#import "AFNetworking.h"
#import "ACNetworkingConfig.h"

@interface ACNetworking ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkingConfig *config;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(ACNetworkCompletionHandler) completionBlock;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(ACNetworkCompletionHandler) completionBlock;

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
        self.config = [ACNetworkingConfig config];
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

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(ACNetworkCompletionHandler) completionBlock {
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^ (AFHTTPRequestOperation *operation,
                                                            id responseObject) {
        NSError *error = nil;
        
        id resultObject = [NSJSONSerialization JSONObjectWithData:responseObject
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
        if (completionBlock != NULL) {
            completionBlock(resultObject, error);
        }
    };
    return successBlock;
}

- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(ACNetworkCompletionHandler) completionBlock {
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^ (AFHTTPRequestOperation *operation,
                                                                   NSError *error) {
        if (completionBlock != NULL) {
            completionBlock(nil, error);
        }
    };
    return failureBlock;
}

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

- (NSOperation *)fetchDataFromRequestContent:(ACNetworkingContent *)content {
    NSURL *URL = [NSURL URLWithString:content.requestPath ?: @""
                        relativeToURL:self.manager.baseURL];
    
    return [self fetchDataFromURLString:URL.absoluteString
                                 method:content.method
                             parameters:content.parameters
                             completion:content.completionBlock];
}

- (NSOperation *)fetchDataFromPath:(NSString *)path
                            method:(ACNetworkMethod)method
                        parameters:(NSDictionary *)parameters
                        completion:(ACNetworkCompletionHandler)completionBlock {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    
    return [self fetchDataFromURLString:URL.absoluteString
                                 method:method
                             parameters:parameters
                             completion:completionBlock];
}

- (NSOperation *)GET_fetchDataFromPath:(NSString *)path
                            parameters:(NSDictionary *)parameters
                            completion:(ACNetworkCompletionHandler)completionBlock{
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodGET
                        parameters:parameters
                        completion:completionBlock];
}

- (NSOperation *)POST_fetchDataFromPath:(NSString *)path
                             parameters:(NSDictionary *)parameters
                             completion:(ACNetworkCompletionHandler)completionBlock {
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodPOST
                        parameters:parameters
                        completion:completionBlock];
}

- (NSOperation *)uploadFileFromPath:(NSString *)path
                           fileInfo:(NSDictionary *)fileInfo
                         parameters:(NSDictionary *)parameters
                           progress:(ACNetworkProgressHandler)progressBlock {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self uploadFileFromURLString:URL.absoluteString
                                fileInfo:fileInfo
                              parameters:parameters
                                progress:progressBlock];
}

- (NSOperation *)downloadFileFromPath:(NSString *)path
                             progress:(ACNetworkProgressHandler)progressBlock{
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self downloadFileFromURLString:URL.absoluteString
                                  progress:progressBlock];
}


- (NSOperation *)fetchDataFromURLString:(NSString *)URLString
                                 method:(ACNetworkMethod)method
                             parameters:(NSDictionary *)parameters
                             completion:(ACNetworkCompletionHandler)completionBlock {
    
    NSMutableURLRequest *request = [self.rs requestWithMethod:[self requestMethod:method]
                                                    URLString:URLString
                                                   parameters:parameters
                                                        error:nil];
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:[self requestSuccess:completionBlock]
                                                                              failure:[self requestFailure:completionBlock]];
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)uploadFileFromURLString:(NSString *)URLString
                                fileInfo:(NSDictionary *)fileInfo
                              parameters:(NSDictionary *)parameters
                                progress:(ACNetworkProgressHandler)progressBlock {
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
                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                  if (progressBlock != NULL) {
                                                                                      progressBlock(ACNetworkProgressZero, responseObject, nil);
                                                                                  }
                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  if (progressBlock != NULL) {
                                                                                      progressBlock(ACNetworkProgressZero, nil, error);
                                                                                  }
                                                                              }];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                        long long totalBytesWritten,
                                        long long totalBytesExpectedToWrite) {
        if (progressBlock != NULL) {
            progressBlock(ACNetworkProgressMake(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite), nil, nil);
        }
    }];
    [self.manager.operationQueue addOperation:operation];
    return operation;
}

- (NSOperation *)downloadFileFromURLString:(NSString *)URLString
                                  progress:(ACNetworkProgressHandler)progressBlock{
    NSMutableURLRequest *request = [self.rs requestWithMethod:@"GET"
                                                    URLString:URLString
                                                   parameters:nil
                                                        error:nil];
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                  if (progressBlock != NULL) {
                                                                                      progressBlock(ACNetworkProgressZero, responseObject, nil);
                                                                                  }
                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  if (progressBlock != NULL) {
                                                                                      progressBlock(ACNetworkProgressZero, nil, error);
                                                                                  }
                                                                              }];
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                          long long totalBytesRead,
                                          long long totalBytesExpectedToRead) {
        if (progressBlock != NULL) {
            progressBlock(ACNetworkProgressMake(bytesRead, totalBytesRead, totalBytesExpectedToRead), nil, nil);
        }
    }];
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
}
#endif

@end
