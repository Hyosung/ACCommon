//
//  ACNetworkUploadRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACNetworkProgressProtocol.h"

@interface ACNetworkUploadRequest : NSObject <ACNetworkProgressProtocol>

@property BOOL responseJSON;
@property (nonatomic, copy) NSDictionary *fileInfo;
@property (nonatomic, copy) NSDictionary *parameters;

@end

UIKIT_EXTERN ACNetworkUploadRequest * ACUploadRequestPath(NSString *path, NSDictionary *fileInfo, ACNetworkProgressHandler progressBlock);
UIKIT_EXTERN ACNetworkUploadRequest * ACUploadRequestURL(NSURL *URL, NSDictionary *fileInfo, ACNetworkProgressHandler progressBlock);
