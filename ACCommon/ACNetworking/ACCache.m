//
//  ACCache.m
//  ACCommon
//
//  Created by 暁星 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACCache.h"

#import <UIKit/UIApplication.h>
#import "ACNetworkHeader.h"
#import "ACNetworkConfiguration.h"
#import <CommonCrypto/CommonDigest.h>

@interface AutoCleanCache : NSCache
@end

@implementation AutoCleanCache

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidReceiveMemoryWarningNotification
                                                  object:nil];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.name = @"com.acnetworking.cache";
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removeAllObjects)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

@end

@implementation ACCacheObject

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _content = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(content))];
        _modificationDate = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(modificationDate))];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_content forKey:NSStringFromSelector(@selector(content))];
    [aCoder encodeObject:_modificationDate forKey:NSStringFromSelector(@selector(modificationDate))];
}

- (instancetype)initWithContent:(id) content {
    self = [super init];
    if (self) {
        _content = content;
        _modificationDate = [NSDate date];
    }
    return self;
}

- (void)updateContent:(id) content {
    _content = content;
    _modificationDate = [NSDate date];
}

- (BOOL)isExpiration {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.modificationDate];
    return (timeInterval > [ACNetworkConfiguration defaultConfiguration].cacheExpirationTimeInterval);
}

@end

@interface ACCache ()

@property (nonatomic, strong) AutoCleanCache *memoryCache;
@property (nonatomic, strong) NSString *diskCachePath;
@property (nonatomic, strong) NSString *applicationPath;

@end

@implementation ACCache

ACNETWORK_STATIC_INLINE NSString * ACCacheKeyForURL(NSURL *URL) {
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

ACNETWORK_STATIC_INLINE NSString * ACDiskCachePathFromURL(NSURL *URL, NSString *diskFolder) {
    return [diskFolder stringByAppendingPathComponent:ACCacheKeyForURL(URL)];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.memoryCache = [[AutoCleanCache alloc] init];
        self.diskCachePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"com.acnetworking.cachedefault"];
        self.applicationPath = NSHomeDirectory();
    }
    return self;
}

+ (instancetype)sharedCache {
    static dispatch_once_t onceToken;
    static ACCache *networkCache = nil;
    dispatch_once(&onceToken, ^{
        networkCache = [[self alloc] init];
    });
    return networkCache;
}

- (id)objectFromMemoryCacheForURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    
    return [self.memoryCache objectForKey:ACCacheKeyForURL(URL)];
}

- (id)objectFromDiskCacheForURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    
    // First check the in-memory cache...
    id objcect = [self objectFromMemoryCacheForURL:URL];
    if (objcect) {
        return objcect;
    }
    
    // Second check the disk cache...
    id diskObject = [NSKeyedUnarchiver unarchiveObjectWithFile:ACDiskCachePathFromURL(URL, self.diskCachePath)];
    if (diskObject) {
        [self setObject:diskObject forURL:URL toDisk:NO];
    }
    
    return diskObject;
}

- (void)setObject:(id)obj forURL:(NSURL *)URL {
    [self setObject:obj forURL:URL toDisk:YES];
}

- (void)setObject:(id)obj forURL:(NSURL *)URL toDisk:(BOOL)toDisk {
    if (!obj || !URL) {
        return;
    }
    
    [self.memoryCache setObject:obj forKey:ACCacheKeyForURL(URL)];
    
    if (toDisk) {
        [NSKeyedArchiver archiveRootObject:obj toFile:ACDiskCachePathFromURL(URL, self.diskCachePath)];
    }
}

- (void)removeObjectForURL:(NSURL *)URL {
    if (!URL) {
        return;
    }
    
    [self.memoryCache removeObjectForKey:ACCacheKeyForURL(URL)];
}

- (void)cleanDiskMemory {
    [self.memoryCache removeAllObjects];
    [[NSFileManager defaultManager] removeItemAtPath:self.diskCachePath error:nil];
}

- (id)fetchDataFromMemoryCacheForURL:(NSURL *)URL {
    ACCacheObject *cacheObject = [self.memoryCache objectForKey:ACCacheKeyForURL(URL)];
    if (cacheObject.isExpiration) {
        return nil;
    }
    
    return cacheObject.content;
}

- (id)fetchDataFromDiskCacheForURL:(NSURL *)URL {
    id object = [self fetchDataFromMemoryCacheForURL:URL];
    if (object) {
        return object;
    }
    
    ACCacheObject *cacheObject = [NSKeyedUnarchiver unarchiveObjectWithFile:ACDiskCachePathFromURL(URL, self.diskCachePath)];
    if (cacheObject.isExpiration) {
        return nil;
    }
    return cacheObject.content;
}

- (void)storeCacheData:(id)data forURL:(NSURL *)URL {
    [self storeCacheData:data forURL:URL toDisk:YES];
}

- (void)storeCacheData:(id)data forURL:(NSURL *)URL toDisk:(BOOL)toDisk {
    ACCacheObject *cacheObject = [self objectFromDiskCacheForURL:URL];
    if (!cacheObject) {
        cacheObject = [[ACCacheObject alloc] init];
    }
    [cacheObject updateContent:data];
    [self setObject:cacheObject forURL:URL];
}

- (void)storeAbsolutePath:(NSString *)absolutePath forURL:(NSURL *)URL {
    if (!absolutePath || !URL) {
        return;
    }
    
    absolutePath = [absolutePath stringByReplacingOccurrencesOfString:self.applicationPath
                                                           withString:@""
                                                              options:NSAnchoredSearch
                                                                range:NSMakeRange(0, absolutePath.length)];
    [self setObject:absolutePath forURL:URL];
}

- (NSString *)fetchAbsolutePathforURL:(NSURL *)URL {
    if (!URL) {
        return nil;
    }
    NSString *relativePath = [self objectFromDiskCacheForURL:URL];
    if (!relativePath) {
        return nil;
    }
    
    return [self.applicationPath stringByAppendingPathComponent:relativePath];
}

@end
