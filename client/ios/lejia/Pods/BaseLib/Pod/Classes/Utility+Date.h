//
//  Utility+Date.h
//  xcbstudent
//
//  Created by Sean Shi on 15/8/23.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#ifndef BaseLib_Utility_Date_h
#define BaseLib_Utility_Date_h

#import "Utility.h"

@interface Utility (Date)

+(NSString *) weekdayStringFromDate:(NSDate*)inputDate;
+(NSString *) weekdayStringFromString:(NSString*)inputDate;
+(NSDate*) parseDateFromString:(NSString*)stringDate withFormat:(NSString*)format;
+(NSString*) formatStringFromDate:(NSDate*) date withFormat:(NSString*)format;

/*!
 Format is like below string:
   @"yyyy-MM-dd"
   @"yyyy-MM-dd HH:mm:ss"
 */
+(NSString*) formatStringFromStringDate:(NSString*) stringDate withInputFormat:(NSString*)inputFormat outputFormat:(NSString*)outputFormat;
+(NSDateComponents*) dateComponentsFromDate:(NSDate*)date;
+(NSDate*)getDateFromDate:(NSDate *)date withMonth:(int)month;
+(NSDate*)getDateFromDate:(NSDate *)date withDay:(int)day;
+(NSDate*)getDateFromDate:(NSDate *)date withWeek:(int)week;
+(NSRange)daysOfMonthWithDate:(NSDate*)date;
+(NSDate*)firstDaysOfMonthWithDate:(NSDate*)date;
+(NSInteger)getWeekdayWithDate:(NSDate*)date;
+(NSDate*)dateWithDateComponents:(NSDateComponents*)dateCom;
+(NSString*)chineseCalendarWithDate:(NSDate *)date;
@end

#endif