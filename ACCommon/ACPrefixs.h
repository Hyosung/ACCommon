//
//  ACPrefixs.h
//  ACCommon
//
//  Created by 曉星 on 14-5-1.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#ifndef ACCommon_ACPrefixs_h
#define ACCommon_ACPrefixs_h

typedef NS_ENUM(BOOL, ACImportStatus) {
    ACImportStatusNo  = NO,
    ACImportStatusYES = YES
};

/*
 预编译头文件
 */

#define __USE_ACCommon__ (1)

#define __USE_iCarousel__               (0)
#define __USE_SDWebImage__              (1)
#define __USE_SoundManager__            (1)
#define __USE_Reachability__            (1)
#define __USE_AFNetworking__            (1)
#define __USE_SVProgressHUD__           (1)
#define __USE_ASIHTTPRequest__          (1)
#define __USE_ChineseToPinyin__         (1)
#define __USE_TTTAttributedLabel__      (1)
#define __USE_SVWebViewController__     (1)
#define __USE_PullingRefreshTableView__ (1)

#define __USE_QuartzCore__ (1)
#define __USE_objc_runtime__ (1)
#define __USE_objc_message__ (1)

#define __AC_DEFINED__(_define_name) ({defined(_define_name) && _define_name})

#endif
