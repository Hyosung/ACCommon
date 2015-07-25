//
//  ACFileUploadRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACRequestProgressProtocol.h"

@interface ACFileUploadRequest : NSObject <ACRequestProgressProtocol>

@property BOOL responseJSON;
@property (nonatomic, copy) NSDictionary *fileInfo;
@property (nonatomic, copy) NSDictionary *parameters;

@end

UIKIT_EXTERN ACFileUploadRequest * ACUploadRequestPath(NSString *path, NSDictionary *fileInfo, ACRequestProgressHandler progressBlock);
UIKIT_EXTERN ACFileUploadRequest * ACUploadRequestURL(NSURL *URL, NSDictionary *fileInfo, ACRequestProgressHandler progressBlock);
