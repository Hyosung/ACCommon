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

@interface ACNetworking ()

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkConfig *config;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;
@property (nonatomic, strong) NSMapTable *operations;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(id <ACNetworkRequestProtocol>) request;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(id <ACNetworkRequestProtocol>) request;
#endif

@end

@implementation ACNetworking

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

#pragma mark - Static inline

UIKIT_STATIC_INLINE NSString * ACOperationIdentifier() {
    return [NSString stringWithFormat:@"%08x%08x", arc4random(), arc4random()];
}

#pragma mark - Lifecycle

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
        self.operations = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

#pragma mark - Request Operation

- (void)cancelAllOperations {
    [self.operations removeAllObjects];
    [self.manager.operationQueue cancelAllOperations];
}

- (void)cancelOperationWithIdentifier:(NSString *) identifier {
    NSOperation *operation = [self.operations objectForKey:identifier];
    if (operation) {
        [operation cancel];
        [self.operations removeObjectForKey:identifier];
    }
}

#pragma mark - Request Methods

- (NSString *)fetchDataFromRequest:(ACNetworkRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.requestPath || request.requestURL, @"requestPath与requestURL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    id resultObject = [[ACNetworkCache cache] fetchCacheDataForURL:URLRequest.URL];
    if (resultObject) {
        if (request.completionBlock) {
            request.completionBlock(resultObject, nil);
        }
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    [self.manager.operationQueue addOperation:operation];
    
    NSString *operationIdentifier = ACOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)uploadFileFromRequest:(ACNetworkUploadRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.requestPath || request.requestURL, @"requestPath与requestURL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    
    if (request.progressBlock) {
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                            long long totalBytesWritten,
                                            long long totalBytesExpectedToWrite) {
            request.progressBlock(ACNetworkProgressMake(bytesWritten,
                                                        totalBytesWritten,
                                                        totalBytesExpectedToWrite), nil, nil);
        }];
    }
    
    [self.manager.operationQueue addOperation:operation];
    NSString *operationIdentifier = ACOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)downloadFileFromRequest:(ACNetworkDownloadRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.requestPath || request.requestURL, @"requestPath与requestURL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    
    if (request.progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                              long long totalBytesRead,
                                              long long totalBytesExpectedToRead) {
            request.progressBlock(ACNetworkProgressMake(bytesRead,
                                                        totalBytesRead,
                                                        totalBytesExpectedToRead), nil, nil);
        }];
    }
    
    [self.manager.operationQueue addOperation:operation];
    NSString *operationIdentifier = ACOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)fetchDataFromPath:(NSString *)path
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

- (NSString *)GET_fetchDataFromPath:(NSString *)path
                         parameters:(NSDictionary *)parameters
                         completion:(ACNetworkCompletionHandler)completionBlock{
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodGET
                        parameters:parameters
                        completion:completionBlock];
}

- (NSString *)POST_fetchDataFromPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                          completion:(ACNetworkCompletionHandler)completionBlock {
    return [self fetchDataFromPath:path
                            method:ACNetworkMethodPOST
                        parameters:parameters
                        completion:completionBlock];
}

- (NSString *)uploadFileFromPath:(NSString *)path
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

- (NSString *)downloadFileFromPath:(NSString *)path
                          progress:(ACNetworkProgressHandler)progressBlock{
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self downloadFileFromURLString:URL.absoluteString
                                  progress:progressBlock];
}


- (NSString *)fetchDataFromURLString:(NSString *)URLString
                              method:(ACNetworkMethod)method
                          parameters:(NSDictionary *)parameters
                          completion:(ACNetworkCompletionHandler)completionBlock {
    
    ACNetworkRequest *request = ACHTTPRequestURL(method, [NSURL URLWithString:URLString], parameters, completionBlock);
    return [self fetchDataFromRequest:request];
}

- (NSString *)uploadFileFromURLString:(NSString *)URLString
                             fileInfo:(NSDictionary *)fileInfo
                           parameters:(NSDictionary *)parameters
                             progress:(ACNetworkProgressHandler)progressBlock {
    ACNetworkUploadRequest *uploadRequest = ACUploadRequestURL([NSURL URLWithString:URLString], fileInfo, progressBlock);
    uploadRequest.parameters = parameters;
    return [self uploadFileFromRequest:uploadRequest];
}

- (NSString *)downloadFileFromURLString:(NSString *)URLString
                               progress:(ACNetworkProgressHandler)progressBlock{
    ACNetworkDownloadRequest *downloadRequest = ACDownloadRequestURL([NSURL URLWithString:URLString], progressBlock);
    return [self downloadFileFromRequest:downloadRequest];
}

#pragma mark - Extension Methods

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(id<ACNetworkRequestProtocol>)request {
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^ (AFHTTPRequestOperation *operation,
                                                            id responseObject) {
        
        if (operation.isCancelled) {
            return ;
        }
        
        if ([request isKindOfClass:[ACNetworkRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACNetworkRequest *)request).responseJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACNetworkRequest *)request).cacheResponseData &&
                ((ACNetworkRequest *)request).method == ACNetworkMethodGET &&
                resultObject) {
                
                [[ACNetworkCache cache] storeCacheData:resultObject forURL:request.requestURL];
            }
            
            if (((ACNetworkRequest *)request).completionBlock) {
                ((ACNetworkRequest *)request).completionBlock(resultObject, error);
            }
        }
        else if ([request isKindOfClass:[ACNetworkDownloadRequest class]]) {
            if (((ACNetworkDownloadRequest *)request).progressBlock) {
                ((ACNetworkDownloadRequest *)request).progressBlock(ACNetworkProgressZero, responseObject, nil);
            }
        }
        else if ([request isKindOfClass:[ACNetworkUploadRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACNetworkUploadRequest *)request).responseJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACNetworkUploadRequest *)request).progressBlock) {
                ((ACNetworkUploadRequest *)request).progressBlock(ACNetworkProgressZero, resultObject, nil);
            }
        }
    };
    return successBlock;
}

- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(id<ACNetworkRequestProtocol>)request {
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^ (AFHTTPRequestOperation *operation,
                                                                   NSError *error) {
        
        if (operation.isCancelled) {
            return ;
        }
        
        if ([request isKindOfClass:[ACNetworkRequest class]]) {
            if (((ACNetworkRequest *)request).completionBlock) {
                
                id resultObject = nil;
                if (((ACNetworkRequest *)request).cacheResponseData &&
                    ((ACNetworkRequest *)request).method == ACNetworkMethodGET) {
                    resultObject = [[ACNetworkCache cache] fetchCacheDataForURL:request.requestURL];
                }
                if (resultObject) {
                    ((ACNetworkRequest *)request).completionBlock(resultObject, nil);
                }
                else {
                    ((ACNetworkRequest *)request).completionBlock(nil, error);
                }
            }
        }
        else if ([request isKindOfClass:[ACNetworkDownloadRequest class]] ||
                 [request isKindOfClass:[ACNetworkUploadRequest class]]) {
            if (((id <ACNetworkProgressProtocol>)request).progressBlock) {
                ((id <ACNetworkProgressProtocol>)request).progressBlock(ACNetworkProgressZero, nil, error);
            }
        }
    };
    return failureBlock;
}

#endif

@end
