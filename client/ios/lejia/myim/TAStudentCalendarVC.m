//
//  TAStudentCalendarVC.m
//  myim
//
//  Created by Sean Shi on 15/11/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TAStudentCalendarVC.h"
#import "Utility+Date.h"

#pragma mark WeekDayView
@interface WeekdayView : UIView
@end
@protocol WeekdayViewDelegate <NSObject>

@required
-(void)weekdayView:(WeekdayView*)weekdayView onTap:(UIGestureRecognizer*)sender;

@end
@interface WeekdayView(){
    UILabel* _weekdayLabel;
    UILabel* _dateLabel;
}
@property (nonatomic,retain) NSDate* date;
@property (nonatomic,retain) id<WeekdayViewDelegate> delegate;
@property (nonatomic,assign) BOOL selected;

@end

@implementation WeekdayView

-(void)setSelected:(BOOL)selected{
    _selected=selected;
    [self setNeedsLayout];
}

-(instancetype)init{
    WeekdayView* ret=[super init];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    return ret;
}

-(void)layoutSubviews{
    NSString* dateString=[Utility formatStringFromDate:_date withFormat:@"MM月dd日"];
    NSString* weekdayString=[Utility weekdayStringFromDate:_date];
    
    UIColor* bgColor=[UIColor whiteColor];
    UIColor* textColor=COLOR_TEXT_NORMAL;
    if(_selected){
        bgColor=UIColorFromRGB(0x3aa5de);
        textColor=[UIColor whiteColor];
    }
    
    
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOpacity=0.5;
    self.layer.shadowRadius=0.5;
    self.layer.shadowOffset=(CGSize){0,0.5};
    self.backgroundColor=bgColor;
    
    if(_weekdayLabel==nil){
        _weekdayLabel=[[UILabel alloc]init];
        [self addSubview:_weekdayLabel];
    }
    _weekdayLabel.text=weekdayString;
    _weekdayLabel.textColor=textColor;
    _weekdayLabel.font=FONT_TEXT_NORMAL;
    [_weekdayLabel fit];
    
    if(_dateLabel==nil){
        _dateLabel=[[UILabel alloc]init];
        [self addSubview:_dateLabel];
    }
    _dateLabel.text=dateString;
    _dateLabel.textColor=textColor;
    _dateLabel.font=FONT_TEXT_SECONDARY;
    [_dateLabel fit];
    
    _weekdayLabel.center=_weekdayLabel.superview.innerCenterPoint;
    _weekdayLabel.top-=(_dateLabel.height+3)/2;
    _dateLabel.centerX=_weekdayLabel.centerX;
    _dateLabel.top=_weekdayLabel.bottom+3;
    
}

-(void)tap:(UITapGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate weekdayView:self onTap:sender];
    }
}
@end


#pragma mark CalendarView
@interface CalendarView : UIControl
@end
@protocol CalendarViewDelegate <NSObject>

@required
-(void)calendarView:(CalendarView*)calendarView onTap:(UIGestureRecognizer*)sender;
-(BOOL)calendarView:(CalendarView*)courseDetailView hadAppointmented:(id)data;
@end
@interface CalendarView(){
    UILabel* _timeLabel;
    UILabel* _courseLabel;
    UILabel* _studentNumLabel;
    UILabel* _statusLabel;
    
    BOOL _touchDown;
}
@property (nonatomic,retain) NSString* dateString;
@property (nonatomic,retain) Course* course;
@property (nonatomic,retain) id<CalendarViewDelegate> delegate;
@property (nonatomic,readonly) BOOL timeExpired;
@property (nonatomic,readonly) BOOL isFull;
@property (nonatomic,readonly) BOOL appointmented;

@end

@implementation CalendarView

