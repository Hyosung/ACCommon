//
//  ACNetworkDownloadRequest.h
//  ACCommon
//
//  Created by 暁星 on 15/7/21.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkHeader.h"
#import "ACNetworkProgressProtocol.h"

@interface ACNetworkDownloadRequest : NSObject <ACNetworkProgressProtocol>

@end

UIKIT_EXTERN ACNetworkDownloadRequest * ACDownloadRequestPath(NSString *path, ACNetworkProgressHandler progressBlock);
UIKIT_EXTERN ACNetworkDownloadRequest * ACDownloadRequestURL(NSURL *URL, ACNetworkProgressHandler progressBlock);
