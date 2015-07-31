//
//  ACNetworkHeader.h
//  ACCommon
//
//  Created by 暁星 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#if __has_include(<AFNetworking.h>)
#import <AFNetworking.h>
#else
#error "请导入 #import <AFNetworking.h>"
#endif

#ifndef ACCommon_ACNetworkHeader_h
#define ACCommon_ACNetworkHeader_h

#ifdef __cplusplus
#define ACCommon_EXTERN		extern "C" __attribute__((visibility ("default")))
#else
#define ACCommon_EXTERN	        extern __attribute__((visibility ("default")))
#endif

#define ACCommon_STATIC_INLINE	static inline

typedef NS_ENUM(NSUInteger, ACRequestMethod) {
    ACRequestMethodGET = 0  ,
    ACRequestMethodPOST     ,
    ACRequestMethodHEAD     ,
    ACRequestMethodPUT      ,
    ACRequestMethodPATCH    ,
    ACRequestMethodDELETE
};

ACCommon_STATIC_INLINE NSString * RequestMethod(ACRequestMethod method) {
    static dispatch_once_t onceToken;
    static NSDictionary *methods = nil;
    dispatch_once(&onceToken, ^{
        methods = @{
                    @(ACRequestMethodGET)   : @"GET",
                    @(ACRequestMethodPUT)   : @"PUT",
                    @(ACRequestMethodHEAD)  : @"HEAD",
                    @(ACRequestMethodPOST)  : @"POST",
                    @(ACRequestMethodPATCH) : @"PATCH",
                    @(ACRequestMethodDELETE): @"DELETE"
                    };
    });
    return methods[@(method)];
}

typedef struct ACRequestProgress {
    NSUInteger bytes;
    long long totalBytes, totalBytesExpected;
} ACRequestProgress;

ACCommon_STATIC_INLINE ACRequestProgress ACRequestProgressMake(NSUInteger bytes, long long totalBytes, long long totalBytesExpected) {
    ACRequestProgress progress = {bytes, totalBytes, totalBytesExpected};
    return progress;
}

ACCommon_STATIC_INLINE bool ACRequestProgressIsEmpty(ACRequestProgress progress) {
    return progress.bytes <= 0 && progress.totalBytes <= 0 && progress.totalBytesExpected <= 0;
}

#define ACRequestProgressZero (ACRequestProgress){0, 0, 0}

typedef void(^ACRequestCompletionHandler)(id result, NSError *error);
typedef void(^ACRequestProgressHandler)(ACRequestProgress progress, id result, NSError *error);

#endif
