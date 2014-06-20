//
//  ACExternals.h
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#ifndef ACCommon_ACExternals_h
#define ACCommon_ACExternals_h

/*
 外部框架或外部类
 */

#if defined(__USE_AFNetworking__) && __USE_AFNetworking__
#import "AFNetworking.h"
#endif

#if defined(__USE_ChineseToPinyin__) && __USE_ChineseToPinyin__
#import "ChineseToPinyin.h"
#endif

#if defined(__USE_ASIHTTPRequest__) && __USE_ASIHTTPRequest__
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASINetworkQueue.h"
#endif

#if defined(__USE_PullingRefreshTableView__) && __USE_PullingRefreshTableView__
#import "PullingRefreshTableView.h"
#endif

#if defined(__USE_Reachability__) && __USE_Reachability__
#import "Reachability.h"
#endif

#if defined(__USE_SDWebImage__) && __USE_SDWebImage__
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
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
