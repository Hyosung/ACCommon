//
//  ACNetworkRequestProtocol.h
//  ACCommon
//
//  Created by 暁星 on 15/7/22.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACNetworkRequestProtocol <NSObject>

@property (nonatomic, copy) NSURL *requestURL;
@property (nonatomic, copy) NSString *requestPath;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *) operationManager;

@end