-(void)checkExpired{
    @try {
        NSString* a=[NSString stringWithFormat:@"%@ %@:00",_dateString,_course.starttime];
        NSDate* datetime=[Utility parseDateFromString:a withFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate* now=[NSDate date];
        if([now compare:datetime]==NSOrderedDescending){
            _timeExpired=true;
        }else{
            _timeExpired=false;
        }
        
    }
    @catch (NSException *exception) {
        _timeExpired=false;
    }
    @finally {
    }
}
-(void)checkFull{
    @try {
        _isFull=_course.appointmentcount.intValue>=_course.studentnum.intValue;
    }
    @catch (NSException *exception) {
        _isFull=false;
    }
    @finally {
    }
    
}
-(void)checkAppointmented{
    if(_delegate!=nil){
        _appointmented=[_delegate calendarView:self hadAppointmented:nil];
    }
}
-(void)checkStatus{
    [self checkExpired];
    [self checkFull];
    [self checkAppointmented];
}

-(void)setDateString:(NSString *)dateString{
    _dateString=dateString;
    [self setNeedsLayout];
}
-(void)setCourse:(Course *)course{
    _course=course;
    [self setNeedsLayout];
}

-(void)touchDown{
    _touchDown=true;
    [self setNeedsLayout];
}

-(void)touchUpOutside{
    _touchDown=false;
    [self setNeedsLayout];
}
-(void)touchUpInside{
    _touchDown=false;
    [self setNeedsLayout];
    if(_delegate!=nil){
        [_delegate calendarView:self onTap:nil];
    }
}


-(instancetype)init{
    CalendarView* ret=[super init];
    [self addTarget:self action:@selector(touchDown) forControlEvents:UIControlEventTouchDown];
    [self addTarget:self action:@selector(touchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(touchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    return ret;
}
-(void)layoutSubviews{
    [self checkStatus];

    UIColor* bgColor=[UIColor whiteColor];
    UIColor* textColor1=COLOR_TEXT_NORMAL;
    UIColor* textColor2=COLOR_TEXT_SECONDARY;
    if(_timeExpired || _isFull || _appointmented){
        bgColor=COLOR_SPLIT;
    }else if(_touchDown){
        bgColor=UIColorFromRGB(0x3aa5de);
        textColor1=[UIColor whiteColor];
        textColor2=textColor1;
    }
    
    CGFloat fontSize1=(self.width)*0.14;
    CGFloat fontSize2=fontSize1*0.8;
    
    UIFont* font1=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize1] ;
    UIFont* font2=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize2] ;
    
    CGFloat topPadding=self.width*0.06;
    CGFloat linePadding=topPadding;
    
    
    
    
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowOpacity=0.5;
    self.layer.shadowRadius=0.5;
    self.layer.shadowOffset=(CGSize){0,0.5};
    self.backgroundColor=bgColor;
    
    if(_timeLabel==nil){
        _timeLabel=[[UILabel alloc]init];
        [self addSubview:_timeLabel];
    }
    _timeLabel.text=[NSString stringWithFormat:@"%@-%@",_course.starttime,_course.endtime];
    _timeLabel.textColor=textColor1;
    _timeLabel.font=font1;
    [_timeLabel fit];
    _timeLabel.centerX=_timeLabel.superview.width/2;
    _timeLabel.top=topPadding;
    

    if(_courseLabel==nil){
        _courseLabel=[[UILabel alloc]init];
        [self addSubview:_courseLabel];
    }
    _courseLabel.text=[Utility descInDict:[Storage teacherSkillDict] fromValue:_course.course];
    _courseLabel.textColor=textColor2;
    _courseLabel.font=font2;
    [_courseLabel fit];
    _courseLabel.centerX=_timeLabel.centerX;
    _courseLabel.top=_timeLabel.bottom+linePadding;
    
    if(_studentNumLabel==nil){
        _studentNumLabel=[[UILabel alloc]init];
        [self addSubview:_studentNumLabel];
    }
    _studentNumLabel.text=[NSString stringWithFormat:@"%@/%@",_course.appointmentcount,_course.studentnum];
    _studentNumLabel.textColor=textColor2;
    _studentNumLabel.font=font2;
    [_studentNumLabel fit];
    _studentNumLabel.centerX=_courseLabel.centerX;
    _studentNumLabel.top=_courseLabel.bottom+linePadding;
 
    if(_statusLabel==nil){
        _statusLabel=[[UILabel alloc]init];
        [self addSubview:_statusLabel];
    }
    _statusLabel.text=_timeExpired?@"时间已过":_appointmented?@"已预约":_isFull?@"已约满":@"";
    _statusLabel.textColor=textColor2;
    _statusLabel.font=font2;
    [_statusLabel fit];
    _statusLabel.centerX=_studentNumLabel.centerX;
    _statusLabel.top=_studentNumLabel.bottom+linePadding;
}

-(void)tap:(UITapGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate calendarView:self onTap:sender];
    }
}
@end


