//
//  TATeacherTimeTableVC.m
//  myim
//
//  Created by Sean Shi on 15/11/25.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherTimeTableVC.h"

#define HOURVIEW_HEIGHT ((getScreenSize().height-64)/10)
#define COURSE_PADDING 5
#define COURSE_COLOR UIColorFromRGB(0x3aa5de)
#define COURSE_PADDING_RIGHT 10

typedef struct CourseConflict{
    BOOL conflict;
    NSInteger nearestCourseOfBelow;
}CourseConflict;

@interface CourseView : UIView
@end

@protocol CourseViewDelegate <NSObject>
@required
-(void)courseView:(CourseView*)courseView onMove:(UIGestureRecognizer*)sender;
-(void)courseView:(CourseView*)courseView onResize:(UIGestureRecognizer*)sender direction:(UISwipeGestureRecognizerDirection)direction;
-(void)courseView:(CourseView*)courseView onDelete:(UIGestureRecognizer*)sender;
-(void)courseView:(CourseView*)courseView didSelected:(UIGestureRecognizer*)sender;
-(void)courseView:(CourseView*)courseView didDiselected:(UIGestureRecognizer*)sender;
-(void)courseView:(CourseView*)courseView onTap:(UIGestureRecognizer*)sender;

@optional
//-(void)courseView:(CourseView *)courseView onLongPressDown:(UILongPressGestureRecognizer*)sender;
//-(void)courseView:(CourseView *)courseView onLongPressUp:(UILongPressGestureRecognizer*)sender;

@end

@interface CourseView(){
    BOOL _gestureResize;
    UISwipeGestureRecognizerDirection _resizeDirection;
    
    UIView* _rootView;
    
    UIView* _resizeBottomIcon;
    UIView* _resizeTopIcon;

    UIImageView* _courseInfoIcon;
    UILabel* _courseInfoLabel;
    UIImageView* _studentNumIcon;
    UILabel* _studentNumLabel;
    UILabel* _remarkLabel;
    
    UIView* _leftHandleView;
    CGPoint _beginPoint;
    
    UILongPressGestureRecognizer* _longPressGesture;
    UIPanGestureRecognizer* _panGesture;
    UISwipeGestureRecognizer* _swipeGesture;
    UITapGestureRecognizer* _tapGesture;
    
}
@property (nonatomic,assign)NSInteger starttime;
@property (nonatomic,assign)NSInteger endtime;
@property (nonatomic,assign)Course* course;
@property (nonatomic,retain)NSArray<UIView*>* hourViews;
@property (nonatomic,retain)id<CourseViewDelegate> delegate;
@property (nonatomic,assign)BOOL selected;

+(instancetype)genWithCourse:(Course*)course hourViews:(NSArray<UIView*>*)hourViews delegate:(id<CourseViewDelegate>)delegate;
@end
@implementation CourseView

+(instancetype)genWithCourse:(Course*)course hourViews:(NSArray<UIView*>*)hourViews delegate:(id<CourseViewDelegate>)delegate{
    CourseView* ret=[[CourseView alloc]init];
    ret.course=course;
    ret.hourViews=hourViews;
    ret.delegate=delegate;
    return ret;
}

