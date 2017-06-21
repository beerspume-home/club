//
//  DatePicker.h
//  myim
//
//  Created by Sean Shi on 15/11/16.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatePicker : NSObject
@end

@protocol DatePickerDelegate <NSObject>
@required
-(void)datePicker:(DatePicker*)datePicker valueChanged:(NSDate*)date;
@end


@interface DatePicker()
-(void)show:(id<DatePickerDelegate>)delegate;
+(instancetype)sharedDatePicker;
@end
