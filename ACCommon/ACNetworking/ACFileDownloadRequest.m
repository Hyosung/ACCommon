//
//  ACFileDownloadRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACFileDownloadRequest.h"

@implementation ACFileDownloadRequest

@synthesize URL;
@synthesize path;
@synthesize method;
@synthesize progressBlock;

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
    NSURL *tempURL = self.URL ?: [NSURL URLWithString:self.path ?: @"" relativeToURL:operationManager.baseURL];
    self.URL = tempURL;
    return [operationManager.requestSerializer requestWithMethod:@"GET" URLString:URL.absoluteString parameters:nil error:nil];
}

@end

ACFileDownloadRequest * ACDownloadRequestPath(NSString *path, ACRequestProgressHandler progressBlock) {
    ACFileDownloadRequest *content = [[ACFileDownloadRequest alloc] init];
    content.path = path;
    content.progressBlock = progressBlock;
    return content;
}

ACFileDownloadRequest * ACDownloadRequestURL(NSURL *URL, ACRequestProgressHandler progressBlock) {
    ACFileDownloadRequest *content = [[ACFileDownloadRequest alloc] init];
    content.URL = URL;
    content.progressBlock = progressBlock;
    return content;
}
