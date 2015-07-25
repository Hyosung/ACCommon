//
//  ACMemoryCache.h
//  ACCommon
//
//  Created by 暁星 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACMemoryCacheObject : NSObject

@property (nonatomic, readonly) NSTimeInterval lastUpdateTimestamp;
@property (nonatomic, readonly, getter=isExpiration) BOOL expiration;

@property (nonatomic, strong, readonly) id content;

- (instancetype)initWithContent:(id) content;
- (void)updateContent:(id) content;

@end

@interface ACMemoryCache : NSCache

+ (instancetype)memoryCache;
+ (instancetype)sharedCache;

- (id)objectForURL:(NSURL *) URL;
- (void)setObject:(id) obj forURL:(NSURL *) URL;
- (void)removeObjectForURL:(NSURL *) URL;

- (id)fetchCacheDataForURL:(NSURL *) URL;
- (void)storeCacheData:(id) data forURL:(NSURL *) URL;

@end
