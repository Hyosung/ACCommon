//
//  ACNetworkContent.m
//  ACCommon
//
//  Created by 上海易凡 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkContent.h"

ACNetworkContent * ACHTTPRequestContent(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkContent *content = [[ACNetworkContent alloc] init];
    content.method = method;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkContent * ACPOSTRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkContent *content = [[ACNetworkContent alloc] init];
    content.method = ACNetworkMethodPOST;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkContent * ACGETRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock) {
    ACNetworkContent *content = [[ACNetworkContent alloc] init];
    content.method = ACNetworkMethodGET;
    content.parameters = parameters;
    content.requestPath = path;
    content.responseJSON = YES;
    content.completionBlock = completionBlock;
    return content;
}

ACNetworkContent * ACUploadRequestContent(NSString *path, NSDictionary *parameters, ACNetworkProgressHandler progressBlock) {
    ACNetworkContent *content = [[ACNetworkContent alloc] init];
    content.method = ACNetworkMethodPOST;
    content.uploadData = YES;
    content.requestPath = path;
    content.parameters = parameters;
    content.progressBlock = progressBlock;
    return content;
}

ACNetworkContent * ACDownloadRequestContent(NSString *path, ACNetworkProgressHandler progressBlock) {
    ACNetworkContent *content = [[ACNetworkContent alloc] init];
    content.method = ACNetworkMethodGET;
    content.uploadData = NO;
    content.requestPath = path;
    content.progressBlock = progressBlock;
    return content;
}

@implementation ACNetworkContent

@end