#pragma mark CourseDetailView
@interface CourseDetailView : UIControl
@end
@protocol CourseDetailViewDelegate <NSObject>
-(void)courseDetailView:(CourseDetailView*)courseDetailView appointment:(id)data;
-(void)courseDetailView:(CourseDetailView*)courseDetailView cancelAppointment:(id)data;
-(BOOL)courseDetailView:(CourseDetailView*)courseDetailView hadAppointmented:(id)data;
@end
@interface CourseDetailView(){
    UIView* _rootView;
    UIImageView* _teacherHeadImage;
    UILabel* _timeLabel;
    UILabel* _courseLabel;
    UILabel* _studentNumLabel;
    UILabel* _remarkLabel;

    UILabel* _appointmentButton;
    
    BOOL _appointmented;

    UITapGestureRecognizer* _appointmentTap;
    UITapGestureRecognizer* _cancelAppointmentTap;
}
@property (nonatomic,retain) Teacher* teacher;
@property (nonatomic,retain) NSString* dateString;
@property (nonatomic,retain) Course* course;
@property (nonatomic,retain) id<CourseDetailViewDelegate> delegate;

@end

@implementation CourseDetailView

-(void)checkStatus{
    _appointmented=[_delegate courseDetailView:self hadAppointmented:nil];
}

-(void)setTeacher:(Teacher *)teacher{
    _teacher=teacher;
    [self setNeedsLayout];
}

-(void)setDateString:(NSString *)dateString{
    _dateString=dateString;
    [self setNeedsLayout];
}
-(void)setCourse:(Course *)course{
    _course=course;
    [self setNeedsLayout];
}

-(instancetype)init{
    CourseDetailView* ret=[super init];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    _appointmentTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(appointment)];
    _cancelAppointmentTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelAppointment)];

    return ret;
}
-(void)layoutSubviews{
    [self checkStatus];
    
    static CGFloat topPadding=10;
    static CGFloat linePadding=5;

    UIColor* bgColor=[UIColor whiteColor];
    UIColor* textColor1=COLOR_TEXT_NORMAL;
    UIColor* textColor2=COLOR_TEXT_SECONDARY;
    
    CGFloat fontSize1=(self.width-topPadding*2)/16;
    CGFloat fontSize2=fontSize1*0.6;
    
    UIFont* font1=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize1] ;
    UIFont* font2=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:fontSize2] ;
    
    
    
    
    self.backgroundColor=UIColorFromRGBWithAlpha(0x000000,0.3);

    if(_rootView==nil){
        _rootView=[[UIView alloc]init];
        [self addSubview:_rootView];
    }
    _rootView.backgroundColor=bgColor;
    _rootView.width=self.width*0.8;
    _rootView.height=_rootView.width;
    _rootView.center=_rootView.superview.innerCenterPoint;
    
    if(_teacherHeadImage==nil){
        _teacherHeadImage=[[UIImageView alloc]init];
        [_rootView addSubview:_teacherHeadImage];
    }
    CGFloat headImageWidth=(_rootView.width-topPadding*3)/3;
    _teacherHeadImage.size=(CGSize){headImageWidth,headImageWidth};
    _teacherHeadImage.origin=(CGPoint){topPadding,topPadding};
    NSURL* headImageUrl=[NSURL URLWithString:_teacher.person.imageurl];
    [_teacherHeadImage sd_setImageWithURL:headImageUrl placeholderImage:[UIImage imageNamed:@"缺省头像"]];
    
    
    
    if(_timeLabel==nil){
        _timeLabel=[[UILabel alloc]init];
        [_rootView addSubview:_timeLabel];
    }
    _timeLabel.text=[NSString stringWithFormat:@"%@-%@",_course.starttime,_course.endtime];
    _timeLabel.textColor=textColor1;
    _timeLabel.font=font1;
    [_timeLabel fit];
    _timeLabel.left=_teacherHeadImage.right+topPadding;
    _timeLabel.top=_teacherHeadImage.top;
    
    
    if(_courseLabel==nil){
        _courseLabel=[[UILabel alloc]init];
        [_rootView addSubview:_courseLabel];
    }
    _courseLabel.text=[Utility descInDict:[Storage teacherSkillDict] fromValue:_course.course];
    _courseLabel.textColor=textColor2;
    _courseLabel.font=font2;
    [_courseLabel fit];
    _courseLabel.left=_timeLabel.left;
    _courseLabel.top=_timeLabel.bottom+linePadding;
    
    if(_studentNumLabel==nil){
        _studentNumLabel=[[UILabel alloc]init];
        [_rootView addSubview:_studentNumLabel];
    }
    _studentNumLabel.text=[NSString stringWithFormat:@"%@/%@",_course.appointmentcount,_course.studentnum];
    _studentNumLabel.textColor=textColor2;
    _studentNumLabel.font=font2;
    [_studentNumLabel fit];
    _studentNumLabel.left=_courseLabel.left;
    _studentNumLabel.top=_courseLabel.bottom+linePadding;
    
    if(_remarkLabel==nil){
        _remarkLabel=[[UILabel alloc]init];
        [_rootView addSubview:_remarkLabel];
    }
    
    
    if(_appointmentButton==nil){
        _appointmentButton=[UIUtility genButtonToSuperview:_rootView
                                                       top:0
                                                     title:@"预约"
                                                    target:self
                                                    action:@selector(appointment)];
    }
    NSString* buttonText=@"预约";
    UITapGestureRecognizer* tap=_appointmentTap;
    if(_appointmented){
        tap=_cancelAppointmentTap;
        buttonText=@"取消预约";
    }
    for (UIGestureRecognizer* g in _appointmentButton.gestureRecognizers){
        [_appointmentButton removeGestureRecognizer:g];
    }
    [_appointmentButton addGestureRecognizer:tap];
    _appointmentButton.text=buttonText;
    _appointmentButton.bottom=_appointmentButton.superview.height-topPadding;
    _appointmentButton.centerX=_appointmentButton.superview.width/2;
    
    NSString* remarkText=[NSString stringWithFormat:@"教练备注:\n%@",_course.remark];
    _remarkLabel.text=remarkText;
    _remarkLabel.textColor=textColor1;
    _remarkLabel.font=font2;
    _remarkLabel.numberOfLines=0;
    [_remarkLabel fitWithWidth:_rootView.width-topPadding*2];
    _remarkLabel.origin=(CGPoint){topPadding,_teacherHeadImage.bottom+linePadding};
    _remarkLabel.width=_rootView.width-topPadding*2;
    CGFloat h=_appointmentButton.top-linePadding-_remarkLabel.top;
    _remarkLabel.height=_remarkLabel.height>h?(h>0?h:0):_remarkLabel.height;
}

