//
//  ACExternals-Header.h
//  ACCommon
//
//  Created by 曉星 on 14-8-9.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#ifndef ACCommon_ACExternals_Header_h
#define ACCommon_ACExternals_Header_h

/*
 外部框架或外部类
 */

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
#import <AFNetworking.h>
#endif

#if defined(__USE_ChineseToPinyin__) && __USE_ChineseToPinyin__
#import "ChineseToPinyin.h"
#endif

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__

#import <UIButton+WebCache.h>
#import <UIImageView+WebCache.h>
#endif

#if defined(__USE_SVProgressHUD__) && __USE_SVProgressHUD__
#import "SVProgressHUD.h"
#endif

#if defined(__USE_SVWebViewController__) && __USE_SVWebViewController__
#import "SVWebViewController.h"
#import "SVModalWebViewController.h"
#endif

#if defined(__USE_SoundManager__) && __USE_SoundManager__
#import "SoundManager.h"
#endif

#if defined(__USE_TTTAttributedLabel__) && __USE_TTTAttributedLabel__
#import "TTTAttributedLabel.h"
#endif

#if defined(__USE_iCarousel__) && __USE_iCarousel__
#import "iCarousel.h"
#endif


#endif
