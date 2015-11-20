//
//  ACCache.h
//  ACCommon
//
//  Created by 暁星 on 15/7/20.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ACCacheObject : NSObject <NSCoding>

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

@interface ACCache : NSObject

+ (instancetype)sharedCache;

/**
 *  @author Stoney, 15-08-04 08:08:32
 *
 *  @brief  从内存中取缓存对象
 *
 */
- (id)objectFromMemoryCacheForURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-08-04 08:08:02
 *
 *  @brief  从本地磁盘中取缓存对象，首先是取内存中的缓存，在没有的情况下，才从磁盘中取
 *
 */
- (id)objectFromDiskCacheForURL:(NSURL *) URL;

- (void)setObject:(id) obj forURL:(NSURL *) URL;
- (void)setObject:(id) obj forURL:(NSURL *) URL toDisk:(BOOL) toDisk;
- (void)removeObjectForURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-08-04 08:08:25
 *
 *  @brief  清理内存与本地磁盘中的缓存
 */
- (void)cleanDiskMemory;

/**
 *  @author Stoney, 15-07-31 09:07:41
 *
 *  @brief  取内存中的缓存数据
 *
 */
- (id)fetchDataFromMemoryCacheForURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-08-04 08:08:22
 *
 *  @brief  取本地磁盘中的缓存对象
 *
 */
- (id)fetchDataFromDiskCacheForURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-07-31 09:07:05
 *
 *  @brief  存缓存数据
 *
 */
- (void)storeCacheData:(id) data forURL:(NSURL *) URL;
- (void)storeCacheData:(id) data forURL:(NSURL *) URL toDisk:(BOOL) toDisk;

/**
 *  @author Stoney, 15-08-04 09:08:11
 *
 *  @brief  存相对路径
 *
 */
- (void)storeAbsolutePath:(NSString *) absolutePath forURL:(NSURL *) URL;

/**
 *  @author Stoney, 15-08-04 09:08:25
 *
 *  @brief  取绝对路径
 *
 */
- (NSString *)fetchAbsolutePathforURL:(NSURL *) URL;

@end
