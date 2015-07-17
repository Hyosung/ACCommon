//
//  NSData+ACAdditions.m
//  ACCommon
//
//  Created by 曉星 on 14-5-2.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSData+ACAdditions.h"

#import <CommonCrypto/CommonCryptor.h>
#import "GTMBase64.h"

@implementation NSData (ACAdditions)

#pragma mark - AES256

- (NSData *)AES256Encrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
        free(buffer);
        return data;
    }
    free(buffer);
    return nil;
}

- (NSData *)AES256Decrypt:(NSString *)key {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          NULL,
                                          [self bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        free(buffer);
        return data;
    }
    free(buffer);
    return nil;
}

#pragma mark - Base64

- (NSString*)encodeBase64 {
    NSData *data = [GTMBase64 encodeData:self];
    NSString *__autoreleasing base64String = [[NSString alloc] initWithData:data
                                                                   encoding:NSUTF8StringEncoding];
    return base64String;
}

- (NSString*)decodeBase64 {
    NSData *data = [GTMBase64 decodeData:self];
    NSString *__autoreleasing base64String = [[NSString alloc] initWithData:data
                                                                   encoding:NSUTF8StringEncoding];
    return base64String;
}


#pragma mark - JSON

- (id)JSON {
    return [NSJSONSerialization JSONObjectWithData:self
                                           options:NSJSONReadingAllowFragments
                                             error:nil];
}

- (id)JSON:(NSError *__autoreleasing *)error {
    id result = [NSJSONSerialization JSONObjectWithData:self
                                                options:NSJSONReadingAllowFragments
                                                  error:error];
    return result;
}

@end
