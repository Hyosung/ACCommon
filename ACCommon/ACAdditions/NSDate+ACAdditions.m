//
//  NSDate+ACAdditions.m
//  ACCommon
//
//  Created by i云 on 14-4-8.
//  Copyright (c) 2014年 Alone Coding. All rights reserved.
//

#import "NSDate+ACAdditions.h"

#if __IOS_64__
#define DATE_STR(__number) [NSString stringWithFormat:@"%02ld",__number]
#else
#define DATE_STR(__number) [NSString stringWithFormat:@"%02d",__number]
#endif

NSInteger const kManySecondsYear   = 60 * 60 * 24 * 365; // 按365天算
NSInteger const kManySecondsMonth  = 60 * 60 * 24 * 30;  // 按30天算
NSInteger const kManySecondsWeek   = 60 * 60 * 24 * 7;
NSInteger const kManySecondsDay    = 60 * 60 * 24;
NSInteger const kManySecondsHour   = 60 * 60;
NSInteger const kManySecondsMinute = 60;

@implementation NSDate (ACAdditions)

- (NSDateComponents *)dateComponents {
    static NSCalendarUnit unitFlags;
    AC_EXEONCE_BEGIN(_datecomponents_)
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    unitFlags = NSCalendarUnitYear |
                NSCalendarUnitMonth |
                NSCalendarUnitDay |
                NSCalendarUnitHour |
                NSCalendarUnitMinute |
                NSCalendarUnitSecond |
                NSCalendarUnitWeekday;
#else
    unitFlags = NSYearCalendarUnit |
                NSMonthCalendarUnit |
                NSDayCalendarUnit |
                NSHourCalendarUnit |
                NSMinuteCalendarUnit |
                NSSecondCalendarUnit |
                NSWeekdayCalendarUnit;
#endif
    AC_EXEONCE_END
    return [[NSCalendar currentCalendar] components:unitFlags fromDate:self];
}

- (NSInteger)yearNumber {
    return [self dateComponents].year;
}

- (NSInteger)monthNumber {
    return [self dateComponents].month;
}

- (NSInteger)dayNumber {
    return [self dateComponents].day;
}

- (NSInteger)hourNumber {
    return [self dateComponents].hour;
}

- (NSInteger)minuteNumber {
    return [self dateComponents].minute;
}

- (NSInteger)secondNumber {
    return [self dateComponents].second;
}

- (NSInteger)weekNumber {
    return [self dateComponents].weekday;
}

- (NSString *)weekString {
   return [NSString stringWithFormat:@"周%@",[self weeks][@([[self dateComponents] weekday])]];
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

/*距离当前的时间间隔描述*/
- (NSString *)timeIntervalDescription {
    NSTimeInterval timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < kManySecondsMinute) {
        return @"1分钟内";
    }
    else if (timeInterval < kManySecondsHour) {
        return [NSString stringWithFormat:@"%.f分钟前", timeInterval / kManySecondsMinute];
    }
    else if (timeInterval < kManySecondsDay) {
        return [NSString stringWithFormat:@"%.f小时前", timeInterval / kManySecondsHour];
    }
    else if (timeInterval < kManySecondsMonth) {//30天内
        return [NSString stringWithFormat:@"%.f天前", timeInterval / kManySecondsDay];
    }
    else if (timeInterval < kManySecondsYear) {//30天至1年内
        NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"M月d日"];
        return [dateFormatter stringFromDate:self];
    }
    else {
        return [NSString stringWithFormat:@"%.f年前", timeInterval / kManySecondsYear];
    }
}

/*精确到分钟的日期描述*/
- (NSString *)minuteDescription {
    NSDateFormatter *dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
    
    NSString *theDay = [dateFormatter stringFromDate:self]; //日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]]; //当前年月日
    if ([theDay isEqualToString:currentDay]) { //当天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
    else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == kManySecondsDay) {//昨天
        [dateFormatter setDateFormat:@"ah:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    }
    else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] < kManySecondsWeek) {//间隔一周内
        [dateFormatter setDateFormat:@"EEEE ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
    else { //以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd ah:mm"];
        return [dateFormatter stringFromDate:self];
    }
}



/*标准时间日期描述*/
- (NSString *)formattedTime {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYYMMdd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(6,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(4,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    
    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components]; //今天 0点时间
    
    NSInteger hour = [self timeIntervalSinceDate:date] / kManySecondsHour;
    NSDateFormatter *dateFormatter = nil;
    NSString *ret = @"";
    
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"HH:mm"];
        }
        else if (hour < 0 && hour >= -24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天HH:mm"];
        }
        else {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
        }
    }else {
        if (hour >= 0 && hour <= 6) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"凌晨hh:mm"];
        }
        else if (hour > 6 && hour <=11 ) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"上午hh:mm"];
        }
        else if (hour > 11 && hour <= 17) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"下午hh:mm"];
        }
        else if (hour > 17 && hour <= 24) {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"晚上hh:mm"];
        }
        else if (hour < 0 && hour >= -24){
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"昨天HH:mm"];
        }
        else  {
            dateFormatter = [NSDateFormatter dateFormatterWithFormat:@"yyyy-MM-dd"];
        }
    }
    
    ret = [dateFormatter stringFromDate:self];
    return ret;
}


/*格式化日期描述*/
- (NSString *)formattedDateDescription {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *theDay = [dateFormatter stringFromDate:self];//日期的年月日
    NSString *currentDay = [dateFormatter stringFromDate:[NSDate date]];//当前年月日
    
    NSInteger timeInterval = -[self timeIntervalSinceNow];
    if (timeInterval < kManySecondsMinute) {
        return @"1分钟内";
    }
    else if (timeInterval < kManySecondsHour) {//1小时内
#if __IOS_64__
        return [NSString stringWithFormat:@"%ld分钟前", timeInterval / kManySecondsMinute];
#else
        return [NSString stringWithFormat:@"%d分钟前", timeInterval / kManySecondsMinute];
#endif
    }
    else if (timeInterval < kManySecondsHour * 6) {//6小时内
#if __IOS_64__
        return [NSString stringWithFormat:@"%ld小时前", timeInterval / kManySecondsHour];
#else
        return [NSString stringWithFormat:@"%d小时前", timeInterval / kManySecondsHour];
#endif
    }
    else if ([theDay isEqualToString:currentDay]) {//当天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"今天 %@", [dateFormatter stringFromDate:self]];
    }
    else if ([[dateFormatter dateFromString:currentDay] timeIntervalSinceDate:[dateFormatter dateFromString:theDay]] == kManySecondsDay) {//昨天
        [dateFormatter setDateFormat:@"HH:mm"];
        return [NSString stringWithFormat:@"昨天 %@", [dateFormatter stringFromDate:self]];
    }
    else {//以前
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        return [dateFormatter stringFromDate:self];
    }
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
