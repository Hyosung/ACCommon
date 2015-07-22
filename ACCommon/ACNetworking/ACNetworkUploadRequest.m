//
//  ACNetworkUploadRequest.m
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkUploadRequest.h"

@implementation ACNetworkUploadRequest

@synthesize requestURL;
@synthesize requestPath;
@synthesize progressBlock;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    NSURL *URL = self.requestURL ?: [NSURL URLWithString:self.requestPath ?: @"" relativeToURL:operationManager.baseURL];
    self.requestURL = URL;
    __weak __typeof__(self) weakSelf = self;
    return [operationManager.requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                    URLString:URL.absoluteString
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

ACNetworkUploadRequest * ACUploadRequestPath(NSString *path, NSDictionary *fileInfo, ACNetworkProgressHandler progressBlock) {
    ACNetworkUploadRequest *content = [[ACNetworkUploadRequest alloc] init];
    content.fileInfo = fileInfo;
    content.requestPath = path;
    content.progressBlock = progressBlock;
    return content;
}

ACNetworkUploadRequest * ACUploadRequestURL(NSURL *URL, NSDictionary *fileInfo, ACNetworkProgressHandler progressBlock) {
    ACNetworkUploadRequest *content = [[ACNetworkUploadRequest alloc] init];
    content.fileInfo = fileInfo;
    content.requestURL = URL;
    content.progressBlock = progressBlock;
    return content;
}
