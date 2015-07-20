//
//  ACNetworkHeader.h
//  ACCommon
//
//  Created by 上海易凡 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#ifndef ACCommon_ACNetworkHeader_h
#define ACCommon_ACNetworkHeader_h

typedef NS_ENUM(NSUInteger, ACNetworkMethod) {
    ACNetworkMethodGET = 0  ,
    ACNetworkMethodPOST     ,
    ACNetworkMethodHEAD     ,
    ACNetworkMethodPUT      ,
    ACNetworkMethodPATCH    ,
    ACNetworkMethodDELETE
};

typedef struct ACNetworkProgress {
    NSUInteger bytes;
    long long totalBytes, totalBytesExpected;
} ACNetworkProgress;

UIKIT_STATIC_INLINE ACNetworkProgress ACNetworkProgressMake(NSUInteger bytes, long long totalBytes, long long totalBytesExpected) {
    ACNetworkProgress progress = {bytes, totalBytes, totalBytesExpected};
    return progress;
}

UIKIT_STATIC_INLINE bool ACNetworkProgressIsEmpty(ACNetworkProgress progress) {
    return progress.bytes <= 0 && progress.totalBytes <= 0 && progress.totalBytesExpected <= 0;
}

#define ACNetworkProgressZero (ACNetworkProgress){0, 0, 0}

typedef void(^ACNetworkCompletionHandler)(id result, NSError *error);
typedef void(^ACNetworkProgressHandler)(ACNetworkProgress progress, id result, NSError *error);

#endif