-(void)setCourse:(Course *)course{
    _course=course;
    if([Utility isEmptyString:_course.starttime]){
        _course.starttime=@"08:00";
    }
    _starttime=[Utility parseIndexFromTime:_course.starttime];
    if([Utility isEmptyString:_course.endtime]){
        _course.endtime=@"08:00";
    }
    _endtime=[Utility parseIndexFromTime:_course.endtime]-1;
    [self setNeedsLayout];
}
-(void)setSelected:(BOOL)selected{
    _selected=selected;
    if(_selected){
        if(_delegate!=nil){
            [_delegate courseView:self didSelected:nil];
        }
    }else{
        if(_delegate!=nil){
            [_delegate courseView:self didDiselected:nil];
        }
    }
    [self setNeedsLayout];
}
-(void)setStarttime:(NSInteger)starttime{
    _starttime=starttime;
    if(_course!=nil){
        _course.starttime=[Utility formatTimeFronIndex:_starttime];
    }
    [self setNeedsLayout];
}
-(void)setEndtime:(NSInteger)endtime{
    _endtime=endtime;
    if(_course!=nil){
        _course.endtime=[Utility formatTimeFronIndex:_endtime+1];
    }
    [self setNeedsLayout];
}
-(void)setHourViews:(NSArray<UIView *> *)hourViews{
    _hourViews=hourViews;
    [self setNeedsLayout];
}
-(void)layoutSubviews{
    [self resize];
    UIColor* bgColor=COURSE_COLOR;
    UIColor* textColor=UIColorFromRGB(0x003c57);
    UIColor* iconColor=textColor;
    if(_selected){
        textColor=[UIColor whiteColor];
        iconColor=textColor;
    }
    
    if(_rootView==nil){
        _rootView=[[UIView alloc]init];
        [self addSubview:_rootView];
    }
    _rootView.size=(CGSize){_rootView.superview.width,_rootView.superview.height-COURSE_PADDING*2};
    _rootView.left=0;
    _rootView.centerY=_rootView.superview.height/2;
    float backgroundAlpha=0.3;
    if(_selected){
        backgroundAlpha=1;
    }
    _rootView.backgroundColor=[bgColor colorWithAlphaComponent:backgroundAlpha];
    
    if(_leftHandleView==nil){
        _leftHandleView=[[UIView alloc]init];
        [_rootView addSubview:_leftHandleView];
    }
    _leftHandleView.backgroundColor=bgColor;
    _leftHandleView.origin=(CGPoint){0,0};
    _leftHandleView.size=(CGSize){2,_leftHandleView.superview.height};
    
    
    
    BOOL oneline=_endtime-_starttime==0;
    
    UIFont* font=nil;
    CGFloat iconWidth=0;
    if(oneline){
        font=FONT_TEXT_SECONDARY;
        iconWidth=20;
    }else{
        font=FONT_TEXT_SECONDARY;
        iconWidth=20;
    }

    if(_courseInfoIcon==nil){
        _courseInfoIcon=[[UIImageView alloc]init];
        [_rootView addSubview:_courseInfoIcon];
        _courseInfoIcon.image=[[UIImage imageNamed:@"icon_课程"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    _courseInfoIcon.tintColor=iconColor;
    _courseInfoIcon.size=(CGSize) {iconWidth,iconWidth};
    _courseInfoIcon.origin=(CGPoint){5,5};

    if(_courseInfoLabel==nil){
        _courseInfoLabel=[[UILabel alloc]init];
        _courseInfoLabel.numberOfLines=0;
        [_rootView addSubview:_courseInfoLabel];
    }
    _courseInfoLabel.textColor=textColor;
    _courseInfoLabel.text=[NSString stringWithFormat:@"%@",self.course.courseDisplay];
    _courseInfoLabel.font=font;
    [_courseInfoLabel fit];
    _courseInfoLabel.left=_courseInfoIcon.right+5;
    _courseInfoLabel.centerY=_courseInfoIcon.centerY;
    
    if(_studentNumIcon==nil){
        _studentNumIcon=[[UIImageView alloc]init];
        [_rootView addSubview:_studentNumIcon];
        _studentNumIcon.image=[[UIImage imageNamed:@"icon_教学人数"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    _studentNumIcon.tintColor=_courseInfoIcon.tintColor;
    _studentNumIcon.size=(CGSize) {iconWidth,iconWidth};
    if(oneline){
        _studentNumIcon.origin=(CGPoint){_courseInfoLabel.right+5,_courseInfoIcon.top};
    }else{
        _studentNumIcon.top=(_courseInfoLabel.bottom>_courseInfoIcon.bottom?_courseInfoLabel.bottom:_courseInfoIcon.bottom)+5;
        _studentNumIcon.left=_courseInfoIcon.left;
    }
    
    if(_studentNumLabel==nil){
        _studentNumLabel=[[UILabel alloc]init];
        _studentNumLabel.numberOfLines=0;
        [_rootView addSubview:_studentNumLabel];
    }
    _studentNumLabel.textColor=_courseInfoLabel.textColor;
    _studentNumLabel.text=[NSString stringWithFormat:@"%@人",self.course.studentnum];
    _studentNumLabel.font=font;
    [_studentNumLabel fit];
    _studentNumLabel.left=_studentNumIcon.right+5;
    _studentNumLabel.centerY=_studentNumIcon.centerY;
    
    if(_remarkLabel==nil){
        _remarkLabel=[[UILabel alloc]init];
        [_rootView addSubview:_remarkLabel];
        _remarkLabel.numberOfLines=0;
    }
    _remarkLabel.textColor=_courseInfoLabel.textColor;
    _remarkLabel.text=self.course.remark;
    _remarkLabel.font=font;
    [_remarkLabel fitWithWidth:self.width-10];
    _remarkLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    _remarkLabel.left=_courseInfoIcon.left;
    _remarkLabel.top=(_studentNumLabel.bottom>_studentNumIcon.bottom?_studentNumLabel.bottom:_studentNumIcon.bottom)+0;
    _remarkLabel.height=_remarkLabel.bottom>_remarkLabel.superview.height?_remarkLabel.superview.height-_remarkLabel.top:_remarkLabel.height;
 
    [self removeGestureRecognizer:_longPressGesture];
    [self removeGestureRecognizer:_panGesture];
    [self removeGestureRecognizer:_swipeGesture];
    if(_selected){
        if(_resizeBottomIcon==nil){
            _resizeBottomIcon=[[UIView alloc]init];
            [_rootView addSubview:_resizeBottomIcon];
            _resizeBottomIcon.backgroundColor=[UIColor whiteColor];
            _resizeBottomIcon.size=(CGSize){8,8};
            _resizeBottomIcon.layer.borderColor=bgColor.CGColor;
            _resizeBottomIcon.layer.borderWidth=1;
            _resizeBottomIcon.layer.cornerRadius=_resizeBottomIcon.width/2;
        }
        _resizeBottomIcon.left=20;
        _resizeBottomIcon.centerY=_resizeBottomIcon.superview.height;

        if(_resizeTopIcon==nil){
            _resizeTopIcon=[[UIView alloc]init];
            [_rootView addSubview:_resizeTopIcon];
            _resizeTopIcon.backgroundColor=[UIColor whiteColor];
            _resizeTopIcon.size=(CGSize){8,8};
            _resizeTopIcon.layer.borderColor=bgColor.CGColor;
            _resizeTopIcon.layer.borderWidth=1;
            _resizeTopIcon.layer.cornerRadius=_resizeBottomIcon.width/2;
        }
        _resizeTopIcon.right=_resizeBottomIcon.superview.width-20;
        _resizeTopIcon.centerY=0;
        _resizeBottomIcon.hidden=false;
        _resizeTopIcon.hidden=false;
        [self addGestureRecognizer:_longPressGesture];
        [self addGestureRecognizer:_panGesture];
    }else{
        _resizeBottomIcon.hidden=true;
        _resizeTopIcon.hidden=true;
        [self addGestureRecognizer:_longPressGesture];
        [self addGestureRecognizer:_swipeGesture];
        [self addGestureRecognizer:_tapGesture];
    }
}

-(instancetype)init{
    CourseView* ret=[super init];
    _longPressGesture=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
    _panGesture=[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    _swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    _tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
    return ret;
}


-(void)resize{
    self.origin=(CGPoint){self.left,_hourViews[_starttime].top};
    self.size=(CGSize){self.width,_hourViews[_endtime].bottom-self.top};
    
}

-(void)tap:(UITapGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate courseView:self onTap:sender];
    }
}
-(void)swipe:(UISwipeGestureRecognizer*)sender{
    if(sender.direction==UISwipeGestureRecognizerDirectionRight){
        [self delView:sender];
    }
}
-(void)pan:(UIGestureRecognizer*)sender{
    if(sender.state==UIGestureRecognizerStateBegan){
        _beginPoint=[sender locationInView:self];
    }else if(sender.state==UIGestureRecognizerStateChanged){
        CGPoint p=[sender locationInView:self];
        CGFloat deltaX=p.x-_beginPoint.x;
        if(deltaX>100){
            [self delView:sender];
        }
    }
    
    if(_selected){
        if(sender.state==UIGestureRecognizerStateBegan){
            _gestureResize=false;
            CGPoint p=[sender locationInView:self];
            CGFloat resizePanZoneWidth=50;
            CGRect bottomRect=(CGRect){0,self.height-resizePanZoneWidth,resizePanZoneWidth,resizePanZoneWidth*2};
            CGRect topRect=(CGRect){self.width-resizePanZoneWidth,-resizePanZoneWidth,resizePanZoneWidth,resizePanZoneWidth*2};
            
            if(CGRectContainsPoint(bottomRect, p)){
                _resizeDirection=UISwipeGestureRecognizerDirectionDown;
                _gestureResize=true;
            }else if(CGRectContainsPoint(topRect, p)){
                _resizeDirection=UISwipeGestureRecognizerDirectionUp;
                _gestureResize=true;
            }
            
            debugLog(@"%@:%@:%d:%d",[NSValue valueWithCGRect:bottomRect],[NSValue valueWithCGPoint:p],_gestureResize?1:0,_resizeDirection);
        }
        
        if(_gestureResize){
            [self resizeView:sender direction:_resizeDirection];
        }else{
            [self moveView:sender];
        }
    }
}
-(void)longPress:(UIGestureRecognizer*)sender{
    if(sender.state==UIGestureRecognizerStateBegan){
        self.selected=!self.selected;
    }
    [self pan:sender];
}

-(void)resizeView:(UIGestureRecognizer*)sender direction:(UISwipeGestureRecognizerDirection)direction{
    if(_delegate!=nil){
        [_delegate courseView:self onResize:sender direction:direction];
    }
}
-(void)moveView:(UIGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate courseView:self onMove:sender];
    }
}
-(void)delView:(UIGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate courseView:self onDelete:sender];
    }
}

@end


@interface TATeacherTimeTableVC ()<CourseViewDelegate,UIAlertViewDelegate>{
    HeaderView* _headView;
    UIScrollView* _leftScrollView;
    UIScrollView* _rightScrollView;
    
    NSInteger _selectedDay;
    
    CGFloat _halfHourRight;
    
    NSString* _teacherid;
    CourseTimeTable* _timetable;
    NSMutableArray<Course*>* _courseList;

    NSMutableArray<UIView*>* _weekdayViews;
    NSMutableArray<UIView*>* _hourViews;
    NSMutableArray<CourseView*>* _courseViewList;
    
    UIView* _panView;
    CGPoint _startPointOfLongPress;
    CGPoint _startPointOfOrigin;
    CGRect _resizeOriginRect;
    
    CourseView* _selectedCrouseView;
    
    
}

@end

@implementation TATeacherTimeTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _courseList=[Utility initArray:nil];
    _selectedDay=-1;
    [self reloadView];
    [self reloadRemoteData];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [self reloadDayContent:_selectedDay<0?0:_selectedDay];
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote teacherAllTimeTable:_teacherid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            NSArray<CourseTimeTable*>* calendars=callback_data.data;
            if(calendars.count>0){
                _timetable=calendars[0];
                _courseList=_timetable.course;
                [self reloadDayContent:_selectedDay<0?0:_selectedDay];
            }else{
                _courseList=[Utility initArray:nil];
                [self reloadDayContent:_selectedDay<0?0:_selectedDay];
            }
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}
-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@"课程表"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(willBack:)]
                                   rightButton:[HeaderView genItemWithText:@"添加课程" target:self action:@selector(add:)]];
    [self.view addSubview:_headView];
    
    
    CGSize leftSize=getStringSize(@"一",FONT_TEXT_NORMAL);
    CGFloat leftPadding=12;
    _leftScrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_leftScrollView];
    _leftScrollView.origin=(CGPoint){0,_headView.bottom};
    _leftScrollView.size=(CGSize){leftSize.width+(leftPadding*2),_leftScrollView.superview.height-_leftScrollView.top};
    _leftScrollView.bounces=false;
    _leftScrollView.backgroundColor=[UIColor whiteColor];
    _leftScrollView.showsVerticalScrollIndicator=false;
    
    CGFloat y=0;
    NSArray<NSString*>* weekdaysname=@[@"周一",@"周二",@"周三",@"周四",@"周五",@"周六",@"周日"];
    _weekdayViews=[Utility initArray:nil];
    for(int i=0;i<7;i++){
        UIView* dayView=[[UIView alloc]init];
        dayView.tag=i;
        [dayView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(willSelectWeekday:)]];
        [_weekdayViews addObject:dayView];
        [_leftScrollView addSubview:dayView];
        dayView.origin=(CGPoint){0,y};
        dayView.size=(CGSize){dayView.superview.width,100};
        dayView.backgroundColor=COLOR_SPLIT;
        UILabel* dayTitleLabel=[Utility genLabelWithText:weekdaysname[i]
                                                 bgcolor:nil
                                               textcolor:COLOR_TEXT_NORMAL
                                                    font:FONT_TEXT_NORMAL];
        [dayView addSubview:dayTitleLabel];
        dayTitleLabel.width=leftSize.width;
        dayTitleLabel.height=dayTitleLabel.superview.height;
        dayTitleLabel.origin=(CGPoint){12,0};
        
        UIView* split0=[[UIView alloc]init];
        [dayView addSubview:split0];
        split0.backgroundColor=COLOR_SPLIT;
        split0.origin=(CGPoint){dayTitleLabel.right+12,0};
        split0.size=(CGSize){0.5,split0.superview.height};
        
        y=dayView.bottom+0.5;
    }
    _leftScrollView.contentSize=(CGSize){_leftScrollView.width,y};
    
}

