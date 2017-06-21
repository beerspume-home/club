//
//  TAAppointmentInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/12/6.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TAAppointmentInfoVC.h"

@interface TAAppointmentInfoVC ()<StarViewDelegate>{
    HeaderView* _headView;
    
    UIImageView* _headImage;
    UILabel* _dateLabel;
    UILabel* _timeLabel;
    UILabel* _courseLabel;
    UILabel* _nameLabel;
    
    UIView* _teacherEvaluationView;
    UILabel* _teacherEvaluationTitleLabel;
    UILabel* _teacherEvaluationLabel;

    UIView* _studentEvaluationView;
    UILabel* _studentEvaluationTitleLabel;
    UILabel* _star1Label;
    StarView* _star1;
    UILabel* _star2Label;
    StarView* _star2;
    UILabel* _star3Label;
    StarView* _star3;
    UILabel* _studentEvaluationLabel;
    
    UIView* _addView;
    
    UIScrollView* _scrollView;
    
    NSString* _appointmentid;
    CourseAppointment* _appointment;
    
    NSString* _studentid;
    NSString* _teacherid;
    NSNumber* _index;


    NSString* _teacherEvaluationText;
    NSString* _studentEvaluationText;
    float _star1Value;
    float _star2Value;
    float _star3Value;
    BOOL _canEdit;
    
    UIView* _headRightButton;
}

@end

