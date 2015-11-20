//
//  ACFileDownloadRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACFileDownloadRequest.h"

@implementation ACFileDownloadRequest

@synthesize URL = _URL;
@synthesize path = _path;
@synthesize method = _method;
@synthesize parameters = _parameters;
@synthesize responseType = _responseType;
@synthesize progressBlock = _progressBlock;

/**
 *  @author Stoney, 15-07-25 14:07:17
 *
 *  @brief  限死请求方式
 *
 */
- (ACRequestMethod)method {
    return ACRequestMethodGET;
}

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *__weak tempURL = self.URL ?: [NSURL URLWithString:self.path ?: @""
                                               relativeToURL:operationManager.baseURL];
    self.URL = tempURL;
    return [operationManager.requestSerializer requestWithMethod:@"GET"
                                                       URLString:_URL.absoluteString
                                                      parameters:self.parameters
                                                           error:nil];
}
@end

__attribute__((overloadable)) ACFileDownloadRequest * ACDownloadRequest(NSString *path, ACRequestProgressHandler progressBlock) {
    ACFileDownloadRequest *content = [[ACFileDownloadRequest alloc] init];
    content.path = path;
    content.responseType = ACResponseTypeFilePath;
    content.progressBlock = progressBlock;
    return content;
}

__attribute__((overloadable)) ACFileDownloadRequest * ACDownloadRequest(NSURL *URL, ACRequestProgressHandler progressBlock) {
    ACFileDownloadRequest *content = [[ACFileDownloadRequest alloc] init];
    content.URL = URL;
    content.responseType = ACResponseTypeFilePath;
    content.progressBlock = progressBlock;
    return content;
}
