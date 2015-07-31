//
//  ACHTTPRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACHTTPRequest.h"

@implementation ACHTTPRequest

@synthesize URL = _URL;
@synthesize path = _path;
@synthesize method = _method;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *__weak tempURL = self.URL ?: [NSURL URLWithString:self.path ?: @"" relativeToURL:operationManager.baseURL];
    self.URL = tempURL;
    return [operationManager.requestSerializer requestWithMethod:RequestMethod(self.method)
                                                       URLString:self.URL.absoluteString
                                                      parameters:self.parameters
                                                           error:nil];
}

@end

__attribute__((overloadable)) ACHTTPRequest * ACCreateRequest(NSString *path, ACRequestMethod method, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = method;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

__attribute__((overloadable)) ACHTTPRequest * ACCreateRequest(NSURL *URL, ACRequestMethod method, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.URL = URL;
    content.method = method;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

__attribute__((overloadable)) ACHTTPRequest * ACCreatePOSTRequest(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = ACRequestMethodPOST;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

__attribute__((overloadable)) ACHTTPRequest * ACCreatePOSTRequest(NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.URL = URL;
    content.method = ACRequestMethodPOST;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

__attribute__((overloadable)) ACHTTPRequest * ACCreateGETRequest(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = ACRequestMethodGET;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

__attribute__((overloadable)) ACHTTPRequest * ACCreateGETRequest(NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.URL = URL;
    content.method = ACRequestMethodGET;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}