-(BOOL)courseChanged{
    BOOL changed=false;
    for(Course* c in _courseList){
        if(c.changed){
            changed=true;
            break;
        }
    }
    return changed;
}
-(void)willBack:(UIGestureRecognizer*)sender{
    if([self courseChanged]){
        UIAlertView* alertDeleteView=[[UIAlertView alloc]initWithTitle:@"更改提示"
                                                               message:@"课程已更改，是否要保存？"
                                                              delegate:self
                                                     cancelButtonTitle:@"保存"
                                                     otherButtonTitles:@"算了，不保存",nil];
        alertDeleteView.tagObject=@{
                                    @"action":@"back",
                                    @"obj":[NSNumber numberWithInteger:sender.view.tag],
                                    };
        [alertDeleteView show];
    }else{
        [self gotoBack];
    }
}

-(void)willSelectWeekday:(UIGestureRecognizer*)sender{
    if([self courseChanged]){
        UIAlertView* alertDeleteView=[[UIAlertView alloc]initWithTitle:@"更改提示"
                                                               message:@"课程已更改，是否要保存？"
                                                              delegate:self
                                                     cancelButtonTitle:@"保存"
                                                     otherButtonTitles:@"稍后再保存",nil];
        alertDeleteView.tagObject=@{
                                    @"action":@"changeweekday",
                                    @"obj":[NSNumber numberWithInteger:sender.view.tag],
                                    };
        [alertDeleteView show];
    }else{
        [self selectWeekday:sender.view.tag];
    }
}
-(void)selectWeekday:(NSInteger)weekday{
    for(UIView* v in _weekdayViews){
        v.backgroundColor=COLOR_SPLIT;
    }
    [self reloadDayContent:weekday];
}

