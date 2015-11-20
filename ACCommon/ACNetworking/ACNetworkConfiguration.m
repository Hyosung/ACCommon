//
//  ACNetworkConfiguration.m
//  ACCommon
//
//  Created by 暁星 on 15/7/16.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkConfiguration.h"

@implementation ACNetworkConfiguration

+ (instancetype)defaultConfiguration {
    static dispatch_once_t onceToken;
    static ACNetworkConfiguration *networkConfig = nil;
    dispatch_once(&onceToken, ^{
        networkConfig = [[self alloc] init];
    });
    return networkConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeoutInterval = 30.0;
        self.downloadFolderName = @"Download";
        self.cacheExpirationTimeInterval = 60.0 * 3;
        self.downloadExpirationTimeInterval = (60.0 * 60.0 * 24.0 * 7);
    }
    return self;
}

- (void)setDownloadFolderName:(NSString *)downloadFolderName {
    NSParameterAssert(downloadFolderName && ![[downloadFolderName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]);
    
    if (![_downloadFolderName isEqualToString:downloadFolderName]) {
        NSString *docmentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *tempDownloadFolder = [docmentPath stringByAppendingPathComponent:downloadFolderName];
        
        if (_downloadFolderName) {
            NSAssert(![[NSFileManager defaultManager] fileExistsAtPath:tempDownloadFolder], @"文件夹名字已被使用，请重新换一个名字");
            //移动已有的文件夹到指定的路径上（实则是修改文件夹名称）
            [[NSFileManager defaultManager] moveItemAtPath:_downloadFolder
                                                    toPath:tempDownloadFolder
                                                     error:nil];
        }
        else {
            if (![[NSFileManager defaultManager] fileExistsAtPath:tempDownloadFolder]) {
                [[NSFileManager defaultManager] createDirectoryAtPath:tempDownloadFolder
                                          withIntermediateDirectories:YES
                                                           attributes:nil
                                                                error:NULL];
            }
        }
        
        _downloadFolder = tempDownloadFolder;
        _downloadFolderName = downloadFolderName;
    }
}

@end