-(void)tap:(UITapGestureRecognizer*)sender{
    CGPoint p=[sender locationInView:self];
    if(!CGRectContainsPoint(_rootView.frame, p)){
        self.hidden=true;
    }
}


-(void)appointment{
    if(_delegate){
        [_delegate courseDetailView:self appointment:nil];
    }
}

-(void)cancelAppointment{
    if(_delegate){
        [_delegate courseDetailView:self cancelAppointment:nil];
    }
}
@end

#pragma mark ViewController
@interface TAStudentCalendarVC ()<WeekdayViewDelegate,CalendarViewDelegate,CourseDetailViewDelegate>{
    HeaderView* _headView;
    UIScrollView* _weekScrollView;
    UIScrollView* _calendarScrollView;
    
    NSDate* _startDate;
    NSString* _startDateString;
    
    NSMutableArray<WeekdayView*>* _weekdayViews;
    WeekdayView* _selectedWeekdayView;
    NSString*   _selectedDate;

    NSMutableArray<CalendarView*>* _calendarViews;
    CalendarView* _selectedCalendarView;
    
    CourseDetailView* _courseDetailView;

    NSString* _teacherid;
    NSString* _studentid;
    Teacher* _teacher;
    
    NSMutableArray<NSMutableDictionary*>* _dateCourse;
    NSMutableArray<CourseAppointment*>* _appointment;
}

@end




@implementation TAStudentCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _startDate=[NSDate date];
    _dateCourse=[Utility initArray:nil];
    [self getTeacherFromRemote];
    [self reloadView];
    [self reloadRemoteData];
}
-(void)getTeacherFromRemote{
    if(_teacher==nil && ![Utility isEmptyString:_teacherid]){
        [Remote teacher:_teacherid callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _teacher=callback_data.data;
            }
        }];
    }else if(_teacher!=nil && [Utility isEmptyString:_teacherid]){
        _teacherid=_teacher.id;
    }
    
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote appointmentCalendar:_teacherid studentid:_studentid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _dateCourse=[Utility initArray:nil];
            NSArray<NSDictionary*>* dateCourse=callback_data.data[@"date"];
            for(NSDictionary* dc in dateCourse){
                NSMutableDictionary* a=[Utility initDictionary:nil];
                [a setObject:dc[@"date"] forKey:@"date"];
                
                NSArray<NSDictionary*>* course=dc[@"course"];
                NSMutableArray<Course*>* b=[Utility initArray:nil];
                for(int i=0;i<course.count;i++){
                    [b addObject:[Course initWithDictionary:course[i]]];
                }
                [b sortUsingComparator:^NSComparisonResult(Course*  _Nonnull obj1, Course*  _Nonnull obj2) {
                    return [obj1.starttime compare:obj2.starttime];
                }];
                [a setObject:b forKey:@"course"];
                
                [_dateCourse addObject:a];
            }
            
            NSArray<NSDictionary*>* c=callback_data.data[@"appointment"];
            _appointment=[Utility initArray:nil];
            for(NSDictionary* v in c){
                [_appointment addObject:[CourseAppointment initWithDictionary:v]];
            }
            
            [self reloadWeekday];
        }else{
            [Utility showError:callback_data.message];
        }
        [lv removeFromSuperview];
    }];
}