-(void)reloadDayContent:(NSInteger)weekday{
    _courseViewList=[Utility initArray:_courseViewList];
    _selectedCrouseView=nil;
    for(Course* c in _courseList){
        if(c.weekday.integerValue==weekday && !c.deleted){
            [_courseViewList addObject:[CourseView genWithCourse:c hourViews:_hourViews delegate:self]];
        }
    }

    if(_rightScrollView==nil){
        _rightScrollView=[[UIScrollView alloc]init];
        [self.view addSubview:_rightScrollView];
        _rightScrollView.origin=(CGPoint){_leftScrollView.right,_headView.bottom};
        _rightScrollView.size=(CGSize){_rightScrollView.superview.width-_rightScrollView.left ,_rightScrollView.superview.height-_rightScrollView.top};
        _rightScrollView.bounces=false;
        _rightScrollView.backgroundColor=COLOR_SPLIT;

        _hourViews=[Utility initArray:_hourViews];
        CGFloat hourPadding=5;
        CGFloat y=0;
        _halfHourRight=0;
        for(int i=0;i<48;i++){
            UIView* hourView=[[UIView alloc]init];
            [_hourViews addObject:hourView];
            hourView.tag=i;
            [hourView addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(addCourse:)]];
            [hourView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHour:)]];
            [_rightScrollView addSubview:hourView];
            hourView.backgroundColor=[UIColor whiteColor];
            hourView.width=hourView.superview.width;
            hourView.height=HOURVIEW_HEIGHT;
            hourView.origin=(CGPoint){0,y};
            
            
            UILabel* halfHourLabel=[Utility genLabelWithText:[NSString stringWithFormat:@"%02d:%@",i/2,(i%2==0?@"00":@"30")]
                                                     bgcolor:nil
                                                   textcolor:COLOR_TEXT_NORMAL
                                                        font:FONT_TEXT_SECONDARY];
            [hourView addSubview:halfHourLabel];
            halfHourLabel.left=hourPadding;
