//
//  ACRequestManager.m
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACRequestManager.h"

#import "ACNetworkConfig.h"
#import "ACMemoryCache.h"

@interface ACRequestManager ()

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkConfig *config;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;
@property (nonatomic, strong) NSMapTable *operations;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(id <ACRequestProtocol>) request;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(id <ACRequestProtocol>) request;
#endif

@end

@implementation ACRequestManager

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__

#pragma mark - Static inline

UIKIT_STATIC_INLINE NSString * ACGenerateOperationIdentifier() {
    return [NSString stringWithFormat:@"%08x%08x", arc4random(), arc4random()];
}

#pragma mark - Lifecycle

+ (instancetype)sharedManager {
    static ACRequestManager *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[self alloc] init];
    });
    return network;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.config = [ACNetworkConfig defaultConfig];
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

- (NSString *)fetchDataFromRequest:(ACHTTPRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.path || request.URL, @"path与URL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    id resultObject = [[ACMemoryCache sharedCache] fetchCacheDataForURL:URLRequest.URL];
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
    
    NSString *operationIdentifier = ACGenerateOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)uploadFileFromRequest:(ACFileUploadRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.path || request.URL, @"path与URL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    
    if (request.progressBlock) {
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten,
                                            long long totalBytesWritten,
                                            long long totalBytesExpectedToWrite) {
            request.progressBlock(ACRequestProgressMake(bytesWritten,
                                                        totalBytesWritten,
                                                        totalBytesExpectedToWrite), nil, nil);
        }];
    }
    
    [self.manager.operationQueue addOperation:operation];
    NSString *operationIdentifier = ACGenerateOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)downloadFileFromRequest:(ACFileDownloadRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.path || request.URL, @"path与URL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    
    if (request.progressBlock) {
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead,
                                              long long totalBytesRead,
                                              long long totalBytesExpectedToRead) {
            request.progressBlock(ACRequestProgressMake(bytesRead,
                                                        totalBytesRead,
                                                        totalBytesExpectedToRead), nil, nil);
        }];
    }
    
    [self.manager.operationQueue addOperation:operation];
    NSString *operationIdentifier = ACGenerateOperationIdentifier();
    [self.operations setObject:operation forKey:operationIdentifier];
    
    return operationIdentifier;
}

- (NSString *)fetchDataFromPath:(NSString *)path
                         method:(ACRequestMethod)method
                     parameters:(NSDictionary *)parameters
                     completion:(ACRequestCompletionHandler)completionBlock {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    
    return [self fetchDataFromURLString:URL.absoluteString
                                 method:method
                             parameters:parameters
                             completion:completionBlock];
}

- (NSString *)GET_fetchDataFromPath:(NSString *)path
                         parameters:(NSDictionary *)parameters
                         completion:(ACRequestCompletionHandler)completionBlock{
    return [self fetchDataFromPath:path
                            method:ACRequestMethodGET
                        parameters:parameters
                        completion:completionBlock];
}

- (NSString *)POST_fetchDataFromPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                          completion:(ACRequestCompletionHandler)completionBlock {
    return [self fetchDataFromPath:path
                            method:ACRequestMethodPOST
                        parameters:parameters
                        completion:completionBlock];
}

- (NSString *)uploadFileFromPath:(NSString *)path
                        fileInfo:(NSDictionary *)fileInfo
                      parameters:(NSDictionary *)parameters
                        progress:(ACRequestProgressHandler)progressBlock {
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self uploadFileFromURLString:URL.absoluteString
                                fileInfo:fileInfo
                              parameters:parameters
                                progress:progressBlock];
}

- (NSString *)downloadFileFromPath:(NSString *)path
                          progress:(ACRequestProgressHandler)progressBlock{
    NSURL *URL = [NSURL URLWithString:path ?: @""
                        relativeToURL:self.manager.baseURL];
    return [self downloadFileFromURLString:URL.absoluteString
                                  progress:progressBlock];
}


