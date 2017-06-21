//
//  TATeacherRecordCell.m
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherRecordCell.h"

//top,left,bottom,right
#define PADDING ((UIEdgeInsets){10,15,10,15})
#define PADDING_LINE 3
#define FONT1 FONT_TEXT_NORMAL
#define FONT2 FONT_TEXT_SECONDARY
#define HEADIMG_SIZE 50
#define HEADIMG_RIGHT_PADDING 5

@interface TATeacherRecordCell(){
    UIImageView* _studentHeadIcon;
    UILabel* _dateLabel;
    UILabel* _timeLabel;
    UILabel* _stampLabel;
    UILabel* _nameLabel;
    UILabel* _remarkLabel;

    BOOL _inited;
}
@end

@implementation TATeacherRecordCell

-(void)setAppointment:(CourseAppointment *)appointment{
    _appointment=appointment;
    [self setNeedsLayout];
}

+(CGFloat)calcLayoutHeightWithAppointment:(CourseAppointment*)appointment andMaxWidth:(CGFloat)maxWidth{
    CGFloat ret=PADDING.top;
    
    CGSize size=getStringSize(appointment.date, FONT1);
    ret+=size.height;
    ret+=PADDING_LINE;
    
    size=getStringSize(appointment.course.starttime, FONT1);
    ret+=size.height;
    ret+=PADDING_LINE;

    size=getStringSize(@"学员", FONT1);
    ret+=size.height;
    ret+=PADDING_LINE;
    
    CGFloat width=maxWidth-(PADDING.left+HEADIMG_SIZE+HEADIMG_RIGHT_PADDING)-PADDING.right;
    size=getStringSizeLimitWithWidth(appointment.studentremark, FONT2, width);
    ret+=size.height;

    ret+=PADDING.bottom;
    return ret;
}

-(void)layoutSubviews{
    NSString* stampText=@"未开始";
    UIColor* stampColor=UIColorFromRGB(0x3aa5de);
    UIColor* textColor=stampColor;
    UIFont* stampFont=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:FONT_TEXT_SECONDARY.pointSize*0.8];
    if([_appointment isDeleted]){
        stampText=@"已取消";
        stampColor=COLOR_SPLIT;
    }else if([_appointment isExpired]){
        if(_appointment.teacherevaluation==nil){
            stampText=@"待评价";
        }else{
            stampText=@"已完成";
        }
        stampColor=COLOR_HEADER_BG;
    }
    textColor=stampColor;
    
    
    if(_studentHeadIcon==nil){
        _studentHeadIcon=[[UIImageView alloc]init];
        [self addSubview:_studentHeadIcon];
    }
    NSURL* headImgUrl=[NSURL URLWithString:_appointment.student.person.imageurl];
    [_studentHeadIcon sd_setImageWithURL:headImgUrl placeholderImage:[UIImage imageNamed:@"缺省头像"]];
    _studentHeadIcon.size=(CGSize){HEADIMG_SIZE,HEADIMG_SIZE};
    _studentHeadIcon.origin=(CGPoint){PADDING.left,PADDING.top};

    
    
    if(_dateLabel==nil){
        _dateLabel=[[UILabel alloc]init];
        [self addSubview:_dateLabel];
    }
    _dateLabel.text=[Utility formatStringFromStringDate:_appointment.date withInputFormat:nil outputFormat:@"yyyy年MM月dd日"];
    _dateLabel.textColor=stampColor;
    _dateLabel.font=FONT_TEXT_NORMAL;
    [_dateLabel fit];
    _dateLabel.origin=(CGPoint){_studentHeadIcon.right+HEADIMG_RIGHT_PADDING,_studentHeadIcon.top};
    
    if(_timeLabel==nil){
        _timeLabel=[[UILabel alloc]init];
        [self addSubview:_timeLabel];
    }
    _timeLabel.text=[NSString stringWithFormat:@"%@-%@",_appointment.course.starttime,_appointment.course.endtime];
    _timeLabel.textColor=stampColor;
    _timeLabel.font=FONT_TEXT_NORMAL;
    [_timeLabel fit];
    _timeLabel.origin=(CGPoint){_dateLabel.left,_dateLabel.bottom+PADDING_LINE};
    
    if(_nameLabel==nil){
        _nameLabel=[[UILabel alloc]init];
        [self addSubview:_nameLabel];
    }
    _nameLabel.text=[NSString stringWithFormat:@"学员:%@",_appointment.student.person.name];
    _nameLabel.textColor=stampColor;
    _nameLabel.font=FONT_TEXT_NORMAL;
    [_nameLabel fit];
    _nameLabel.origin=(CGPoint){_timeLabel.left,_timeLabel.bottom+PADDING_LINE};

    if(_remarkLabel==nil){
        _remarkLabel=[[UILabel alloc]init];
        [self addSubview:_remarkLabel];
    }
    _remarkLabel.text=_appointment.studentremark;
    _remarkLabel.textColor=stampColor;
    _remarkLabel.font=FONT2;
    _remarkLabel.origin=(CGPoint){_nameLabel.left,_nameLabel.bottom+PADDING_LINE};
    CGFloat width=_remarkLabel.superview.width-_remarkLabel.left-PADDING.right;
    [_remarkLabel fitWithWidth:width];
    
    
    if(_stampLabel!=nil){
        [_stampLabel removeFromSuperview];
    }
    
    _stampLabel=[UIUtility genStampLabelWithText:stampText color:stampColor font:stampFont];
    [self addSubview:_stampLabel];
    _stampLabel.top=PADDING.top;
    _stampLabel.right=_stampLabel.superview.width-PADDING.right;

//    CGFloat bottom=[Utility calcBottomOfSubviewsInView:self];
//    self.height=bottom+PADDING.bottom;
}

@end
