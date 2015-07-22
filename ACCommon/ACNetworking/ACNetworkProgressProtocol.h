//
//  ACNetworkProgressProtocol.h
//  ACCommon
//
//  Created by 暁星 on 15/7/22.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACNetworkRequestProtocol.h"

@protocol ACNetworkProgressProtocol <ACNetworkRequestProtocol>

@property (nonatomic, copy) ACNetworkProgressHandler progressBlock;

@end