- (NSString *)fetchDataFromURLString:(NSString *)URLString
                              method:(ACRequestMethod)method
                          parameters:(NSDictionary *)parameters
                          completion:(ACRequestCompletionHandler)completionBlock {
    
    ACHTTPRequest *request = ACCreateRequest([NSURL URLWithString:URLString], method, parameters, completionBlock);
    return [self fetchDataFromRequest:request];
}

- (NSString *)uploadFileFromURLString:(NSString *)URLString
                             fileInfo:(NSDictionary *)fileInfo
                           parameters:(NSDictionary *)parameters
                             progress:(ACRequestProgressHandler)progressBlock {
    ACFileUploadRequest *uploadRequest = ACUploadRequest([NSURL URLWithString:URLString], fileInfo, progressBlock);
    uploadRequest.parameters = parameters;
    return [self uploadFileFromRequest:uploadRequest];
}

- (NSString *)downloadFileFromURLString:(NSString *)URLString
                               progress:(ACRequestProgressHandler)progressBlock{
    ACFileDownloadRequest *downloadRequest = ACDownloadRequest([NSURL URLWithString:URLString], progressBlock);
    return [self downloadFileFromRequest:downloadRequest];
}

#pragma mark - Extension Methods

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(id<ACRequestProtocol>)request {
    void (^successBlock)(AFHTTPRequestOperation *, id) = ^ (AFHTTPRequestOperation *operation,
                                                            id responseObject) {
        
        if (operation.isCancelled) {
            return ;
        }
        
        if ([request isKindOfClass:[ACHTTPRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACHTTPRequest *)request).responseJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACHTTPRequest *)request).cacheResponseData &&
                ((ACHTTPRequest *)request).method == ACRequestMethodGET &&
                resultObject) {
                
                [[ACMemoryCache sharedCache] storeCacheData:resultObject forURL:request.URL];
            }
            
            if (((ACHTTPRequest *)request).completionBlock) {
                ((ACHTTPRequest *)request).completionBlock(resultObject, error);
            }
        }
        else if ([request isKindOfClass:[ACFileDownloadRequest class]]) {
            if (((ACFileDownloadRequest *)request).progressBlock) {
                ((ACFileDownloadRequest *)request).progressBlock(ACRequestProgressZero, responseObject, nil);
            }
        }
        else if ([request isKindOfClass:[ACFileUploadRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACFileUploadRequest *)request).responseJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACFileUploadRequest *)request).progressBlock) {
                ((ACFileUploadRequest *)request).progressBlock(ACRequestProgressZero, resultObject, nil);
            }
        }
    };
    return successBlock;
}

- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(id<ACRequestProtocol>)request {
    void (^failureBlock)(AFHTTPRequestOperation *, NSError *) = ^ (AFHTTPRequestOperation *operation,
                                                                   NSError *error) {
        
        if (operation.isCancelled) {
            return ;
        }
        
        if ([request isKindOfClass:[ACHTTPRequest class]]) {
            if (((ACHTTPRequest *)request).completionBlock) {
                
                id resultObject = nil;
                if (((ACHTTPRequest *)request).cacheResponseData &&
                    ((ACHTTPRequest *)request).method == ACRequestMethodGET) {
                    resultObject = [[ACMemoryCache sharedCache] fetchCacheDataForURL:request.URL];
                }
                if (resultObject) {
                    ((ACHTTPRequest *)request).completionBlock(resultObject, nil);
                }
                else {
                    ((ACHTTPRequest *)request).completionBlock(nil, error);
                }
            }
        }
        else if ([request isKindOfClass:[ACFileDownloadRequest class]] ||
                 [request isKindOfClass:[ACFileUploadRequest class]]) {
            if (((id <ACRequestProgressProtocol>)request).progressBlock) {
                ((id <ACRequestProgressProtocol>)request).progressBlock(ACRequestProgressZero, nil, error);
            }
        }
    };
    return failureBlock;
}

#endif

@end