-(void)reloadWeekday{
    CGFloat weekdayWidth=90;
    CGFloat weekdayHeight=60;
    CGFloat weekdayPadding=5;
    
    for(UIView* v in _weekScrollView.subviews){
        [v removeFromSuperview];
    }
    _weekdayViews=[Utility initArray:_weekdayViews];
    for(int i=0;i<_dateCourse.count;i++){
        NSDate* date=[Utility parseDateFromString:_dateCourse[i][@"date"] withFormat:nil];
        WeekdayView* weekdayView=[[WeekdayView alloc]init];
        weekdayView.date=date;
        weekdayView.delegate=self;
        [_weekScrollView addSubview:weekdayView];
        weekdayView.origin=(CGPoint){i*(weekdayWidth+weekdayPadding)+1,weekdayPadding};
        weekdayView.size=(CGSize){weekdayWidth,weekdayHeight};
        [_weekdayViews addObject:weekdayView];
        
    }
    
    [_weekScrollView fitHeightOfSubviews];
    _weekScrollView.height+=weekdayPadding;
    [_weekScrollView fitContentWidthWithPadding:1];
    
    NSInteger selectWeekDayIndex=0;
    if(![Utility isEmptyString:_selectedDate]){
        for(int i=0;i<_weekdayViews.count;i++){
            if([_selectedDate isEqualToString:[Utility formatStringFromDate:_weekdayViews[i].date withFormat:nil]]){
                selectWeekDayIndex=i;
                break;
            }
        }
    }
    [self selectWeekday:_weekdayViews[selectWeekDayIndex]];
    
}

-(void)reloadCalendar{
    _calendarScrollView.top=_weekScrollView.bottom;
    _calendarScrollView.height=_calendarScrollView.superview.height-_calendarScrollView.top;
    for(UIView* v in _calendarScrollView.subviews){
        [v removeFromSuperview];
    }
    
    NSInteger numberOfLine=3;
    CGFloat padding=5;
    CGFloat calendarViewWidth=(_calendarScrollView.width-(numberOfLine+1)*padding)/numberOfLine;
    CGFloat calendarViewHeight=calendarViewWidth*1;
    
    _calendarViews=[Utility initArray:nil];
    for(int i=0;i<_dateCourse.count;i++){
        NSString* dateString=_dateCourse[i][@"date"];
        if([dateString isEqualToString:_selectedDate]){
            NSArray<Course*>* courses=_dateCourse[i][@"course"];
            for (int j=0;j<courses.count;j++){
                Course* course=courses[j];
                CalendarView* calenderView=[[CalendarView alloc]init];
                calenderView.dateString=dateString;
                calenderView.course=course;
                calenderView.delegate=self;
                [_calendarScrollView addSubview:calenderView];
                calenderView.size=(CGSize){calendarViewWidth,calendarViewHeight};
                
                CGFloat x=(j%numberOfLine)*(padding+calendarViewWidth)+padding;
                CGFloat y=(j/numberOfLine)*(padding+calendarViewHeight)+padding;
                calenderView.origin=(CGPoint){x,y};

                [_calendarViews addObject:calenderView];
            }
        }
    }
    
    [_calendarScrollView fitContentHeightWithPadding:padding];
}

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@"预约时段"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:nil];
    [self.view addSubview:_headView];
    
    
    _weekScrollView=[[UIScrollView alloc]init];
    [_weekScrollView fillSuperview:self.view underOf:_headView];
    _weekScrollView.width=_weekScrollView.superview.width-10;
    _weekScrollView.centerX=_weekScrollView.superview.width/2;

    _calendarScrollView=[[UIScrollView alloc]init];
    [_calendarScrollView fillSuperview:self.view underOf:_weekScrollView];
}

