//
//  NSData+ACAdditions.h
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (ACAdditions)

#pragma mark - AES256

/*
 AES256加密
 */
- (NSData *)AES256Encrypt:(NSString *) key;

/*
 AES256解密
 */
- (NSData *)AES256Decrypt:(NSString *) key;

#pragma mark - Base64

/*
 Base64加密
 */
- (NSString*)encodeBase64;

/*
 Base64解密
 */
- (NSString*)decodeBase64;
@end
