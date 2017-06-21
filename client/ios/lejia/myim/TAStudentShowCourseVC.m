//
//  TAStudentShowCourseVC.m
//  myim
//
//  Created by Sean Shi on 15/12/12.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TAStudentShowCourseVC.h"

@interface TAStudentShowCourseVC (){
    HeaderView* _headView;
    UIScrollView* _scrollView;


    UIView* _rootView;
    UIImageView* _headImage;
    UILabel* _timeLabel;
    UILabel* _courseLabel;
    UILabel* _studentNumLabel;
    UILabel* _remarkLabel;
    
    UILabel* _appointmentButton;
    
    BOOL _appointmented;

    Teacher* _teacher;
    NSString* _dateString;
    Course* _course;

}

@end

@implementation TAStudentShowCourseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}


-(void) reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@""
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:nil];
    [self.view addSubview:_headView];
    
    _scrollView=[[UIScrollView alloc]init];
    [_scrollView fillSuperview:self.view underOf:_headView];
    
    
//    [self checkStatus];
//    
//    static CGFloat topPadding=10;
//    static CGFloat linePadding=5;
//    
//    UIColor* bgColor=[UIColor whiteColor];
//    UIColor* textColor1=COLOR_TEXT_NORMAL;
//    UIColor* textColor2=COLOR_TEXT_SECONDARY;
//    
//    CGFloat fontSize1=(self.width-topPadding*2)/16;
//    CGFloat fontSize2=fontSize1*0.6;
//    
//    UIFont* font1=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize1] ;
//    UIFont* font2=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize2] ;
//    
//    
//    
//    
//    self.backgroundColor=UIColorFromRGBWithAlpha(0x000000,0.3);
//    
//    if(_rootView==nil){
//        _rootView=[[UIView alloc]init];
//        [self addSubview:_rootView];
//    }
//    _rootView.backgroundColor=bgColor;
//    _rootView.width=self.width*0.8;
//    _rootView.height=_rootView.width;
//    _rootView.center=_rootView.superview.innerCenterPoint;
//    
//    if(_teacherHeadImage==nil){
//        _teacherHeadImage=[[UIImageView alloc]init];
//        [_rootView addSubview:_teacherHeadImage];
//    }
//    CGFloat headImageWidth=(_rootView.width-topPadding*3)/3;
//    _teacherHeadImage.size=(CGSize){headImageWidth,headImageWidth};
//    _teacherHeadImage.origin=(CGPoint){topPadding,topPadding};
//    NSURL* headImageUrl=[NSURL URLWithString:_teacher.person.imageurl];
//    [_teacherHeadImage sd_setImageWithURL:headImageUrl placeholderImage:[UIImage imageNamed:@"缺省头像"]];
//    
//    
//    
//    if(_timeLabel==nil){
//        _timeLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_timeLabel];
//    }
//    _timeLabel.text=[NSString stringWithFormat:@"%@-%@",_course.starttime,_course.endtime];
//    _timeLabel.textColor=textColor1;
//    _timeLabel.font=font1;
//    [_timeLabel fit];
//    _timeLabel.left=_teacherHeadImage.right+topPadding;
//    _timeLabel.top=_teacherHeadImage.top;
//    
//    
//    if(_courseLabel==nil){
//        _courseLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_courseLabel];
//    }
//    _courseLabel.text=[Utility descInDict:[Storage teacherSkillDict] fromValue:_course.course];
//    _courseLabel.textColor=textColor2;
//    _courseLabel.font=font2;
//    [_courseLabel fit];
//    _courseLabel.left=_timeLabel.left;
//    _courseLabel.top=_timeLabel.bottom+linePadding;
//    
//    if(_studentNumLabel==nil){
//        _studentNumLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_studentNumLabel];
//    }
//    _studentNumLabel.text=[NSString stringWithFormat:@"%@/%@",_course.appointmentcount,_course.studentnum];
//    _studentNumLabel.textColor=textColor2;
//    _studentNumLabel.font=font2;
//    [_studentNumLabel fit];
//    _studentNumLabel.left=_courseLabel.left;
//    _studentNumLabel.top=_courseLabel.bottom+linePadding;
//    
//    if(_remarkLabel==nil){
//        _remarkLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_remarkLabel];
//    }
//    
//    
//    if(_appointmentButton==nil){
//        _appointmentButton=[UIUtility genButtonToSuperview:_rootView
//                                                       top:0
//                                                     title:@"预约"
//                                                    target:self
//                                                    action:@selector(appointment)];
//    }
//    NSString* buttonText=@"预约";
//    UITapGestureRecognizer* tap=_appointmentTap;
//    if(_appointmented){
//        tap=_cancelAppointmentTap;
//        buttonText=@"取消预约";
//    }
//    for (UIGestureRecognizer* g in _appointmentButton.gestureRecognizers){
//        [_appointmentButton removeGestureRecognizer:g];
//    }
//    [_appointmentButton addGestureRecognizer:tap];
//    _appointmentButton.text=buttonText;
//    _appointmentButton.bottom=_appointmentButton.superview.height-topPadding;
//    _appointmentButton.centerX=_appointmentButton.superview.width/2;
//    
//    NSString* remarkText=[NSString stringWithFormat:@"教练备注:\n%@",_course.remark];
//    _remarkLabel.text=remarkText;
//    _remarkLabel.textColor=textColor1;
//    _remarkLabel.font=font2;
//    _remarkLabel.numberOfLines=0;
//    [_remarkLabel fitWithWidth:_rootView.width-topPadding*2];
//    _remarkLabel.origin=(CGPoint){topPadding,_teacherHeadImage.bottom+linePadding};
//    _remarkLabel.width=_rootView.width-topPadding*2;
//    CGFloat h=_appointmentButton.top-linePadding-_remarkLabel.top;
//    _remarkLabel.height=_remarkLabel.height>h?(h>0?h:0):_remarkLabel.height;
    
    
}
@end
