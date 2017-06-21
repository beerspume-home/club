//
//  TATeacherCourseVC.m
//  myim
//
//  Created by Sean Shi on 15/11/26.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherCourseVC.h"

@interface TATeacherCourseVC ()<FeatureItemDelegate>{
    HeaderView* _headView;
    UIScrollView* _scrollView;
    //起始时间
    FeatureItem* _startHourItem;
    //结束时间
    FeatureItem* _endHourItem;
    //课程
    FeatureItem* _courseItem;
    //同时学习人数
    FeatureItem* _studentNumItem;
    //备注
    FeatureItem* _remarkItem;
    
    NSMutableArray<Dict*>* _starttimeDict;
    NSMutableArray<Dict*>* _endtimeDict;
    NSArray<Dict*>* _courseDict;
    
    Course* _course;
    NSString* _teacherid;
    NSString* _calendarid;
    NSString* _weekday;
    NSArray<NSNumber*>* _availableTime;
}

@end

@implementation TATeacherCourseVC



-(NSMutableArray<Dict*>*) partStartTimeDictWithIndexSet:(NSArray<NSNumber*>*)indexset{
    NSMutableArray<Dict*>*  ret=[Utility initArray:nil];
    if(indexset!=nil){
        for(int i=0;i<indexset.count;i++){
            NSInteger index=indexset[i].integerValue;
            [ret addObject:_starttimeDict[index]];
        }
    }else{
        ret=_starttimeDict;
    }
    return ret;
}
-(NSMutableArray<Dict*>*) partEndTimeDictWithIndexSet:(NSArray<NSNumber*>*)indexset{
    NSMutableArray<Dict*>*  ret=[Utility initArray:nil];
    if(indexset!=nil){
        for(int i=0;i<indexset.count;i++){
            NSInteger index=indexset[i].integerValue;
            [ret addObject:_endtimeDict[index]];
        }
    }else{
        ret=_endtimeDict;
    }
    return ret;
}

-(NSArray<Dict*>*)avaliableEnttime{
    NSMutableArray<NSNumber*>* a=[NSMutableArray arrayWithArray:_availableTime];
    NSString * value=_startHourItem.rightValue;
    NSInteger startindex=[Utility parseIndexFromTime:value];
    if(startindex>=0){
        NSInteger endindex=startindex;
        for(int i=0;i<_availableTime.count;i++){
            NSInteger a=_availableTime[i].integerValue;
            if(a<=startindex){
                endindex=startindex;
            }else if(a==endindex+1){
                endindex=a;
            }else{
                break;
            }
        }
        a=[Utility initArray:nil];
        for(int i=startindex;i<=endindex;i++){
            [a addObject:[NSNumber numberWithInt:i]];
        }
    }
    return [self partEndTimeDictWithIndexSet:a];
}
-(void)featureItem:(FeatureItem *)featureItem didValueChange:(NSString *)value{
    if(featureItem==_startHourItem){
        _endHourItem.rightDict=[self avaliableEnttime];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDict];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _startHourItem.view.top=12;
    _endHourItem.view.top=_startHourItem.view.bottom;
    _courseItem.view.top=_endHourItem.view.bottom;
    _studentNumItem.view.top=_courseItem.view.bottom;
    _remarkItem.view.top=_studentNumItem.view.bottom;
}

