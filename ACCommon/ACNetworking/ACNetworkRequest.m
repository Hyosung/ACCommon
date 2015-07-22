//
//  ACNetworkRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkRequest.h"

@implementation ACNetworkRequest

@synthesize requestURL;
@synthesize requestPath;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *URL = self.requestURL ?: [NSURL URLWithString:self.requestPath ?: @"" relativeToURL:operationManager.baseURL];
    self.requestURL = URL;
    return [operationManager.requestSerializer requestWithMethod:RequestMethod(self.method)
                                                       URLString:URL.absoluteString
                                                      parameters:self.parameters
                                                           error:nil];
}

@end

ACNetworkRequest * ACHTTPRequest(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkRequest *content = [[ACNetworkRequest alloc] init];
    content.method = method;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkRequest * ACHTTPRequestURL(ACNetworkMethod method, NSURL *URL, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkRequest *content = [[ACNetworkRequest alloc] init];
    content.method = method;
    content.parameters = parameters;
    content.requestURL = URL;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkRequest * ACPOSTRequest(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkRequest *content = [[ACNetworkRequest alloc] init];
    content.method = ACNetworkMethodPOST;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkRequest * ACGETRequest(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkRequest *content = [[ACNetworkRequest alloc] init];
    content.method = ACNetworkMethodGET;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}