//            halfHourLabel.centerY=halfHourLabel.superview.height/2;
            halfHourLabel.top=2;
            
            _halfHourRight=_halfHourRight<halfHourLabel.right?halfHourLabel.right:_halfHourRight;
            
            UIView* splitView=[[UIView alloc]init];
            [hourView addSubview:splitView];
            splitView.backgroundColor=COLOR_SPLIT;
            splitView.origin=(CGPoint){0,splitView.superview.height-0.5};
            splitView.size=(CGSize){splitView.superview.width,0.5};
            
            y=hourView.bottom;
        }
        _halfHourRight+=hourPadding;
        _rightScrollView.contentSize=(CGSize){_rightScrollView.width,y};
    }
    if(_selectedDay!=weekday){
        CGRect scrollRect=_hourViews[16].frame;
        scrollRect.size.height=1;
        if(scrollRect.origin.y>_rightScrollView.contentOffset.y){
            scrollRect.origin.y+=_rightScrollView.height;
        }
        [_rightScrollView scrollRectToVisible:scrollRect animated:false];
    }
    _selectedDay=weekday;
    _weekdayViews[weekday].backgroundColor=[UIColor whiteColor];
    for(UIView* v in _rightScrollView.subviews){
        if([v isKindOfClass:[CourseView class]]){
            [v removeFromSuperview];
        }
    }

    
    
    for(int i=0;i<_courseViewList.count;i++){
        [_rightScrollView addSubview:_courseViewList[i]];
        _courseViewList[i].left=_halfHourRight;
        _courseViewList[i].width=_rightScrollView.width-_halfHourRight-COURSE_PADDING_RIGHT;
        _courseViewList[i].hourViews=_hourViews;
        [_courseViewList[i] resize];
    }
    
}