@implementation TAAppointmentInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
    [self reloadRemoteData];
    
}
-(void)reloadRemoteData{
    if(_appointment==nil){
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote appointment:_appointmentid callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _appointment=callback_data.data;
                [self processData];
                [self refreshView];
            }else{
                [Utility showError:callback_data.message];
            }
            [lv removeFromSuperview];
        }];
    }else{
        _appointmentid=_appointment.id;
        [self processData];
        [self refreshView];
    }
}
-(void)processData{
    if(_appointment!=nil){
        _teacherEvaluationText=nil;
        _studentEvaluationText=nil;
        _star1Value=0;
        _star2Value=0;
        _star3Value=0;
        _canEdit=false;
        if(_appointment.teacherevaluation!=nil){
            _teacherEvaluationText=_appointment.teacherevaluation.evaluation;
        }else if(_teacherid!=nil){
            _canEdit=true;
        }
        
        if(_appointment.studentevaluation!=nil){
            _studentEvaluationText=_appointment.studentevaluation.evaluation;
            _star1Value=_appointment.studentevaluation.star1==nil?0:_appointment.studentevaluation.star1.floatValue;
            _star2Value=_appointment.studentevaluation.star2==nil?0:_appointment.studentevaluation.star2.floatValue;
            _star3Value=_appointment.studentevaluation.star3==nil?0:_appointment.studentevaluation.star3.floatValue;
        }else if(_studentid!=nil){
            _canEdit=true;
        }
        
    }
}
-(void)reloadView{
    [super reloadView];
    _headView =[[HeaderView alloc]initWithTitle:@"约车记录"
                                     leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                    rightButton:nil];
    [self.view addSubview:_headView];
    if(_headRightButton==nil){
        _headRightButton=[HeaderView genItemWithText:@"保存" target:self action:@selector(save:)];
    }
    if(_addView==nil){
        static CGFloat padding=10;
        CGFloat iconWidth=self.view.width*0.04;
        _addView=[[UIView alloc]init];
        UIImageView* addIcon=[[UIImageView alloc]init];
        [_addView addSubview:addIcon];
        addIcon.image=[[UIImage imageNamed:@"添加_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        addIcon.origin=(CGPoint){padding,padding};
        addIcon.size=(CGSize){iconWidth,iconWidth};
        addIcon.tintColor=COLOR_SPLIT;
        UILabel* addLabel=[[UILabel alloc]init];
        [_addView addSubview:addLabel];
        addLabel.text=@"点击添加评价";
        addLabel.textColor=COLOR_SPLIT;
        addLabel.font=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:iconWidth];
        [addLabel fit];
        addLabel.left=addIcon.right+10;
        addLabel.centerY=addIcon.centerY;
        
        [_addView fitSizeOfSubviews];
        _addView.width+=padding;
        _addView.height+=padding;
        _addView.layer.borderColor=COLOR_SPLIT.CGColor;
        _addView.layer.borderWidth=1;
        _addView.layer.cornerRadius=5;
    }
    
    
    [self refreshView];
}

-(void)refreshView{
    if(_appointment!=nil){
        if(_canEdit){
            _headView.rightBarItem=_headRightButton;
        }else{
            _headView.rightBarItem=nil;
        }
        
        if(_scrollView==nil){
            _scrollView=[[UIScrollView alloc]init];
            [_scrollView fillSuperview:self.view underOf:_headView];
            _scrollView.backgroundColor=[UIColor whiteColor];
        }

        NSURL* headImgUrl=nil;
        NSString* name=nil;
        
        if(_studentid!=nil){
            headImgUrl=[NSURL URLWithString:_appointment.teacher.person.imageurl];
            name=[NSString stringWithFormat:@"教练:%@",_appointment.teacher.person.name];
        }else if(_teacherid!=nil){
            headImgUrl=[NSURL URLWithString:_appointment.student.person.imageurl];
            name=[NSString stringWithFormat:@"学员:%@",_appointment.student.person.name];
        }
        [_headImage sd_setImageWithURL:headImgUrl placeholderImage:[UIImage imageNamed:@"缺省头像"]];

        
        if(_headImage==nil){
            _headImage=[[UIImageView alloc]init];
            [_scrollView addSubview:_headImage];
            _headImage.size=(CGSize){60,60};
            _headImage.origin=(CGPoint){15,12};
            _headImage.layer.shadowColor=[UIColor blackColor].CGColor;
            _headImage.layer.shadowOpacity=0.5;
            _headImage.layer.shadowRadius=1;
            _headImage.layer.shadowOffset=(CGSize){0,1};
        }
        
        
        if(_nameLabel==nil){
            _nameLabel=[[UILabel alloc]init];
            [_scrollView addSubview:_nameLabel];
        }
        _nameLabel.text=name;
        _nameLabel.textColor=COLOR_TEXT_NORMAL;
        _nameLabel.font=FONT_TEXT_SECONDARY;
        [_nameLabel fit];
        _nameLabel.top=_headImage.bottom+3;
        _nameLabel.centerX=_headImage.centerX;
        
        
        if(_dateLabel==nil){
            _dateLabel=[[UILabel alloc]init];
            [_scrollView addSubview:_dateLabel];
        }
        _dateLabel.text=[NSString stringWithFormat:@"练习日期:%@",
                         [Utility formatStringFromStringDate:_appointment.date withInputFormat:nil outputFormat:@"yyyy年MM月dd日"]];
        _dateLabel.textColor=COLOR_TEXT_NORMAL;
        _dateLabel.font=FONT_TEXT_NORMAL;
        [_dateLabel fit];
        _dateLabel.left=_headImage.right+10;
        _dateLabel.top=_headImage.top;
        
        if(_timeLabel==nil){
            _timeLabel=[[UILabel alloc]init];
            [_scrollView addSubview:_timeLabel];
        }
        _timeLabel.text=[NSString stringWithFormat:@"课时段:%@-%@",
                         _appointment.course.starttime,_appointment.course.endtime];
        _timeLabel.textColor=COLOR_TEXT_NORMAL;
        _timeLabel.font=FONT_TEXT_NORMAL;
        [_timeLabel fit];
        _timeLabel.left=_dateLabel.left;
        _timeLabel.top=_dateLabel.bottom+3;

        if(_courseLabel==nil){
            _courseLabel=[[UILabel alloc]init];
            [_scrollView addSubview:_courseLabel];
        }
        _courseLabel.text=[NSString stringWithFormat:@"练习科目:%@",
                         [Utility descInDict:[Storage teacherSkillDict] fromValue:_appointment.course.course]];
        _courseLabel.textColor=COLOR_TEXT_NORMAL;
        _courseLabel.font=FONT_TEXT_NORMAL;
        [_courseLabel fit];
        _courseLabel.left=_timeLabel.left;
        _courseLabel.top=_timeLabel.bottom+3;
        
        
        //教练评价部分
        if(_teacherEvaluationView==nil){
            _teacherEvaluationView=[[UIView alloc]init];
            [_scrollView addSubview:_teacherEvaluationView];
        }
        if(_teacherEvaluationTitleLabel==nil){
            _teacherEvaluationTitleLabel=[[UILabel alloc]init];
            [_teacherEvaluationView addSubview:_teacherEvaluationTitleLabel];
        }
        if(_teacherEvaluationLabel==nil){
            _teacherEvaluationLabel=[[UILabel alloc]init];
            [_teacherEvaluationView addSubview:_teacherEvaluationLabel];
        }
        //学员评价部分
        if(_studentEvaluationView==nil){
            _studentEvaluationView=[[UIView alloc]init];
            [_scrollView addSubview:_studentEvaluationView];
        }
        if(_studentEvaluationTitleLabel==nil){
            _studentEvaluationTitleLabel=[[UILabel alloc]init];
            [_studentEvaluationView addSubview:_studentEvaluationTitleLabel];
        }
        if(_star1Label==nil){
            _star1Label=[[UILabel alloc]init];
            [_studentEvaluationView addSubview:_star1Label];
        }
        if(_star2Label==nil){
            _star2Label=[[UILabel alloc]init];
            [_studentEvaluationView addSubview:_star2Label];
        }
        if(_star3Label==nil){
            _star3Label=[[UILabel alloc]init];
            [_studentEvaluationView addSubview:_star3Label];
        }
        if(_star1==nil){
            _star1=[[StarView alloc]init];
            _star1.delegate=self;
            [_studentEvaluationView addSubview:_star1];
        }
        if(_star2==nil){
            _star2=[[StarView alloc]init];
            _star2.delegate=self;
            [_studentEvaluationView addSubview:_star2];
        }
        if(_star3==nil){
            _star3=[[StarView alloc]init];
            _star3.delegate=self;
            [_studentEvaluationView addSubview:_star3];
        }
        if(_studentEvaluationLabel==nil){
            _studentEvaluationLabel=[[UILabel alloc]init];
            [_studentEvaluationView addSubview:_studentEvaluationLabel];
        }

        CGFloat maxWidth=_headImage.superview.width-_headImage.left*2-10;

        [_addView removeFromSuperview];
        _addView.hidden=true;
        //学员查看
        if(_studentid!=nil){
            
            //教练评价
            _teacherEvaluationView.hidden=false;

            _teacherEvaluationTitleLabel.text=@"教练点评";
            _teacherEvaluationTitleLabel.textColor=COLOR_TEXT_NORMAL;
            _teacherEvaluationTitleLabel.font=FONT_TEXT_NORMAL;
            [_teacherEvaluationTitleLabel fit];
            _teacherEvaluationTitleLabel.origin=(CGPoint){_headImage.left,0};

            if(_teacherEvaluationText==nil){
                _teacherEvaluationLabel.text=@"教练尚未点评";
            }else{
                _teacherEvaluationLabel.text=_teacherEvaluationText;
            }
            _teacherEvaluationLabel.textColor=COLOR_TEXT_HIGHLIGHT;
            _teacherEvaluationLabel.font=FONT_TEXT_SECONDARY;
            _teacherEvaluationLabel.numberOfLines=0;
            [_teacherEvaluationLabel fitWithWidth:maxWidth];
            _teacherEvaluationLabel.origin=(CGPoint){_teacherEvaluationTitleLabel.left+10,_teacherEvaluationTitleLabel.bottom+5};
            
            _teacherEvaluationView.origin=(CGPoint){0,_nameLabel.bottom+20};
            _teacherEvaluationView.width=_teacherEvaluationView.superview.width;
            [_teacherEvaluationView fitHeightOfSubviews];
            
            
            //学员评价
            _studentEvaluationView.hidden=false;
            
            _studentEvaluationTitleLabel.text=@"评价教练:";
            _studentEvaluationTitleLabel.textColor=COLOR_TEXT_NORMAL;
            _studentEvaluationTitleLabel.font=FONT_TEXT_NORMAL;
            [_studentEvaluationTitleLabel fit];
            _studentEvaluationTitleLabel.origin=(CGPoint){_teacherEvaluationTitleLabel.left,0};

            //服务态度评星
            _star1Label.text=@"服务态度";
            _star1Label.textColor=COLOR_TEXT_NORMAL;
            _star1Label.font=FONT_TEXT_NORMAL;
            [_star1Label fit];
            _star1Label.origin=(CGPoint){_studentEvaluationTitleLabel.left,_studentEvaluationTitleLabel.bottom+25};
            
            _star1.maxvalue=5;
            _star1.value=_star1Value;
            _star1.iconSize=_star1Label.font.pointSize*2;
            _star1.iconPadding=10;
            _star1.editable=_canEdit;
            [_star1 reloadView];
            _star1.left=_star1Label.right+20;
            _star1.centerY=_star1Label.centerY;

    
            //教学水平评星
            _star2Label.text=@"教学水平";
            _star2Label.textColor=COLOR_TEXT_NORMAL;
            _star2Label.font=FONT_TEXT_NORMAL;
            [_star2Label fit];
            _star2Label.origin=(CGPoint){_star1Label.left,_star1Label.bottom+25};
            
            _star2.maxvalue=5;
            _star2.value=_star2Value;
            _star2.iconSize=_star2Label.font.pointSize*2;
            _star2.iconPadding=10;
            _star2.editable=_canEdit;
            [_star2 reloadView];
            _star2.left=_star2Label.right+20;
            _star2.centerY=_star2Label.centerY;

            
            //车内整洁评星
            _star3Label.text=@"车内整洁";
            _star3Label.textColor=COLOR_TEXT_NORMAL;
            _star3Label.font=FONT_TEXT_NORMAL;
            [_star3Label fit];
            _star3Label.origin=(CGPoint){_star2Label.left,_star2Label.bottom+25};
            
            _star3.maxvalue=5;
            _star3.value=_star3Value;
            _star3.iconSize=_star3Label.font.pointSize*2;
            _star3.iconPadding=10;
            _star3.editable=_canEdit;
            [_star3 reloadView];
            _star3.left=_star3Label.right+20;
            _star3.centerY=_star3Label.centerY;
            
            if(!_canEdit || ![Utility isEmptyString:_studentEvaluationText]){
                _studentEvaluationLabel.hidden=false;
                _studentEvaluationLabel.text=_studentEvaluationText;
                _studentEvaluationLabel.textColor=COLOR_TEXT_HIGHLIGHT;
                _studentEvaluationLabel.font=FONT_TEXT_SECONDARY;
                _studentEvaluationLabel.numberOfLines=0;
                [_studentEvaluationLabel fitWithWidth:maxWidth];
                _studentEvaluationLabel.width=maxWidth;
                _studentEvaluationLabel.origin=(CGPoint){_teacherEvaluationLabel.left,_star3.bottom+25};
                if(_canEdit){
                    _studentEvaluationLabel.userInteractionEnabled=true;
                    [_studentEvaluationLabel setGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addStudentEvaluation:)]];

                }else{
                    _studentEvaluationLabel.userInteractionEnabled=false;
                    [_studentEvaluationLabel removeAllGestureRecognizer];
                }
                
            }else{
                _studentEvaluationLabel.hidden=true;
                [_addView removeFromSuperview];
                [_studentEvaluationView addSubview:_addView];
                _addView.hidden=false;
                [_addView setGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addStudentEvaluation:)]];
                
                _addView.top=_star3.bottom+25;
                _addView.centerX=_addView.superview.width/2;
                
            }

            _studentEvaluationView.origin=(CGPoint){0,_teacherEvaluationView.bottom+20};
            _studentEvaluationView.width=_studentEvaluationView.superview.width;
            [_studentEvaluationView fitHeightOfSubviews];

        }else if(_teacherid!=nil){
            //教练评价
            _teacherEvaluationView.hidden=false;
            
            _teacherEvaluationTitleLabel.text=@"教练点评";
            _teacherEvaluationTitleLabel.textColor=COLOR_TEXT_NORMAL;
            _teacherEvaluationTitleLabel.font=FONT_TEXT_NORMAL;
            [_teacherEvaluationTitleLabel fit];
            _teacherEvaluationTitleLabel.origin=(CGPoint){_headImage.left,0};
            
            
            if(!_canEdit || ![Utility isEmptyString:_teacherEvaluationText]){
                _teacherEvaluationLabel.hidden=false;
                _teacherEvaluationLabel.text=_teacherEvaluationText;
                _teacherEvaluationLabel.textColor=COLOR_TEXT_HIGHLIGHT;
                _teacherEvaluationLabel.font=FONT_TEXT_SECONDARY;
                _teacherEvaluationLabel.numberOfLines=0;
                [_teacherEvaluationLabel fitWithWidth:maxWidth];
                _teacherEvaluationLabel.width=maxWidth;
                _teacherEvaluationLabel.origin=(CGPoint){_teacherEvaluationTitleLabel.left+10,_teacherEvaluationTitleLabel.bottom+5};
                
                if(_canEdit){
                    _teacherEvaluationLabel.userInteractionEnabled=true;
                    [_teacherEvaluationLabel setGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addTeacherEvaluation:)]];
                    
                }else{
                    _teacherEvaluationLabel.userInteractionEnabled=false;
                    [_teacherEvaluationLabel removeAllGestureRecognizer];
                }
                
            }else{
                _teacherEvaluationLabel.hidden=true;
                [_addView removeFromSuperview];
                [_teacherEvaluationView addSubview:_addView];
                _addView.hidden=false;
                [_addView setGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addTeacherEvaluation:)]];
                
                _addView.top=_teacherEvaluationTitleLabel.left+10;
                _addView.centerX=_addView.superview.width/2;
                
            }
            
            _teacherEvaluationView.origin=(CGPoint){0,_nameLabel.bottom+20};
            _teacherEvaluationView.width=_teacherEvaluationView.superview.width;
            [_teacherEvaluationView fitHeightOfSubviews];
            
            
            //学员评价
            _studentEvaluationView.hidden=true;
        }
    
        [_scrollView fitContentHeightWithPadding:10];
    }
    
}

