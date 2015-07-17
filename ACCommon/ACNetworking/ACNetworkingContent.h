//
//  ACNetworkingContent.h
//  ACCommon
//
//  Created by 上海易凡 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkingHeader.h"

@class ACNetworkingContent;

UIKIT_EXTERN ACNetworkingContent * ACHTTPRequestContent(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkingContent * ACPOSTRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkingContent * ACGETRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkingContent * ACUploadRequestContent(NSString *path, NSDictionary *parameters, ACNetworkProgressHandler progressBlock);
UIKIT_EXTERN ACNetworkingContent * ACDownloadRequestContent(NSString *path, ACNetworkProgressHandler progressBlock);

@interface ACNetworkingContent : NSObject

@property BOOL cacheResponseData;
@property ACNetworkMethod method;
@property (nonatomic, copy) NSURL *requestURL;
@property (nonatomic, copy) NSString *requestPath;
@property (nonatomic, copy) NSDictionary *fileInfo;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) ACNetworkProgressHandler progressBlock;
@property (nonatomic, copy) ACNetworkCompletionHandler completionBlock;

@end
