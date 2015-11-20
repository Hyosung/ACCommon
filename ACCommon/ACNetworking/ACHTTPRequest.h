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

/**
 *  @author Stoney, 15-07-31 09:07:31
 *
 *  @brief  是否缓存响应的数据
 */
@property BOOL cacheResponseData;
@property (nonatomic, copy) NSDictionary *parameters;
@property (nonatomic, copy) ACRequestCompletionHandler completionBlock;

@end

extern __attribute__((overloadable)) ACHTTPRequest * ACCreateRequest(NSString *path, ACRequestMethod method, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
extern __attribute__((overloadable)) ACHTTPRequest * ACCreateRequest(NSURL *URL, ACRequestMethod method, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);

extern __attribute__((overloadable)) ACHTTPRequest * ACCreatePOSTRequest(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
extern __attribute__((overloadable)) ACHTTPRequest * ACCreatePOSTRequest(NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);

extern __attribute__((overloadable)) ACHTTPRequest * ACCreateGETRequest(NSString *path, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
extern __attribute__((overloadable)) ACHTTPRequest * ACCreateGETRequest(NSURL *URL, NSDictionary *parameters, ACRequestCompletionHandler completionBlock);
