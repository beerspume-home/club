//
//  DatePicker.m
//  myim
//
//  Created by Sean Shi on 15/11/16.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "DatePicker.h"

@interface DatePicker(){
    UIView* _maskView;
    UIDatePicker* _datePicker;
    
    id<DatePickerDelegate> _delegate;
}

@end

static DatePicker* datePickerInstance;
@implementation DatePicker

-(void)show:(id<DatePickerDelegate>)delegate{
    _delegate=delegate;
    if(_maskView!=nil && _datePicker!=nil){
        _maskView.hidden=false;
        _datePicker.hidden=false;
        _datePicker.top=_datePicker.superview.height;

        [UIView animateWithDuration:0.2 animations:^{
            _datePicker.bottom=_datePicker.superview.height-5;
        } completion:^(BOOL finished) {
            if(finished){
            }
            
        }];
        
    }
}

-(void)hide{
    _delegate=nil;
    if(_maskView!=nil){
        [UIView animateWithDuration:0.2 animations:^{
            _datePicker.top=_datePicker.superview.height;
        } completion:^(BOOL finished) {
            if(finished){
                _maskView.hidden=true;
                _datePicker.hidden=true;
            }
            
        }];
    }
}

-(void)dateChanged:(UIDatePicker*)datePicker{
    if(_delegate!=nil){
        [_delegate datePicker:self valueChanged:datePicker.date];
    }
}

-(instancetype)init{
    DatePicker* ret=[super init];
    UIView* rootView=[UIApplication sharedApplication].keyWindow;
    if(rootView!=nil){
        if(_maskView==nil){
            _maskView=[[UIView alloc]init];
            [rootView addSubview:_maskView];
            _maskView.hidden=true;
            _maskView.frame=rootView.frame;
            _maskView.backgroundColor=[UIColor blackColor];
            _maskView.alpha=0.1;
            _maskView.userInteractionEnabled=true;
            [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)]];
        }
        if(_datePicker==nil){
            _datePicker=[[UIDatePicker alloc]init];
            [rootView addSubview:_datePicker];
            _datePicker.width=_datePicker.superview.width-10;
            _datePicker.bottom=_datePicker.superview.height-5;
            _datePicker.centerX=_datePicker.superview.width/2;
            _datePicker.backgroundColor=[UIColor whiteColor];
            _datePicker.datePickerMode=UIDatePickerModeDate;
            _datePicker.layer.masksToBounds=true;
            _datePicker.layer.borderWidth=1;
            _datePicker.layer.borderColor=COLOR_SPLIT.CGColor;
            _datePicker.layer.cornerRadius=5;
            [_datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged ];
        }
        
    }
    _maskView.hidden=true;
    _datePicker.hidden=true;
    return ret;
    
}


+(instancetype)sharedDatePicker{
    if(datePickerInstance==nil){
        datePickerInstance=[[DatePicker alloc]init];
    }
    return datePickerInstance;
}
@end
