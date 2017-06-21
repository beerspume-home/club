//
//  TAStudentRecordListVC.m
//  myim
//
//  Created by Sean Shi on 15/12/4.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TAStudentRecordListVC.h"
#import "TAStudentRecordCell.h"

#pragma mark AppointmentDetailView
@interface AppointmentDetailView : UIControl
@end
@protocol AppointmentDetailViewDelegate <NSObject>
-(void)appointmentDetailView:(AppointmentDetailView*)appointmentDetailView cancelAppointment:(id)data;
-(BOOL)appointmentDetailView:(AppointmentDetailView*)appointmentDetailView isExpired:(id)data;
@end

@interface AppointmentDetailView(){
    UIView* _rootView;
    UIImageView* _teacherHeadImage;
    UILabel* _timeLabel;
    UILabel* _courseLabel;
    UILabel* _nameLabel;
    UILabel* _remarkLabel;
    
    UILabel* _appointmentButton;
    
    UITapGestureRecognizer* _cancelAppointmentTap;
    Course* _course;
    Teacher* _teacher;
    NSString* _dateString;
    
    BOOL _isExpired;
}
@property (nonatomic,retain) CourseAppointment* appointment;
@property (nonatomic,retain) id<AppointmentDetailViewDelegate> delegate;

@end
@implementation AppointmentDetailView

-(void)setAppointment:(CourseAppointment *)appointment{
    _appointment=appointment;
    _teacher=_appointment.teacher;
    _course=_appointment.course;
    _dateString=_appointment.date;
    [self setNeedsLayout];
}

-(instancetype)init{
    AppointmentDetailView* ret=[super init];
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    _cancelAppointmentTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cancelAppointment)];
    
    return ret;
}
-(void)layoutSubviews{
    static CGFloat topPadding=10;
    static CGFloat linePadding=5;
    
    if(_delegate!=nil){
        _isExpired=[_delegate appointmentDetailView:self isExpired:nil];
    }
    
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

    
    if(_nameLabel==nil){
        _nameLabel=[[UILabel alloc]init];
        [_rootView addSubview:_nameLabel];
    }
    _nameLabel.text=[NSString stringWithFormat:@"教练:%@",_appointment.teacher.person.name];
    _nameLabel.textColor=textColor2;
    _nameLabel.font=font2;
    [_nameLabel fit];
    _nameLabel.origin=(CGPoint){_courseLabel.left,_courseLabel.bottom+linePadding};
    
    
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
    NSString* buttonText=@"取消预约";
    UITapGestureRecognizer* tap=_cancelAppointmentTap;

    for (UIGestureRecognizer* g in _appointmentButton.gestureRecognizers){
        [_appointmentButton removeGestureRecognizer:g];
    }
    [_appointmentButton addGestureRecognizer:tap];
    _appointmentButton.text=buttonText;
    _appointmentButton.bottom=_appointmentButton.superview.height-topPadding;
    _appointmentButton.centerX=_appointmentButton.superview.width/2;
    if([_appointment isDeleted]){
        _appointmentButton.hidden=true;
    }else{
        _appointmentButton.hidden=false;
    }
    
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


-(void)cancelAppointment{
    if(_delegate){
        [_delegate appointmentDetailView:self cancelAppointment:nil];
    }
}
@end


#pragma mark ViewController
@interface TAStudentRecordListVC ()<UITableViewDataSource,UITableViewDelegate,AppointmentDetailViewDelegate,TAStudentRecordCellDelegate>{
    HeaderView* _headView;
    
    UITableView* _tableView;
    
    NSMutableArray<CourseAppointment*>* _records;

    NSString* _studentid;

    
    BOOL _loading;
    BOOL _isend;
    NSInteger _start;
    NSInteger _offset;

    BOOL _showExpired;

    AppointmentDetailView* _appointmentDetailView;

}

@end

@implementation TAStudentRecordListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _start=0;
    _offset=30;
    [self reloadView];
    [self reloadRemoteData];
}

-(void)reloadRemoteData{
    if(!_loading){
        _loading=true;
        [Remote studentAppointmentList:_studentid showexpired:_showExpired start:_start offset:_offset callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSArray<CourseAppointment*>* result=callback_data.data;
                if(result.count<_offset){
                    _isend=true;
                }
                if(_records==nil){
                    _records=[Utility initArray:nil];
                }
                [_records addObjectsFromArray:result];
                [_tableView reloadData];
            }else if(callback_data.code==2){
                _isend=true;
                [_tableView reloadData];
            }else{
                [Utility showError:callback_data.message];
            }
            _loading=false;
        }];
    }
}

- (void)reloadView {
    [super reloadView];
    NSString* headText=@"预约记录";
    UIView* rightButton=[HeaderView genItemWithText:@"历史" target:self action:@selector(gotoHistoryRecord:)];
    if(_showExpired){
        headText=@"历史约车记录";
        rightButton=nil;
    }
    _headView=[[HeaderView alloc]initWithTitle:headText
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:rightButton];
    [self.view addSubview:_headView];
    
    _tableView=[[UITableView alloc]init];
    [_tableView fillSuperview:self.view underOf:_headView];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.bounces=false;

}


