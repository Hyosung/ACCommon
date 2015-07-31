//
//  ACRequestProgressProtocol.h
//  ACCommon
//
//  Created by 暁星 on 15/7/22.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ACRequestProtocol.h"

@protocol ACRequestProgressProtocol <ACRequestProtocol>

@property (nonatomic, copy) ACRequestProgressHandler progressBlock;
@property (nonatomic, copy) NSDictionary *parameters;

@end
