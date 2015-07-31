//
//  ACMemoryCache.h
//  ACCommon
//
//  Created by 暁星 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACMemoryCacheObject : NSObject

/**
 *  @author Stoney, 15-07-31 13:07:48
 *
 *  @brief  更新时间
 */
@property (nonatomic, readonly) NSDate *modificationDate;

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

/**
 *  @author Stoney, 15-07-31 09:07:41
 *
 *  @brief  取缓存数据
 *
 *  @param URL URL
 *
 */
- (id)fetchCacheDataForURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-07-31 09:07:05
 *
 *  @brief  存缓存数据
 *
 *  @param data data
 *  @param URL  URL
 */
- (void)storeCacheData:(id) data forURL:(NSURL *) URL;

@end
