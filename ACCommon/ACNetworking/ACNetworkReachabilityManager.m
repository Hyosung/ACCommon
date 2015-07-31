//
//  ACNetworkReachabilityManager.m
//  ACCommon
//
//  Created by 曉星 on 15/5/27.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "ACNetworkReachabilityManager.h"

#import <UIKit/UIDevice.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const ACNetworkingReachabilityDidChangeNotification = @"com.stoney.networking.reachability.change";
NSString * const ACNetworkingReachabilityNotificationStatusItem = @"ACNetworkingReachabilityNotificationStatusItem";

typedef void (^ACNetworkReachabilityStatusBlock)(ACNetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, ACNetworkReachabilityAssociation) {
    ACNetworkReachabilityForAddress = 1,
    ACNetworkReachabilityForAddressPair = 2,
    ACNetworkReachabilityForName = 3,
};

NSString * ACStringFromNetworkReachabilityStatus(ACNetworkReachabilityStatus status) {
    switch (status) {
        case ACNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"ACNetworking", nil);
#if	TARGET_OS_IPHONE
        case ACNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"ACNetworking", nil);
#endif
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000)
        case ACNetworkReachabilityStatusReachableVia2G:
            return NSLocalizedStringFromTable(@"Reachable via 2G", @"ACNetworking", nil);
        case ACNetworkReachabilityStatusReachableVia3G:
            return NSLocalizedStringFromTable(@"Reachable via 3G", @"ACNetworking", nil);
        case ACNetworkReachabilityStatusReachableVia4G:
            return NSLocalizedStringFromTable(@"Reachable via 4G", @"ACNetworking", nil);
#endif
        case ACNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"ACNetworking", nil);
        case ACNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"ACNetworking", nil);
    }
}

static ACNetworkReachabilityStatus ACNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    ACNetworkReachabilityStatus status = ACNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = ACNetworkReachabilityStatusNotReachable;
    }
#if	defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
        status = ACNetworkReachabilityStatusReachableViaWWAN;
        //来源 http://www.cocoachina.com/bbs/read.php?tid=228822
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending) {
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
            if (currentRadioAccessTechnology) {
                if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                    status = ACNetworkReachabilityStatusReachableVia4G;
                }
                else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                    status = ACNetworkReachabilityStatusReachableVia2G;
                }
                else {
                    status = ACNetworkReachabilityStatusReachableVia3G;
                }
            }
        }
        else {
            if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection) {
                if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                    status = ACNetworkReachabilityStatusReachableVia2G;
                }
                else {
                    status = ACNetworkReachabilityStatusReachableVia3G;
                }
            }
        }
#else
        status = ACNetworkReachabilityStatusReachableViaWWAN;
#endif
    }
#endif
    else {
        status = ACNetworkReachabilityStatusReachableViaWiFi;
    }
    
    return status;
}

static void ACNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    ACNetworkReachabilityStatus status = ACNetworkReachabilityStatusForFlags(flags);
    ACNetworkReachabilityStatusBlock block = (__bridge ACNetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ ACNetworkingReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:ACNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
    
}

static const void * ACNetworkReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void ACNetworkReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface ACNetworkReachabilityManager ()
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) ACNetworkReachabilityAssociation networkReachabilityAssociation;
@property (readwrite, nonatomic, assign) ACNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) ACNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation ACNetworkReachabilityManager


+ (instancetype)sharedManager {
    static ACNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;
        
        _sharedManager = [self managerForAddress:&address];
    });
    
    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    
    ACNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = ACNetworkReachabilityForName;
    
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    
    ACNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = ACNetworkReachabilityForAddress;
    
    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.networkReachability = reachability;
    self.networkReachabilityStatus = ACNetworkReachabilityStatusUnknown;
    
    return self;
}

- (void)dealloc {
    [self stopMonitoring];
    
    if (_networkReachability) {
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

#pragma mark -

- (BOOL)isReachable {
#if	TARGET_OS_IPHONE
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
#else
    return [self isReachableViaWiFi];
#endif
    
}

#if	defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
- (BOOL)isReachableViaWWAN {
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
    return [self isReachableVia2G] || [self isReachableVia3G] || [self isReachableVia4G] || self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableViaWWAN;
#else
    return self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableViaWWAN;
#endif
}

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000

- (BOOL)isReachableVia2G {
    return self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableVia2G;
}

- (BOOL)isReachableVia3G {
    return self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableVia3G;
}

- (BOOL)isReachableVia4G {
    return self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableVia4G;
}
#endif

#endif

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == ACNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    ACNetworkReachabilityStatusBlock callback = ^(ACNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
        
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, ACNetworkReachabilityRetainCallback, ACNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, ACNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    switch (self.networkReachabilityAssociation) {
        case ACNetworkReachabilityForName:
            break;
        case ACNetworkReachabilityForAddress:
        case ACNetworkReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
                ACNetworkReachabilityStatus status = ACNetworkReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);
                    
                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:ACNetworkingReachabilityDidChangeNotification object:nil userInfo:@{ ACNetworkingReachabilityNotificationStatusItem: @(status) }];
                    
                    
                });
            });
        }
            break;
    }
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return ACStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(ACNetworkReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] ||
        [key isEqualToString:@"reachableViaWWAN"] ||
        [key isEqualToString:@"reachableVia2G"] ||
        [key isEqualToString:@"reachableVia3G"] ||
        [key isEqualToString:@"reachableVia4G"] ||
        [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end