-(NSArray<NSNumber*>*)availableTimeWithExpectCourse:(Course*)course{
    NSMutableArray<NSNumber*>* ret=[Utility initArray:nil];
    for(int i=0;i<48;i++){
        [ret addObject:[NSNumber numberWithInt:i]];
    }
    for(int i=0;i<_courseViewList.count;i++){
        CourseView* cv=_courseViewList[i];
        if(cv.course!=course){
            for(int j=cv.starttime;j<=cv.endtime;j++){
                [ret removeObject:[NSNumber numberWithInt:j]];
            }
        }
    }
    return ret;
}
-(void)addWithStarttime:(NSInteger)starttime endtime:(NSInteger)endtime{
    Course* course=[[Course alloc]init];
    if(starttime>=0){
        course.starttime=[Utility formatTimeFronIndex:starttime];
        course.endtime=[Utility formatTimeFronIndex:endtime+1];
    }
    course.studentnum=@"1";
    course.course=@"km2,km3A";
    
    [self gotoPageWithClass:[TATeacherCourseVC class] parameters:@{
                                                                                    @"availableTime":[self availableTimeWithExpectCourse:nil],
                                                                                    PAGE_PARAM_WEEKDAY:[Utility convertIntToString:_selectedDay],
                                                                                    PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                                    PAGE_PARAM_COURSE:course,
                                                                                    }];
}
-(void)add:(UIGestureRecognizer*)sender{
    [self addWithStarttime:-1 endtime:-1];
}
-(void)edit:(Course*)course{
    if(course!=nil){
        [self gotoPageWithClass:[TATeacherCourseVC class] parameters:@{
                                                                                    @"availableTime":[self availableTimeWithExpectCourse:course],
                                                                                    PAGE_PARAM_WEEKDAY:course.weekday,
                                                                                    PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                                    PAGE_PARAM_COURSE:course,
                                                                                    }];
    }
}

-(void)tapHour:(UIGestureRecognizer*)sender{
    if(_selectedCrouseView!=nil){
        _selectedCrouseView.selected=false;
        _selectedCrouseView=nil;
    }
}

-(void)addCourse:(UIGestureRecognizer*)sender{
    if(sender.state==UIGestureRecognizerStateBegan){
        NSInteger starttime=sender.view.tag;
        NSInteger endtime=starttime;
        CourseConflict conflict=[self conflictWithOtherCrouse:nil newStarttime:starttime  newEndtime:endtime];
        if(!conflict.conflict){
            if(endtime+1<conflict.nearestCourseOfBelow){
                endtime+=1;
            }
            [self addWithStarttime:starttime endtime:endtime];

        }
    }
}
-(CourseConflict)conflictWithOtherCrouse:(CourseView*)courseView newStarttime:(NSInteger)starttime newEndtime:(NSInteger)endtime{
    BOOL conflict=false;
    NSInteger nearestCourseOfBelow=_hourViews.count;
    for(int i=0;i<_courseViewList.count;i++){
        CourseView* cv=_courseViewList[i];
        if(cv!=courseView){
            if((cv.starttime<=starttime && cv.endtime>=starttime)
               || (cv.starttime>=starttime && cv.starttime<=endtime)){
                conflict=true;
                break;
            }
            if(cv.starttime>starttime && cv.starttime<nearestCourseOfBelow){
                nearestCourseOfBelow=cv.starttime;
            }
        }
    }
    return (CourseConflict){conflict,nearestCourseOfBelow};
}
-(NSInteger)getTimenumOfRect:(CGRect)rect{
    return (rect.origin.y/HOURVIEW_HEIGHT);
}

