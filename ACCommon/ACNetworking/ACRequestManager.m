//
//  ACRequestManager.m
//  ACCommon
//
//  Created by 曉星 on 14-5-17.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "ACRequestManager.h"

#import "ACNetworkConfiguration.h"
#import "ACCache.h"
#import <CommonCrypto/CommonDigest.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface ACRequestManager ()

@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, strong) ACNetworkConfiguration *configuration;
@property (nonatomic, weak  ) AFHTTPRequestSerializer <AFURLRequestSerialization> *rs;
@property (nonatomic, strong) NSMapTable *operations;

- (void (^)(AFHTTPRequestOperation *, id))requestSuccess:(id <ACRequestProtocol>) request;
- (void (^)(AFHTTPRequestOperation *, NSError *))requestFailure:(id <ACRequestProtocol>) request;

@end

@implementation ACRequestManager

#pragma mark - Static inline

/**
 *  @author Stoney, 15-07-31 09:07:27
 *
 *  @brief  生成请求的标识
 *
 */
ACNETWORK_STATIC_INLINE NSString * ACGenerateOperationIdentifier() {
    return [NSString stringWithFormat:@"%08x%08x", arc4random(), arc4random()];
}

ACNETWORK_STATIC_INLINE NSString * ACFileNameForURL(NSURL *URL) {
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

ACNETWORK_STATIC_INLINE NSString * ACFilePathFromURL(NSURL *URL, NSString *folderPath, NSString *extension) {
    
    assert(URL);
    assert(folderPath);
    
    NSString *pathExtension = extension ? [NSString stringWithFormat:@".%@", [extension lowercaseString]] : @"";
    NSString *fileName = [NSString stringWithFormat:@"%@%@", ACFileNameForURL(URL), pathExtension];
    NSString *filePath = [folderPath stringByAppendingPathComponent:fileName];
    return filePath;
}

ACNETWORK_STATIC_INLINE NSData * ACFileDataFromPath(NSString *path) {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    if (fileAttributes) {
        //判断文件是否过期
        NSTimeInterval timeDifference = [[NSDate date] timeIntervalSinceDate:[fileAttributes fileModificationDate]];
        if (timeDifference > [ACNetworkConfiguration defaultConfiguration].downloadExpirationTimeInterval) {
            return nil;
        }
    }
    return [[NSFileManager defaultManager] contentsAtPath:path];
}

ACNETWORK_STATIC_INLINE NSString * ACExtensionFromMIMEType(NSString *MIMEType) {
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)MIMEType, NULL);
    CFStringRef filenameExtension = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassFilenameExtension);
    CFRelease(UTI);
    if (!filenameExtension) {
        return @"";
    }
    return CFBridgingRelease(filenameExtension);
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
        self.configuration = [ACNetworkConfiguration defaultConfiguration];
        
        self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:self.configuration.baseURL];
        self.manager.requestSerializer.timeoutInterval = self.configuration.timeoutInterval;
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.rs = self.manager.requestSerializer;
        self.operations = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

#pragma mark - Request Operation

- (void)cancelAllOperations {
    [self.manager.operationQueue cancelAllOperations];
    [self.operations removeAllObjects];
}

- (void)cancelOperationWithIdentifier:(NSString *) identifier {
    if (!identifier) {
        return;
    }
    NSOperation *operation = [self.operations objectForKey:identifier];
    if (!operation) {
        return;
    }
    
    [operation cancel];
    [self.operations removeObjectForKey:identifier];
}

- (void)pauseOperationWithIdentifier:(NSString *) identifier {
    if (!identifier) {
        return;
    }
    AFHTTPRequestOperation *operation = [self.operations objectForKey:identifier];
    if (!(operation && ![operation isPaused])) {
        return;
    }
    [operation pause];
}

- (void)resumeOperationWithIdentifier:(NSString *) identifier {
    if (identifier) {
        AFHTTPRequestOperation *operation = [self.operations objectForKey:identifier];
        if (operation && [operation isPaused]) {
            [operation resume];
        }
    }
}

- (BOOL)isPausedOperationWithIdentifier:(NSString *) identifier {
    if (!identifier) {
        return NO;
    }
    
    AFHTTPRequestOperation *operation = [self.operations objectForKey:identifier];
    if (!operation) {
        return NO;
    }
    
    return [operation isPaused];
}

