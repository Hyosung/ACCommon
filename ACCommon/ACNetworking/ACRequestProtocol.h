//
//  ACRequestProtocol.h
//  ACCommon
//
//  Created by 暁星 on 15/7/22.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ACRequestProtocol <NSObject>

@property (copy) NSURL *URL;
@property (copy) NSString *path;
@property ACRequestMethod method;

- (NSMutableURLRequest *)URLRequestFormOperationManager:(AFHTTPRequestOperationManager *) operationManager;

@end
