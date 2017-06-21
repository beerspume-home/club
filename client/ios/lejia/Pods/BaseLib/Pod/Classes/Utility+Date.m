//
//  Utility+Date.m
//  xcbstudent
//
//  Created by Sean Shi on 15/8/23.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "Utility+Date.h"

@implementation Utility (Date)

+(NSString *) weekdayStringFromDate:(NSDate*)inputDate{
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:inputDate];
    
    return [weekdays objectAtIndex:theComponents.weekday];
    
}

+(NSString *) weekdayStringFromString:(NSString*)inputDate {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:inputDate];
    
    return [self weekdayStringFromDate:date];
    
}


+(NSDate*) parseDateFromString:(NSString*)stringDate withFormat:(NSString*)format{
    if(format==nil){
        format=@"yyyy-MM-dd";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate* date=[dateFormatter dateFromString:stringDate];
    return date;
}
+(NSString*) formatStringFromDate:(NSDate*) date withFormat:(NSString*)format{
    if(format==nil){
        format=@"yyyy-MM-dd";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString* ret=[dateFormatter stringFromDate:date];
    return ret;
    
}

/*!
 Format is like below string:
 @"yyyy-MM-dd"
 @"yyyy-MM-dd HH:mm:ss"
 */
+(NSString*) formatStringFromStringDate:(NSString*) stringDate withInputFormat:(NSString*)inputFormat outputFormat:(NSString*)outputFormat{
    if(inputFormat==nil){
        inputFormat=@"yyyy-MM-dd";
    }
    if(outputFormat==nil){
        outputFormat=@"yyyy-MM-dd";
    }
    NSString* ret=[Utility formatStringFromDate:[Utility parseDateFromString:stringDate withFormat:inputFormat] withFormat:outputFormat];
    
    return ret;
    
}


+(NSDateComponents*) dateComponentsFromDate:(NSDate*)date{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSDateComponents* com=[cal components:
                           NSCalendarUnitYear
                           |NSCalendarUnitMonth
                           |NSCalendarUnitDay
                           |NSCalendarUnitHour
                           |NSCalendarUnitMinute
                           |NSCalendarUnitSecond
                           |NSCalendarUnitWeekday
                                 fromDate:date];
    com.timeZone=[NSTimeZone localTimeZone];
    return com;
}

+(NSDate*)getDateFromDate:(NSDate *)date withMonth:(int)month{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    NSDate* ret = [cal dateByAddingComponents:comps toDate:date options:0];
    return ret;
}
+(NSDate*)getDateFromDate:(NSDate *)date withDay:(int)day{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setDay:day];
    NSDate* ret = [cal dateByAddingComponents:comps toDate:date options:0];
    return ret;
}
+(NSDate*)getDateFromDate:(NSDate *)date withWeek:(int)week{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setWeekOfYear:week];
    NSDate* ret = [cal dateByAddingComponents:comps toDate:date options:0];
    return ret;
}

+(NSRange)daysOfMonthWithDate:(NSDate*)date{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSRange ret=[cal rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return ret;
}
+(NSDate*)firstDaysOfMonthWithDate:(NSDate*)date{
    NSDateComponents* dateCom=[Utility dateComponentsFromDate:date];
    [dateCom setDay:1];
    return [Utility dateWithDateComponents:dateCom];
}
+(NSInteger)getWeekdayWithDate:(NSDate*)date{
    NSDateComponents* dateCom=[Utility dateComponentsFromDate:date];
    return dateCom.weekday;
}

+(NSDate*)dateWithDateComponents:(NSDateComponents*)dateCom{
    NSCalendar* cal=[NSCalendar currentCalendar];
    cal.firstWeekday=2;
    NSDate* ret=[cal dateFromComponents:dateCom];
    return ret;
}

static NSArray *chineseYears;
static NSArray *chineseMonths;
static NSArray *chineseDays;
+(NSString*)chineseCalendarWithDate:(NSDate *)date{
    if(chineseYears==nil){
        chineseYears = @[
                             @"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉",
                             @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未",
                             @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳",
                             @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑",
                             @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑",
                             @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥", ];
    }
    if(chineseMonths==nil){
        chineseMonths=@[
                            @"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月",
                            @"九月", @"十月", @"冬月", @"腊月",];
    }
    if(chineseDays==nil){
        chineseDays=@[
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十", ];
    }
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    
//    NSString *y_str = [chineseYears objectAtIndex:localeComp.year-1];
    NSString *m_str = [chineseMonths objectAtIndex:localeComp.month-1];
    NSString *d_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    NSString *ret =d_str;
    if(localeComp.day==1){
        ret=m_str;
    }
    
    return ret;
}
@end