- (BOOL)isExecutingOperationWithIdentifier:(NSString *)identifier {
    if (!identifier) {
        return NO;
    }
    
    AFHTTPRequestOperation *operation = [self.operations objectForKey:identifier];
    if (!operation) {
        return NO;
    }
    
    return [operation isExecuting];
}

#pragma mark - Request Methods

- (NSString *)fetchDataFromRequest:(ACHTTPRequest *) request {
    NSAssert(request, @"request不能为nil");
    NSAssert(request.path || request.URL, @"path与URL只能填写其中一个");
    
    NSMutableURLRequest *URLRequest = [request URLRequestFormOperationManager:self.manager];
    
    //取本地缓存
    id resultObject = [[ACCache sharedCache] fetchDataFromDiskCacheForURL:URLRequest.URL];
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
    NSString *filePath = [[ACCache sharedCache] fetchAbsolutePathforURL:URLRequest.URL];
    NSData *fileData = ACFileDataFromPath(filePath);
    if (fileData) {
        id resultData = nil;
        if (request.responseType == ACResponseTypeFilePath) {
            resultData = filePath;
        }
        else if (request.responseType == ACResponseTypeImage) {
            resultData = [UIImage imageWithData:fileData];
        }
        else if (request.responseType == ACResponseTypeData) {
            resultData = fileData;
        }
        if (request.progressBlock) {
            request.progressBlock(ACRequestProgressZero, resultData, nil);
        }
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [self.manager HTTPRequestOperationWithRequest:URLRequest
                                                                              success:[self requestSuccess:request]
                                                                              failure:[self requestFailure:request]];
    
    filePath = ACFilePathFromURL(URLRequest.URL, [ACNetworkConfiguration defaultConfiguration].downloadFolder, nil);
    
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
    
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
            return;
        }
        
        if ([request isKindOfClass:[ACHTTPRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACHTTPRequest *)request).responseType == ACResponseTypeJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACHTTPRequest *)request).cacheResponseData &&
                ((ACHTTPRequest *)request).method == ACRequestMethodGET &&
                resultObject) {
                
                [[ACCache sharedCache] storeCacheData:resultObject forURL:request.URL];
            }
            
            if (((ACHTTPRequest *)request).completionBlock) {
                ((ACHTTPRequest *)request).completionBlock(resultObject, error);
            }
        }
        else if ([request isKindOfClass:[ACFileDownloadRequest class]]) {
            //获取后缀
            NSString *extension = ACExtensionFromMIMEType(operation.response.MIMEType);
            //下载路径
            NSString *filePath = ACFilePathFromURL(request.URL, [ACNetworkConfiguration defaultConfiguration].downloadFolder, extension);
            NSString *srcFilePath = [filePath stringByDeletingPathExtension];
            
            //删除已存在的文件以便于后面的移动操作
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            //移动
            if ([[NSFileManager defaultManager] moveItemAtPath:srcFilePath toPath:filePath error:nil]) {
                [[ACCache sharedCache] storeAbsolutePath:filePath forURL:request.URL];
            }
            
            NSData *fileData = [[NSFileManager defaultManager] contentsAtPath:filePath];
            id resultData = nil;
            if (fileData) {
                if (request.responseType == ACResponseTypeFilePath) {
                    resultData = filePath;
                }
                else if (request.responseType == ACResponseTypeImage) {
                    resultData = [UIImage imageWithData:fileData];
                }
                else if (request.responseType == ACResponseTypeData) {
                    resultData = fileData;
                }
            }
            
            if (((ACFileDownloadRequest *)request).progressBlock) {
                ((ACFileDownloadRequest *)request).progressBlock(ACRequestProgressZero, resultData, nil);
            }
        }
        else if ([request isKindOfClass:[ACFileUploadRequest class]]) {
            NSError *error = nil;
            id resultObject = responseObject;
            if (((ACFileUploadRequest *)request).responseType == ACResponseTypeJSON) {
                
                resultObject  = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&error];
            }
            
            if (((ACFileUploadRequest *)request).progressBlock) {
                ((ACFileUploadRequest *)request).progressBlock(ACRequestProgressZero, resultObject, error);
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
                    resultObject = [[ACCache sharedCache] fetchDataFromDiskCacheForURL:request.URL];
                }
                ((ACHTTPRequest *)request).completionBlock(resultObject, resultObject ? nil : error);
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

@end
