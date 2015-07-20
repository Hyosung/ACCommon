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
#import "ACNetworkCache.h"
#import <CommonCrypto/CommonDigest.h>

@interface ACNetworking ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkConfig *config;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(ACNetworkCompletionHandler) completionBlock;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(ACNetworkCompletionHandler) completionBlock;

- (NSString *)requestMethod:(ACNetworkMethod) method;
- (NSString *)cacheKey:(NSURL *) URL;

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

- (NSString *)cacheKey:(NSURL *) URL {
    const char *str = [URL.absoluteString UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSMutableString *md5Ciphertext = [NSMutableString stringWithString:@""];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Ciphertext appendFormat:@"%02x",r[i]];
    }
    return [md5Ciphertext copy];
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

- (NSOperation *)fetchDataFromRequestContent:(ACNetworkContent *)content {
    NSAssert(content, @"content不能为nil");
    NSAssert(content.requestPath || content.requestURL, @"requestPath与requestURL只能填写其中一个");
    NSAssert(content.progressBlock || content.completionBlock, @"progressBlock与completionBlock只能填写其中一个");
    
    NSURL *URL = content.requestURL ?: [NSURL URLWithString:content.requestPath ?: @"" relativeToURL:self.manager.baseURL];
    
    NSMutableURLRequest *request = nil;
    if (content.progressBlock && content.uploadData) {
        request = [self.rs multipartFormRequestWithMethod:@"POST"
                                                URLString:URL.absoluteString
                                               parameters:content.parameters
                                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                    __weak NSArray *allKeys = content.fileInfo.allKeys;
                                    for (NSString *keyName in allKeys) {
                                        id fileURL = content.fileInfo[keyName];
                                        if ([fileURL isKindOfClass:[NSString class]]) {
                                            fileURL = [NSURL URLWithString:fileURL];
                                        }
                                        [formData appendPartWithFileURL:fileURL
                                                                   name:keyName
                                                                  error:nil];
                                    }
                                } error:nil];
    }
    else {
        request = [self.rs requestWithMethod:[self requestMethod:content.method]
                                   URLString:URL.absoluteString
                                  parameters:content.parameters
                                       error:nil];
    }
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:request
                                                                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                  NSError *error = nil;
                                                                                  id resultObject = responseObject;
                                                                                  if (content.responseJSON) {
                                                                                      
                                                                                     resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                                                                                     options:NSJSONReadingAllowFragments
                                                                                                                                       error:&error];
                                                                                  }
                                                                                  
                                                                                  if (content.progressBlock) {
                                                                                      content.progressBlock(ACNetworkProgressZero, resultObject, nil);
                                                                                  }
                                                                                  else {
                                                                                      if (content.cacheResponseData &&
                                                                                          content.method == ACNetworkMethodGET &&
                                                                                          resultObject) {
                                                                                          [[ACNetworkCache cache] setObject:resultObject forKey:[self cacheKey:URL]];
                                                                                      }
                                                                                      
                                                                                      content.completionBlock(resultObject, error);
                                                                                  }
                                                                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                  
                                                                                  if (content.progressBlock) {
                                                                                      content.progressBlock(ACNetworkProgressZero, nil, error);
                                                                                  }
                                                                                  else {
                                                                                      id resultObject = nil;
                                                                                      if (content.cacheResponseData &&
                                                                                          content.method == ACNetworkMethodGET) {
                                                                                          resultObject = [[ACNetworkCache cache] objectForKey:[self cacheKey:URL]];
                                                                                      }
                                                                                      if (resultObject) {
                                                                                          content.completionBlock(resultObject, nil);
                                                                                      }
                                                                                      else {
                                                                                          content.completionBlock(nil, error);
                                                                                      }
                                                                                  }
                                                                              }];
    
    if (content.progressBlock) {
        if (content.uploadData) {
            [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                                long long totalBytesWritten,
                                                long long totalBytesExpectedToWrite) {
                content.progressBlock(ACNetworkProgressMake(bytesWritten,
                                                            totalBytesWritten,
                                                            totalBytesExpectedToWrite), nil, nil);
            }];
        }
        else {
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                                  long long totalBytesRead,
                                                  long long totalBytesExpectedToRead) {
                content.progressBlock(ACNetworkProgressMake(bytesRead,
                                                            totalBytesRead,
                                                            totalBytesExpectedToRead), nil, nil);
            }];
        }
    }
    
    [self.manager.operationQueue addOperation:operation];
    return operation;
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