-(void)reloadView{
    [super reloadView];

    _headView=[[HeaderView alloc]initWithTitle:@"课程"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:[HeaderView genItemWithText:@"保存" target:self action:@selector(save:)]];
    [self.view addSubview:_headView];

    
    _scrollView=[[UIScrollView alloc]init];
    [_scrollView fillSuperview:self.view underOf:_headView];
    
    _startHourItem=[[FeatureItem alloc]initSelectInSuperView:_scrollView
                                                                      top:0
                                                                    title:@"起始时间"
                                                                    value:_course==nil?@"":_course.starttime
                                                                   height:FEATURE_NORMAL_HEIGHT
                                                                showSplit:false
                                                                    dict:[self partStartTimeDictWithIndexSet: _availableTime]
                                                              mutliSelect:false];
    _startHourItem.delegate=self;
    
    _endHourItem=[[FeatureItem alloc]initSelectInSuperView:_scrollView
                                                                      top:0
                                                                    title:@"结束时间"
                                                                    value:_course==nil?@"":_course.endtime
                                                                   height:FEATURE_NORMAL_HEIGHT
                                                                showSplit:true
                                                                  dict:[self avaliableEnttime]
                                                              mutliSelect:false];

    _courseItem=[[FeatureItem alloc]initSelectInSuperView:_scrollView
                                                                    top:0
                                                                  title:@"教学课程"
                                                                  value:_course==nil?@"":_course.course
                                                                 height:FEATURE_NORMAL_HEIGHT
                                                              showSplit:true
                                                                   dict:_courseDict
                                                            mutliSelect:true];

    _studentNumItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                         top:0
                                                       title:@"最多学习人数"
                                                       value:_course==nil?@"1":_course.studentnum
                                                      height:FEATURE_NORMAL_HEIGHT
                                                   showSplit:true
                                                   inputType:CHANGEVALUE_INPUTTYPE_NumberPad];

    _remarkItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                     top:0
                                                   title:@"备注"
                                                   value:_course==nil?@"":_course.remark
                                                  height:FEATURE_NORMAL_HEIGHT
                                               showSplit:true
                                               inputType:CHANGEVALUE_INPUTTYPE_Default];

}

-(void)initDict{
    _starttimeDict=[Utility initArray:nil];
    _endtimeDict=[Utility initArray:nil];
    for(int i=0;i<48;i++){
        NSString* startvalue=[NSString stringWithFormat:@"%02d:%@",i/2,(i%2==0?@"00":@"30")];
        NSString* endvalue=[NSString stringWithFormat:@"%02d:%@",(i+1)/2,((i+1)%2==0?@"00":@"30")];
        [_starttimeDict addObject:[Dict initWithDictionary:@{
                                                        @"name":@"time",
                                                        @"value":startvalue,
                                                        @"desc":startvalue,
                                                        @"order":[Utility convertIntToString:i],
                                                        }]];
        [_endtimeDict addObject:[Dict initWithDictionary:@{
                                                             @"name":@"time",
                                                             @"value":endvalue,
                                                             @"desc":endvalue,
                                                             @"order":[Utility convertIntToString:i],
                                                             }]];
    }
    _courseDict=[Storage teacherSkillDict];
}

-(void)save:(UIGestureRecognizer*)sender{
    BOOL complete=true;
    if([Utility isEmptyString:_startHourItem.rightValue]){
        [Utility showError:@"请输入起始时间" type:ErrorType_Network];
        complete=false;
    }
    if([Utility isEmptyString:_endHourItem.rightValue]){
        [Utility showError:@"请输入结束时间" type:ErrorType_Network];
        complete=false;
    }
    if([Utility isEmptyString:_courseItem.rightValue]){
        [Utility showError:@"请选择教学课程" type:ErrorType_Network];
        complete=false;
    }
    if([Utility isEmptyString:_studentNumItem.rightValue]){
        [Utility showError:@"请输入最多学习人数" type:ErrorType_Network];
        complete=false;
    }
    if(![Utility isEmptyString:_startHourItem.rightValue] && ![Utility isEmptyString:_endHourItem.rightValue] && [_startHourItem.rightValue compare:_endHourItem.rightValue]!=NSOrderedAscending){
        [Utility showError:@"结束时间必须大于开始时间" type:ErrorType_Network];
        complete=false;
    }
    
    if(complete){
        if(_course==nil){
            _course=[[Course alloc]init];
            _course.timetable=_calendarid;
        }
        _course.weekday=_weekday;
        _course.starttime=_startHourItem.rightValue;
        _course.endtime=_endHourItem.rightValue;
        _course.course=_courseItem.rightValue;
        _course.studentnum=_studentNumItem.rightValue;
        _course.remark=_remarkItem.rightValue;
        
        [self gotoBackWithParamaters:@{
                                       PAGE_PARAM_COURSE:_course,
                                       }];
        
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }else if([PAGE_PARAM_COURSE isEqualToString:key]){
        _course=value;
    }else if([PAGE_PARAM_WEEKDAY isEqualToString:key]){
        _weekday=value;
    }else if([PAGE_PARAM_COURSE_CALENDAR_ID isEqualToString:key]){
        _calendarid=value;
    }else if([@"availableTime" isEqualToString:key]){
        _availableTime=value;
    }
    
}
@end
