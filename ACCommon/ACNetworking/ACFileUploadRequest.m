//
//  ACFileUploadRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACFileUploadRequest.h"

@implementation ACFileUploadRequest

@synthesize URL = _URL;
@synthesize path = _path;
@synthesize method = _method;
@synthesize parameters = _parameters;
@synthesize responseType = _responseType;
@synthesize progressBlock = _progressBlock;

- (ACRequestMethod)method {
    if (_method == ACRequestMethodGET || _method == ACRequestMethodHEAD) {
        _method = ACRequestMethodPOST;
    }
    return _method;
}

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *__weak tempURL = self.URL ?: [NSURL URLWithString:self.path ?: @""
                                               relativeToURL:operationManager.baseURL];
    self.URL = tempURL;
    __weak __typeof__(self) weakSelf = self;
    return [operationManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                    URLString:self.URL.absoluteString
                                                                   parameters:self.parameters
                                                    constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                        __strong __typeof__(weakSelf) self = weakSelf;
                                                        NSArray *allKeys = self.fileInfo.allKeys;
                                                        for (NSString *keyName in allKeys) {
                                                            id fileURL = self.fileInfo[keyName];
                                                            if ([fileURL isKindOfClass:[NSString class]]) {
                                                                fileURL = [NSURL URLWithString:fileURL];
                                                            }
                                                            [formData appendPartWithFileURL:fileURL
                                                                                       name:keyName
                                                                                      error:nil];
                                                        }
                                                    } error:nil];
}

@end

__attribute__((overloadable)) ACFileUploadRequest * ACUploadRequest(NSString *path, NSDictionary *fileInfo, ACRequestProgressHandler progressBlock) {
    ACFileUploadRequest *content = [[ACFileUploadRequest alloc] init];
    content.path = path;
    content.fileInfo = fileInfo;
    content.progressBlock = progressBlock;
    return content;
}

__attribute__((overloadable)) ACFileUploadRequest * ACUploadRequest(NSURL *URL, NSDictionary *fileInfo, ACRequestProgressHandler progressBlock) {
    ACFileUploadRequest *content = [[ACFileUploadRequest alloc] init];
    content.URL = URL;
    content.fileInfo = fileInfo;
    content.progressBlock = progressBlock;
    return content;
}
