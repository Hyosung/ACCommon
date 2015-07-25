//
//  ACFileDownloadRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACRequestProgressProtocol.h"

@interface ACFileDownloadRequest : NSObject <ACRequestProgressProtocol>

@end

UIKIT_EXTERN ACFileDownloadRequest * ACDownloadRequestPath(NSString *path, ACRequestProgressHandler progressBlock);
UIKIT_EXTERN ACFileDownloadRequest * ACDownloadRequestURL(NSURL *URL, ACRequestProgressHandler progressBlock);
