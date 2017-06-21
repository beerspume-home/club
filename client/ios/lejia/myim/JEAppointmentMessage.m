//
//  JEAppointmentMessage.m
//  myim
//
//  Created by Sean Shi on 15/12/2.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "JEAppointmentMessage.h"

@implementation JEAppointmentMessage

-(NSData*)encode{

    NSDictionary* dataDict=[self propertiesToDictionary];
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:dataDict
                                                   options:kNilOptions
                                                     error:nil];
    return data;
}

-(void)decodeWithData:(NSData *)data{
    if (data==nil) {
        return;
    }
    
    NSError* __error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data
                                                         options:kNilOptions
                                                           error:&__error];
    [self fillPropertiesWithDictionary:json];
}

+(NSString *)getObjectName{
    return @"JE:appointmentMsg";
}

+(RCMessagePersistent)persistentFlag{
    return (MessagePersistent_ISCOUNTED | MessagePersistent_ISPERSISTED);
}

- (NSString *)conversationDigest{
    return @"约车消息";
}

@end


@interface JEAppointmentMessageCell(){
    
    UILabel* _titleLabel;
    UILabel* _dateLabel;
    UILabel* _timeLabel;
    UILabel* _studentNameLabel;
    
}

@end

@implementation JEAppointmentMessageCell
-(instancetype)initWithFrame:(CGRect)frame{
    [self initEvent];
    return [super initWithFrame:frame];
}
-(void)initEvent{
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
}

-(void)tap:(UIGestureRecognizer*)sender{
    if(self.delegate!=nil){
        [self.delegate didTapMessageCell:self.model];
    }
}

-(void)layoutSubviews{
    
    JEAppointmentMessage* message=(JEAppointmentMessage*)self.model.content;
    
    self.messageContentView.backgroundColor=[UIColor whiteColor];
    self.messageContentView.layer.cornerRadius=3;
    self.messageContentView.layer.shadowColor=[UIColor blackColor].CGColor;
    self.messageContentView.layer.shadowOpacity=0.5;
    self.messageContentView.layer.shadowRadius=1;
    self.messageContentView.layer.shadowOffset=(CGSize){0,1};
    
    if(_titleLabel==nil){
        _titleLabel=[[UILabel alloc]init];
        [self.messageContentView addSubview:_titleLabel];
    }
    _titleLabel.text=@"学车预约";
    if(message.isCanceled){
        _titleLabel.text=@"学车取消";
    }
    _titleLabel.textColor=COLOR_TEXT_NORMAL;
    _titleLabel.font=FONT_TEXT_NORMAL;
    [_titleLabel fit];
    _titleLabel.origin=(CGPoint){5,5};
    
    if(_dateLabel==nil){
        _dateLabel=[[UILabel alloc]init];
        [self.messageContentView addSubview:_dateLabel];
    }
    _dateLabel.text=[Utility formatStringFromStringDate:message.courseDate withInputFormat:nil outputFormat:@"yyyy年MM月dd日"];
    _dateLabel.textColor=COLOR_TEXT_NORMAL;
    _dateLabel.font=FONT_TEXT_NORMAL;
    [_dateLabel fit];
    _dateLabel.origin=(CGPoint){_titleLabel.left+5,_titleLabel.bottom+3};
    
    if(_timeLabel==nil){
        _timeLabel=[[UILabel alloc]init];
        [self.messageContentView addSubview:_timeLabel];
    }
    _timeLabel.text=[NSString stringWithFormat:@"%@-%@",message.courseStarttime,message.courseEndtime];
    _timeLabel.textColor=COLOR_TEXT_NORMAL;
    _timeLabel.font=FONT_TEXT_NORMAL;
    [_timeLabel fit];
    _timeLabel.origin=(CGPoint){_dateLabel.left,_dateLabel.bottom+3};
    
    [self.messageContentView fitHeightOfSubviews];
    self.messageContentView.height+=5;
    
}

-(void)setModel:(RCMessageModel *)model{
    [super setModel:model];
    [self setNeedsLayout];
}

-(BOOL)isDisplayMessageTime{
    return true;
}
-(BOOL)isDisplayNickname{
    return true;
}
-(BOOL)isDisplayReadStatus{
    return true;
}

@end



