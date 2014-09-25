//
//  NSDate+ACAdditions.m
//  ACCommon
//
//  Created by i云 on 14-4-8.
//  Copyright (c) 2014年 Crazy Stone. All rights reserved.
//

#import "NSDate+ACAdditions.h"

#if __IOS_64__
#define DATE_STR(__number) [NSString stringWithFormat:@"%02ld",__number]
#else
#define DATE_STR(__number) [NSString stringWithFormat:@"%02d",__number]
#endif

@implementation NSDate (ACAdditions)

- (NSDateComponents *)dateComponents {
    static NSCalendar *cal;
    static unsigned int unitFlag;
    AC_EXEONCE_BEGIN(one)
    cal = [NSCalendar currentCalendar];
    unitFlag = NSEraCalendarUnit |
               NSYearCalendarUnit |
               NSMonthCalendarUnit |
               NSDayCalendarUnit |
               NSHourCalendarUnit |
               NSMinuteCalendarUnit |
               NSSecondCalendarUnit |
               NSWeekdayCalendarUnit;
    AC_EXEONCE_END
    return [cal components:unitFlag fromDate:self];
}

- (NSString *)era {
    return ACSTR(@"%@",@([[self dateComponents] era]));
}

- (NSString *)year {
    return ACSTR(@"%@",@([[self dateComponents] year]));
}

- (NSString *)month {
    return ACSTR(@"%@",@([[self dateComponents] month]));
}

- (NSString *)month_MM {
    return DATE_STR([[self dateComponents] month]);
}

- (NSString *)day {
    return ACSTR(@"%@",@([[self dateComponents] day]));
}

- (NSString *)day_dd {
    return DATE_STR([[self dateComponents] day]);
}

- (NSString *)hour {
    return ACSTR(@"%@",@([[self dateComponents] hour]));
}

- (NSString *)hour_hh {
    return DATE_STR([[self dateComponents] hour]);
}

- (NSString *)minute {
    return ACSTR(@"%@",@([[self dateComponents] minute]));
}

- (NSString *)minute_mm {
    return DATE_STR([[self dateComponents] minute]);
}

- (NSString *)second {
    return ACSTR(@"%@",@([[self dateComponents] second]));
}

- (NSString *)second_ss {
    return DATE_STR([[self dateComponents] second]);
}

- (NSString *)week {
    return ACSTR(@"周%@",[self weeks][@([[self dateComponents] weekday])]);
}

- (NSDictionary *)weeks {
    return @{@2: @"一",
             @3: @"二",
             @4: @"三",
             @5: @"四",
             @6: @"五",
             @7: @"六",
             @1: @"日"};
}

@end
