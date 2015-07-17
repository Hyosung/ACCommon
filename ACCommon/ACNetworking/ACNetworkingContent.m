//
//  ACNetworkingContent.m
//  ACCommon
//
//  Created by 上海易凡 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkingContent.h"

ACNetworkingContent * ACHTTPRequestContent(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkingContent *content = [[ACNetworkingContent alloc] init];
    content.method = method;
    content.requestPath = path;
    content.parameters = parameters;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkingContent * ACPOSTRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkingContent *content = [[ACNetworkingContent alloc] init];
    content.method = ACNetworkMethodPOST;
    content.requestPath = path;
    content.parameters = parameters;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkingContent * ACGETRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkingContent *content = [[ACNetworkingContent alloc] init];
    content.method = ACNetworkMethodGET;
    content.requestPath = path;
    content.parameters = parameters;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkingContent * ACUploadRequestContent(NSString *path, NSDictionary *parameters, ACNetworkProgressHandler progressBlock) {
    ACNetworkingContent *content = [[ACNetworkingContent alloc] init];
    content.method = ACNetworkMethodPOST;
    content.requestPath = path;
    content.parameters = parameters;
    content.progressBlock = progressBlock;
    return content;
}

ACNetworkingContent * ACDownloadRequestContent(NSString *path, ACNetworkProgressHandler progressBlock) {
    ACNetworkingContent *content = [[ACNetworkingContent alloc] init];
    content.method = ACNetworkMethodGET;
    content.requestPath = path;
    content.progressBlock = progressBlock;
    return content;
}

@implementation ACNetworkingContent

@end
