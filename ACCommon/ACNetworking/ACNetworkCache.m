//
//  ACNetworkCache.m
//  ACCommon
//
//  Created by 暁星 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkCache.h"
#import "ACNetworkConfig.h"
#import <CommonCrypto/CommonDigest.h>

@implementation ACNetworkCacheObject

- (instancetype)initWithContent:(id) content {
    self = [super init];
    if (self) {
        _content = content;
        _lastUpdateTimestamp = [NSDate date].timeIntervalSince1970;
    }
    return self;
}

- (void)updateContent:(id) content {
    _content = content;
    _lastUpdateTimestamp = [NSDate date].timeIntervalSince1970;
}

- (BOOL)isExpiration {
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    NSTimeInterval timeInterval = currentTimestamp - _lastUpdateTimestamp;
    return (timeInterval > [ACNetworkConfig config].cacheExpirationTimeInterval);
}

@end

@implementation ACNetworkCache

UIKIT_STATIC_INLINE NSString * ACCacheKeyForURL(NSURL *URL) {
    const char *str = [URL.absoluteString UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSMutableString *md5Ciphertext = [NSMutableString stringWithString:@""];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5Ciphertext appendFormat:@"%02x",r[i]];
    }
    return [md5Ciphertext copy];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllObjects)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

+ (instancetype)cache {
    static dispatch_once_t onceToken;
    static ACNetworkCache *networkCache = nil;
    dispatch_once(&onceToken, ^{
        networkCache = [[self alloc] init];
    });
    return networkCache;
}

- (id)objectForURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    
    return [self objectForKey:ACCacheKeyForURL(URL)];
}

- (void)setObject:(id)obj forURL:(NSURL *)URL {
    if (obj && URL) {
        [self setObject:obj forKey:ACCacheKeyForURL(URL)];
    }
}

- (void)removeObjectForURL:(NSURL *)URL {
    if (URL) {
        [self removeObjectForKey:URL];
    }
}

- (id)fetchCacheDataForURL:(NSURL *)URL {
    ACNetworkCacheObject *cacheObject = [self objectForURL:URL];
    if (cacheObject.isExpiration) {
        return nil;
    }
    
    return cacheObject.content;
}

- (void)storeCacheData:(id)data forURL:(NSURL *)URL {
    ACNetworkCacheObject *cacheObject = [self objectForURL:URL];
    if (!cacheObject) {
        cacheObject = [[ACNetworkCacheObject alloc] init];
    }
    
    [cacheObject updateContent:data];
    [self setObject:cacheObject forURL:URL];
}

@end
