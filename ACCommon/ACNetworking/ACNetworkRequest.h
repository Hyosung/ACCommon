//
//  ACNetworkRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACNetworkRequestProtocol.h"

@interface ACNetworkRequest : NSObject <ACNetworkRequestProtocol>

@property BOOL responseJSON;
@property BOOL cacheResponseData;
@property ACNetworkMethod method;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) ACNetworkCompletionHandler completionBlock;

@end

UIKIT_EXTERN ACNetworkRequest * ACHTTPRequest(ACNetworkMethod method, NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkRequest * ACHTTPRequestURL(ACNetworkMethod method, NSURL *URL, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkRequest * ACPOSTRequest(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
UIKIT_EXTERN ACNetworkRequest * ACGETRequest(NSString *path, NSDictionary *parameters, ACNetworkCompletionHandler completionBlock);
