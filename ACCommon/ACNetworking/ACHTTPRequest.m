//
//  ACHTTPRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACHTTPRequest.h"

@implementation ACHTTPRequest

@synthesize URL;
@synthesize path;
@synthesize method;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *tempURL = self.URL ?: [NSURL URLWithString:self.path ?: @"" relativeToURL:operationManager.baseURL];
    self.URL = tempURL;
    return [operationManager.requestSerializer requestWithMethod:RequestMethod(self.method)
                                                       URLString:URL.absoluteString
                                                      parameters:self.parameters
                                                           error:nil];
}

@end

ACHTTPRequest * ACHTTPRequestPath(ACRequestMethod method, NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = method;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACHTTPRequest * ACHTTPRequestURL(ACRequestMethod method, NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.URL = URL;
    content.method = method;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACHTTPRequest * ACPOSTRequestPath(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = ACRequestMethodPOST;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACHTTPRequest * ACGETRequestPath(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock) {
    ACHTTPRequest *content = [[ACHTTPRequest alloc] init];
    content.path = path;
    content.method = ACRequestMethodGET;
    content.parameters = parameters;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}