-(void)selectWeekday:(WeekdayView*)weekdayView{
    if(_selectedWeekdayView!=weekdayView){
        for(WeekdayView* w in _weekdayViews){
            w.selected=false;
        }
        _selectedWeekdayView=weekdayView;
        _selectedWeekdayView.selected=true;
        _selectedDate=[Utility formatStringFromDate:_selectedWeekdayView.date withFormat:nil];
        [self reloadCalendar];
    }
}
-(void)weekdayView:(WeekdayView *)weekdayView onTap:(UIGestureRecognizer *)sender{
    [self selectWeekday:weekdayView];
}

-(void)selectCalendar:(CalendarView*)calendarView{
    if(!calendarView.timeExpired){
        if(!calendarView.isFull || calendarView.appointmented){
            [self showCourseDetail:calendarView.course dateString:calendarView.dateString];
        }
    }
}

-(void)showCourseDetail:(Course*)course dateString:(NSString*)dateString{
    if(_courseDetailView==nil){
        _courseDetailView=[[CourseDetailView alloc]init];
        [self.view addSubview:_courseDetailView];
    }
    _courseDetailView.frame=(CGRect){0,0,_courseDetailView.superview.width,_courseDetailView.superview.height};
    _courseDetailView.teacher=_teacher;
    _courseDetailView.course=course;
    _courseDetailView.dateString=dateString;
    _courseDetailView.delegate=self;
    _courseDetailView.hidden=false;
}

-(void)calendarView:(CalendarView *)calendarView onTap:(UIGestureRecognizer *)sender{
    [self selectCalendar:calendarView];
}

-(BOOL)calendarView:(CalendarView *)calendarView hadAppointmented:(id)data{
    for(CourseAppointment* ca in _appointment){
        if([ca.date isEqualToString:calendarView.dateString] && [ca.course.id isEqualToString:calendarView.course.id]){
            return true;
        }
    }
    return false;
}


-(void)sendMessage:(CourseDetailView *)courseDetailView isCanceled:(BOOL)isCanceled{

    JEAppointmentMessage* rcMessage=[[JEAppointmentMessage alloc]init];
    rcMessage.teacherid=_teacherid;
    rcMessage.studentid=_studentid;
    rcMessage.courseDate=courseDetailView.dateString;
    rcMessage.courseid=courseDetailView.course.id;
    rcMessage.courseStarttime=_courseDetailView.course.starttime;
    rcMessage.courseEndtime=_courseDetailView.course.endtime;
    rcMessage.isCanceled=isCanceled;
    
    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_PRIVATE targetId:_teacher.person.id content:rcMessage pushContent:@"" pushData:nil success:^(long messageId) {
        debugLog(@"send message success (%ld)",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        debugLog(@"send message error (%ld),(%d)",messageId,nErrorCode);
    }];
}

-(void)courseDetailView:(CourseDetailView *)courseDetailView appointment:(id)data{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote createAppointment:_studentid date:courseDetailView.dateString courseid:courseDetailView.course.id remark:@"" callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            courseDetailView.hidden=true;
            [self reloadRemoteData];
            [self sendMessage:courseDetailView isCanceled:false];
        }else{
            [Utility showError:callback_data.message];
        }
        [lv removeFromSuperview];
    }];
}
-(void)courseDetailView:(CourseDetailView *)courseDetailView cancelAppointment:(id)data{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote cancelAppointment:_studentid date:courseDetailView.dateString courseid:courseDetailView.course.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            courseDetailView.hidden=true;
            [self reloadRemoteData];
            [self sendMessage:courseDetailView isCanceled:true];
        }else{
            [Utility showError:callback_data.message];
        }
        [lv removeFromSuperview];
    }];
}

-(BOOL)courseDetailView:(CourseDetailView*)courseDetailView hadAppointmented:(id)data{
    for(CourseAppointment* ca in _appointment){
        if([ca.date isEqualToString:courseDetailView.dateString] && [ca.course.id isEqualToString:courseDetailView.course.id]){
            return true;
        }
    }
    return false;
}
-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_STUDENT_ID isEqualToString:key]){
        _studentid=value;
    }else if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }else if([PAGE_PARAM_TEACHER isEqualToString:key]){
        _teacher=value;
    }
}
@end