#pragma mark 表格
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _records.count+(_isend?0:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;

    if(index<_records.count){
        TAStudentRecordCell* cell=[[TAStudentRecordCell alloc]init];
        cell.appointment=_records[index];
        cell.delegate=self;
        cell.height=[TAStudentRecordCell calcLayoutHeightWithAppointment:_records[index] andMaxWidth:tableView.width];
        return cell;
        
    }else{
        UITableViewCell* cell=nil;
        NSString* cellname=@"empty_cell";
        cell=[tableView dequeueReusableCellWithIdentifier:cellname];
        if(cell==nil){
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
        }
        [Utility cleanView:cell.contentView];
        UILabel* refreshLabel=[[UILabel alloc]init];
        [cell.contentView addSubview:refreshLabel];
        refreshLabel.font=FONT_TEXT_NORMAL;
        refreshLabel.textColor=COLOR_TEXT_NORMAL;
        refreshLabel.text=[NSString stringWithFormat:@"载入%d条约车记录",_offset];
        [Utility fitLabel:refreshLabel];
        refreshLabel.center=refreshLabel.superview.innerCenterPoint;
        return cell;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    if(index<_records.count){
        return [TAStudentRecordCell calcLayoutHeightWithAppointment:_records[index] andMaxWidth:tableView.width];
    }else{
        return 90;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    if(index<_records.count-1 || _isend){
        CourseAppointment* record=_records[index];
        [self showCourseDetail:record atIndex:index];
    }
}


-(void)showCourseDetail:(CourseAppointment*)appointment atIndex:(int)index{
    if(_showExpired){
        if(![appointment isDeleted]){
            [self gotoPageWithClass:[TAAppointmentInfoVC class] parameters:@{
                                                                                   PAGE_PARAM_APPOINTMENT:appointment,
                                                                                   PAGE_PARAM_STUDENT_ID:_studentid,
                                                                                   PAGE_PARAM_INDEX:[NSNumber numberWithInt:index],
                                                                                   }];
        }
    }else{
        if(_appointmentDetailView==nil){
            _appointmentDetailView=[[AppointmentDetailView alloc]init];
            [self.view addSubview:_appointmentDetailView];
        }
        _appointmentDetailView.frame=(CGRect){0,0,_appointmentDetailView.superview.width,_appointmentDetailView.superview.height};
        _appointmentDetailView.appointment=appointment;
        _appointmentDetailView.delegate=self;
        _appointmentDetailView.hidden=false;
    }
}



-(void)gotoHistoryRecord:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[self class] parameters:@{
                                                      PAGE_PARAM_STUDENT_ID:_studentid,
                                                      @"showExpired":[NSNumber numberWithBool:true],
                                                      }];
}


-(void)sendMessage:(AppointmentDetailView *)appointmentDetailView teacher:(Teacher*)teacher{
    
    JEAppointmentMessage* rcMessage=[[JEAppointmentMessage alloc]init];
    rcMessage.teacherid=teacher.id;
    rcMessage.studentid=_studentid;
    rcMessage.courseDate=appointmentDetailView.appointment.date;
    rcMessage.courseid=appointmentDetailView.appointment.course.id;
    rcMessage.courseStarttime=appointmentDetailView.appointment.course.starttime;
    rcMessage.courseEndtime=appointmentDetailView.appointment.course.endtime;
    rcMessage.isCanceled=true;
    
    [[RCIMClient sharedRCIMClient]sendMessage:ConversationType_PRIVATE targetId:teacher.person.id content:rcMessage pushContent:@"" pushData:nil success:^(long messageId) {
        debugLog(@"send message success (%ld)",messageId);
    } error:^(RCErrorCode nErrorCode, long messageId) {
        debugLog(@"send message error (%ld),(%d)",messageId,nErrorCode);
    }];
}
-(void)appointmentDetailView:(AppointmentDetailView *)appointmentDetailView cancelAppointment:(id)data{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote cancelAppointment:_studentid date:appointmentDetailView.appointment.date courseid:appointmentDetailView.appointment.course.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            appointmentDetailView.hidden=true;
            appointmentDetailView.appointment.deleted=@"1";
            [_tableView reloadData];
            [self sendMessage:appointmentDetailView teacher:appointmentDetailView.appointment.teacher];
        }else{
            [Utility showError:callback_data.message];
        }
        [lv removeFromSuperview];
    }];
}

-(BOOL)appointmentDetailView:(AppointmentDetailView*)appointmentDetailView isExpired:(id)data{
    return _showExpired;
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_STUDENT_ID isEqualToString:key]){
        _studentid=value;
    }else if([@"showExpired" isEqualToString:key]){
        _showExpired=[@"1" isEqualToString:[NSString stringWithFormat:@"%@",value]];
    }else if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([@"evaluation" isEqualToString:value[PAGE_PARAM_TYPE]]){
            NSNumber* index=value[PAGE_PARAM_INDEX];
            CourseAppointment* appointment=value[PAGE_PARAM_APPOINTMENT];
            if(index.intValue>=0){
                @try {
                    _records[index.intValue]=appointment;
                    [_tableView reloadData];
                }
                @catch (NSException *exception) {
                }
                @finally {
                }
            }
        }
    }
}

@end