-(void)courseView:(CourseView *)courseView onMove:(UIGestureRecognizer *)sender{
    CGPoint newPoint=[sender locationInView:_rightScrollView];
    CGRect rect=(CGRect){courseView.left,courseView.top+COURSE_PADDING,courseView.width,courseView.height-COURSE_PADDING*2};
    if(sender.state==UIGestureRecognizerStateBegan){
        if(_panView==nil){
            _panView=[[UIView alloc]init];
            _panView.frame=rect;
            [_rightScrollView addSubview:_panView];
            _panView.backgroundColor=COURSE_COLOR;
            _panView.alpha=0.2;
            UIImageView* iconView=[[UIImageView alloc]init];
            [_panView addSubview:iconView];
            CGFloat iconWidth=HOURVIEW_HEIGHT*0.6;
            iconView.image=[[UIImage imageNamed:@"icon_拖动上下"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconView.tintColor=[UIColor whiteColor];
            iconView.size=(CGSize){iconWidth,iconWidth};
            iconView.center=iconView.superview.innerCenterPoint;
            _panView.tagObject=iconView;
        }
        _panView.frame=rect;
        ((UIImageView*)_panView.tagObject).center=_panView.innerCenterPoint;
        _panView.hidden=false;
        _startPointOfLongPress=newPoint;
        _startPointOfOrigin=_panView.origin;
        [_rightScrollView bringSubviewToFront:_panView];
    }else if(sender.state==UIGestureRecognizerStateEnded){
        courseView.frame=_panView.frame;
        _panView.hidden=true;
        NSInteger moveToStarttime=[self getTimenumOfRect:_panView.frame];
        NSInteger timelen=courseView.endtime-courseView.starttime;
        courseView.starttime=moveToStarttime;
        courseView.endtime=courseView.starttime+timelen;
        if(courseView.height<_rightScrollView.height){
            [_rightScrollView scrollRectToVisible:courseView.frame animated:false];
        }
    }else if(sender.state==UIGestureRecognizerStateChanged){
        CGFloat deltaY = newPoint.y-_startPointOfLongPress.y;
        courseView.origin=(CGPoint){_startPointOfOrigin.x,_startPointOfOrigin.y+deltaY};
        NSInteger moveToStarttime=[self getTimenumOfRect:rect];
        NSInteger moveToEndtime=moveToStarttime+courseView.endtime-courseView.starttime;
        
        CourseConflict conflict=[self conflictWithOtherCrouse:courseView newStarttime:moveToStarttime newEndtime:moveToEndtime];
        if(!conflict.conflict && conflict.nearestCourseOfBelow>moveToEndtime && moveToStarttime>=0){
            _panView.top=moveToStarttime*HOURVIEW_HEIGHT+COURSE_PADDING;
        }
        if(courseView.height<_rightScrollView.height){
            [_rightScrollView scrollRectToVisible:rect animated:false];
        }
    }
}
-(void)courseView:(CourseView *)courseView onResize:(UIGestureRecognizer *)sender direction:(UISwipeGestureRecognizerDirection)direction{
    CGPoint newPoint=[sender locationInView:_rightScrollView];
    if(sender.state==UIGestureRecognizerStateBegan){
        _startPointOfLongPress=newPoint;
        _startPointOfOrigin=(CGPoint){0, (direction==UISwipeGestureRecognizerDirectionUp?courseView.top:courseView.bottom)};
        _resizeOriginRect=courseView.frame;
    
    }else if(sender.state==UIGestureRecognizerStateEnded){
    }else if(sender.state==UIGestureRecognizerStateChanged){
        NSInteger newtime=[self getTimenumOfRect:(CGRect){newPoint.x,newPoint.y+(_startPointOfOrigin.y-_startPointOfLongPress.y),1,1}];
        NSInteger starttime=0;
        NSInteger endtime=0;
        if(direction==UISwipeGestureRecognizerDirectionUp){
            starttime=newtime;
            endtime=courseView.endtime;
        }else{
            starttime=courseView.starttime;
            endtime=newtime;
        }
        if(endtime>=starttime){
            CourseConflict conflict=[self conflictWithOtherCrouse:courseView newStarttime:starttime newEndtime:endtime];
            if(!conflict.conflict){
                if(direction==UISwipeGestureRecognizerDirectionUp){
                    courseView.starttime=starttime;
                }else{
                    courseView.endtime=endtime;
                }
                
            }
        }
        
    }
}

-(void)courseView:(CourseView *)courseView onDelete:(UIGestureRecognizer *)sender{
    UIAlertView* alertDeleteView=[[UIAlertView alloc]initWithTitle:@"删除提示"
                                                            message:@"真的要删除课程么？"
                                                           delegate:self
                                                  cancelButtonTitle:@"是的"
                                                  otherButtonTitles:@"不！点错了",nil];
    alertDeleteView.tagObject=@{
                                @"action":@"deletecourse",
                                @"obj":courseView,
                                };
    [alertDeleteView show];
    courseView.selected=false;
    _panView.hidden=true;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* action=alertView.tagObject[@"action"];
    if([@"deletecourse" isEqualToString:action]){
        if(buttonIndex==0){
            CourseView* courseView=alertView.tagObject[@"obj"];
            if([Utility isEmptyString:courseView.course.id]){
                [_courseList removeObject:courseView.course];
            }else{
                courseView.course.deleted=true;
                courseView.course.changed=true;
            }
            [_courseViewList removeObject:courseView];
            [UIView animateWithDuration:0.2 animations:^{
                courseView.left=courseView.superview.width;
            } completion:^(BOOL finished) {
                [courseView removeFromSuperview];
                [self reloadDayContent:_selectedDay];
            }];
        }
    }else if([@"changeweekday" isEqualToString:action]){
        NSNumber* weekday=alertView.tagObject[@"obj"];
        if(buttonIndex==0){
            __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
            [Remote updateTeacherCourse:_teacherid timetableid:_timetable.id courseList:_courseList callback:^(StorageCallbackData *callback_data) {
                if(callback_data.code==0){
                    if(_timetable==nil){
                        _timetable=[[CourseTimeTable alloc]init];
                    }
                    if([Utility isEmptyString:_timetable.id]){
                        _timetable.id=((CourseTimeTable*)callback_data.data).id;
                    }
                    
                    [Utility showMessage:@"课程表已保存"];
                    [self selectWeekday:weekday.integerValue];
                }else{
                    [Utility showError:callback_data.message type:ErrorType_Network];
                }
                [lv removeFromSuperview];
            }];
        }else{
            [self selectWeekday:weekday.integerValue];
        }
        
    }else if([@"back" isEqualToString:action]){
        if(buttonIndex==0){
            __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
            [Remote updateTeacherCourse:_teacherid timetableid:_timetable.id courseList:_courseList callback:^(StorageCallbackData *callback_data) {
                if(callback_data.code==0){
                    if(_timetable==nil){
                        _timetable=[[CourseTimeTable alloc]init];
                    }
                    if([Utility isEmptyString:_timetable.id]){
                        _timetable.id=((CourseTimeTable*)callback_data.data).id;
                    }
                    [Utility showMessage:@"课程表已保存"];
                    [self gotoBack];
                }else{
                    [Utility showError:callback_data.message type:ErrorType_Network];
                }
                [lv removeFromSuperview];
            }];
        }else{
            [self gotoBack];
        }
    }
}

-(void)courseView:(CourseView*)courseView didSelected:(UIGestureRecognizer*)sender{
    if(_selectedCrouseView!=nil && _selectedCrouseView!=courseView){
        _selectedCrouseView.selected=false;
    }
    _selectedCrouseView=courseView;
}

-(void)courseView:(CourseView*)courseView didDiselected:(UIGestureRecognizer*)sender{
    if(_selectedCrouseView==courseView){
        _selectedCrouseView=nil;
    }
}
-(void)courseView:(CourseView *)courseView onTap:(UIGestureRecognizer *)sender{
    if(_selectedCrouseView!=courseView){
        _selectedCrouseView.selected=false;
        _selectedCrouseView=nil;
    }
    [self edit:courseView.course];
}
-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_COURSE isEqualToString:key]){
        BOOL found=false;
        for(Course* c in _courseList){
            if(c==value){
                found=true;
            }
        }
        if(!found){
            [_courseList addObject:value];
        }
        [self reloadDayContent:_selectedDay];
    }else if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }
}
@end