-(void)addStudentEvaluation:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"评价",
                                                               PAGE_PARAM_PLACEHOLDER:@"请输入评价内容",
                                                               PAGE_PARAM_ORIGIN_VALUE:_studentEvaluationText==nil?@"":_studentEvaluationText,
                                                               PAGE_PARAM_TYPE:@"student_evaluation",
                                                               PAGE_PARAM_INPUTTYPE:CHANGEVALUE_INPUTTYPE_Default,
                                                               }];
}
-(void)addTeacherEvaluation:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"评价",
                                                               PAGE_PARAM_PLACEHOLDER:@"请输入评价内容",
                                                               PAGE_PARAM_ORIGIN_VALUE:_teacherEvaluationText==nil?@"":_teacherEvaluationText,
                                                               PAGE_PARAM_TYPE:@"teacher_evaluation",
                                                               PAGE_PARAM_INPUTTYPE:CHANGEVALUE_INPUTTYPE_Default,
                                                               }];
}

-(void)save:(UIGestureRecognizer*)sender{
    CourseAppointmentEvaluation* evaluation=nil;
    NSString* who=nil;
    BOOL completed=true;
    if(_studentid!=nil){
        evaluation=_appointment.studentevaluation;
        who=@"student";
        
        if(_star1Value==0){
            [Utility showError:@"请评价服务态度"];
            completed=false;
        }
        if(_star2Value==0){
            [Utility showError:@"请评价教学水平"];
            completed=false;
        }
        if(_star3Value==0){
            [Utility showError:@"请评价车内整洁"];
            completed=false;
        }
        if([Utility isEmptyString:_studentEvaluationText]){
            [Utility showError:@"请写评价内容"];
            completed=false;
        }
    }
    if(_teacherid!=nil){
        evaluation=_appointment.teacherevaluation;
        who=@"teacher";
        if([Utility isEmptyString:_teacherEvaluationText]){
            [Utility showError:@"请写评价内容"];
            completed=false;
        }
    }
    if(completed){
        if(evaluation==nil){
            evaluation=[[CourseAppointmentEvaluation alloc]init];
            evaluation.appointment=_appointment.id;
        }
        if(_studentid!=nil){
            evaluation.star1=[NSNumber numberWithFloat:_star1Value];
            evaluation.star2=[NSNumber numberWithFloat:_star2Value];
            evaluation.star3=[NSNumber numberWithFloat:_star3Value];
            evaluation.evaluation=_studentEvaluationText;
        }else if(_teacherid!=nil){
            evaluation.evaluation=_teacherEvaluationText;
        }
        
        
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote updateAppointmentEvaluation:evaluation who:who callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [self gotoBackWithParamaters:@{
                                               PAGE_PARAM_RETURN_VALUE:@{
                                                       PAGE_PARAM_TYPE:@"evaluation",
                                                       PAGE_PARAM_APPOINTMENT:callback_data.data,
                                                       PAGE_PARAM_INDEX:_index==nil?@-1:_index,
                                                       }
                                               }];
            }else{
                [Utility showError:callback_data.message];
            }
            [lv removeFromSuperview];
        }];
    }
    
}

-(void)starView:(StarView *)starView didChangeValue:(float)value{
    if(starView==_star1){
        _star1Value=value;
    }else if(starView==_star2){
        _star2Value=value;
    }else if(starView==_star3){
        _star3Value=value;
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_APPOINTMENT_ID isEqualToString:key]){
        _appointmentid=value;
    }else if([PAGE_PARAM_APPOINTMENT isEqualToString:key]){
        _appointment=value;
    }else if([PAGE_PARAM_STUDENT_ID isEqualToString:key]){
        _studentid=value;
    }else if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }else if([PAGE_PARAM_INDEX isEqualToString:key]){
        _index=value;
    }else if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([@"student_evaluation" isEqualToString:value[PAGE_PARAM_TYPE]]){
            _studentEvaluationText=value[PAGE_PARAM_RETURN_VALUE];
            [self refreshView];
        }else if([@"teacher_evaluation" isEqualToString:value[PAGE_PARAM_TYPE]]){
            _teacherEvaluationText=value[PAGE_PARAM_RETURN_VALUE];
            [self refreshView];
        }
    }
}
@end
