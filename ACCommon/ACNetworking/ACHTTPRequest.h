//
//  ACHTTPRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACRequestProtocol.h"

@interface ACHTTPRequest : NSObject <ACRequestProtocol>

@property BOOL responseJSON;
@property BOOL cacheResponseData;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) ACRequestCompletionHandler completionBlock;

@end

UIKIT_EXTERN ACHTTPRequest * ACHTTPRequestPath(ACRequestMethod method, NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
UIKIT_EXTERN ACHTTPRequest * ACHTTPRequestURL(ACRequestMethod method, NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
UIKIT_EXTERN ACHTTPRequest * ACPOSTRequestPath(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
UIKIT_EXTERN ACHTTPRequest * ACGETRequestPath(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
