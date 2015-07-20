//
//  ACNetworkContent.h
//  ACCommon
//
//  Created by 上海易凡 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"

@class ACNetworkContent;

UIKIT_EXTERN ACNetworkContent * ACHTTPRequestContent(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkContent * ACPOSTRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkContent * ACGETRequestContent(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkContent * ACUploadRequestContent(NSString *path, NSDictionary *parameters, ACNetworkProgressHandler progressBlock);
UIKIT_EXTERN ACNetworkContent * ACDownloadRequestContent(NSString *path, ACNetworkProgressHandler progressBlock);

@interface ACNetworkContent : NSObject

@property BOOL uploadData;
@property BOOL responseJSON;
@property BOOL cacheResponseData;
@property ACNetworkMethod method;
@property (nonatomic, copy) NSURL *requestURL;
@property (nonatomic, copy) NSString *requestPath;
@property (nonatomic, copy) NSDictionary *fileInfo;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) ACNetworkProgressHandler progressBlock;
@property (nonatomic, copy) ACNetworkCompletionHandler completionBlock;

@end
