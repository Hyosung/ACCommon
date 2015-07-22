//
//  ACNetworkDownloadRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkDownloadRequest.h"

@implementation ACNetworkDownloadRequest

@synthesize requestURL;
@synthesize requestPath;
@synthesize progressBlock;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *URL = self.requestURL ?: [NSURL URLWithString:self.requestPath ?: @"" relativeToURL:operationManager.baseURL];
    self.requestURL = URL;
    return [operationManager.requestSerializer requestWithMethod:@"GET" URLString:URL.absoluteString parameters:nil error:nil];
}

@end

ACNetworkDownloadRequest * ACDownloadRequestPath(NSString *path, ACNetworkProgressHandler progressBlock) {
    ACNetworkDownloadRequest *content = [[ACNetworkDownloadRequest alloc] init];
    content.requestPath = path;
    content.progressBlock = progressBlock;
    return content;
}

ACNetworkDownloadRequest * ACDownloadRequestURL(NSURL *URL, ACNetworkProgressHandler progressBlock) {
    ACNetworkDownloadRequest *content = [[ACNetworkDownloadRequest alloc] init];
    content.requestURL = URL;
    content.progressBlock = progressBlock;
    return content;
}
