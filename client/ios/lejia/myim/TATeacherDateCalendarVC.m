//
//  TATeacherDateCalendarVC.m
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherDateCalendarVC.h"
#define PADDING 0
#define FONT_DAY [UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:selectCircleWidth*0.5]
#define FONT_MONTH FONT_DAY


typedef enum : NSUInteger {
    DayViewCourseStatusEmpty,
    DayViewCourseStatusAppintmentable,
    DayViewCourseStatusFull,
} DayViewCourseStatus;

@interface DayView : UIView
@end
@protocol DayViewDelegate <NSObject>

@required
-(NSDate*)todayForDayView:(DayView*)dayView;
-(NSDate*)selectedForDayView:(DayView*)dayView;

@end

@interface DayView(){
    UIView* _splitView;
    UILabel* _dayLabel;
    UILabel* _chineseDayLabel;
    UIView* _selectedCircleView;
    UIView* _courseStatusDot;
    NSDateComponents* _dateCom;
    
    
}
@property (nonatomic,retain) id<DayViewDelegate> delegate;
@property (nonatomic,retain) NSDate* date;
@property (nonatomic,assign) DayViewCourseStatus courseStatus;
//@property (nonatomic,assign) BOOL daySelected;
-(BOOL)isToday;
@end

@implementation DayView
-(void)setDate:(NSDate *)date{
    _date=date;
    if(_date==nil){
        _dateCom=nil;
    }else{
        _dateCom=[Utility dateComponentsFromDate:_date];
    }
    [self setNeedsLayout];
}
//-(void)setDaySelected:(BOOL)daySelected{
//    _daySelected=daySelected;
//    [self setNeedsLayout];
//}
-(void)setCourseStatus:(DayViewCourseStatus)courseStatus{
    _courseStatus=courseStatus;
    [self setNeedsLayout];
}

-(void)layoutSubviews{
    self.origin=(CGPoint){0,0};
    self.size=self.superview.size;
    self.backgroundColor=[UIColor whiteColor];
    if(_splitView==nil){
        _splitView=[[UIView alloc]init];
        [self addSubview:_splitView];
    }
    _splitView.origin=(CGPoint){0,0};
    _splitView.size=(CGSize){self.width,0.5};
    _splitView.backgroundColor=COLOR_SPLIT;
    if(_date!=nil){
        UIColor* selectCircleColor=COLOR_TEXT_HIGHLIGHT;
        if([self isToday]){
            selectCircleColor=[UIColor redColor];
        }
//        else if([self isExpired]){
//            selectCircleColor=COLOR_SPLIT;
//        }
        
        if(_selectedCircleView==nil){
            _selectedCircleView=[[UIView alloc]init];
            [self addSubview:_selectedCircleView];
        }
        _selectedCircleView.backgroundColor=selectCircleColor;
        CGFloat selectCircleWidth=self.width-10;
        _selectedCircleView.size=(CGSize){selectCircleWidth,selectCircleWidth};
        _selectedCircleView.layer.cornerRadius=selectCircleWidth/2;
        _selectedCircleView.centerX=self.width/2;
        _selectedCircleView.top=5;
        if([self willShowCircle]){
            _selectedCircleView.hidden=false;
        }else{
            _selectedCircleView.hidden=true;
        }
        
        UIColor* dayColor=[UIColor blackColor];
        if([self isWeekend]){
    //        dayColor=COLOR_TEXT_SECONDARY;
        }
        if([self isToday] || [self isSelectedDay]){
            dayColor=[UIColor whiteColor];
        }else if([self isExpired]){
            dayColor=COLOR_SPLIT;
        }
        
        if(_dayLabel==nil){
            _dayLabel=[[UILabel alloc]init];
            [self addSubview:_dayLabel];
        }
        _dayLabel.textColor=dayColor;
        _dayLabel.text=[self getDayString];
        _dayLabel.font=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:selectCircleWidth*0.5];
        [Utility fitLabel:_dayLabel];
        //    CGSize size=_dayLabel.size;
        //    [_dayLabel fit];
        
        if(_chineseDayLabel==nil){
            _chineseDayLabel=[[UILabel alloc]init];
            [self addSubview:_chineseDayLabel];
        }
        _chineseDayLabel.textColor=dayColor;
        _chineseDayLabel.text=[Utility chineseCalendarWithDate:_date];
        _chineseDayLabel.font=[UIFont fontWithName:_dayLabel.font.familyName size:_dayLabel.font.pointSize*0.5];
        [_chineseDayLabel fit];
        
        CGFloat dayPadding=0;
        _dayLabel.center=_selectedCircleView.center;
        _dayLabel.top-=(_chineseDayLabel.height+dayPadding)/2;
        _chineseDayLabel.centerX=_dayLabel.centerX;
        _chineseDayLabel.top=_dayLabel.bottom+dayPadding;
    }else{
        [_dayLabel removeFromSuperview];
        [_chineseDayLabel removeFromSuperview];
        [_selectedCircleView removeFromSuperview];
        [_courseStatusDot removeFromSuperview];
        
        _dayLabel=nil;
        _chineseDayLabel=nil;
        _selectedCircleView=nil;
        _courseStatusDot=nil;
    }
}

-(BOOL)isWeekend{
    return (_dateCom.weekday==1||_dateCom.weekday==7);
}
-(NSString*)getDayString{
    NSDateComponents* dateCom=[Utility dateComponentsFromDate:_date];
    return [NSString stringWithFormat:@"%d",dateCom.day];
}
-(BOOL)isToday{
    NSDate* today=nil;
    if(_delegate!=nil){
        today=[_delegate todayForDayView:self];
    }
    if(today==nil){
        today=[NSDate date];
    }
    NSDateComponents* todayCom=[Utility dateComponentsFromDate:today];
    
    
    return (todayCom.year==_dateCom.year && todayCom.month==_dateCom.month && todayCom.day==_dateCom.day);
}
-(BOOL)isSelectedDay{
    NSDate* selectedday=nil;
    if(_delegate!=nil){
        selectedday=[_delegate selectedForDayView:self];
    }
    if(selectedday==nil){
        return false;
    }
    NSDateComponents* selecteddayCom=[Utility dateComponentsFromDate:selectedday];
    
    BOOL ret=(selecteddayCom.year==_dateCom.year && selecteddayCom.month==_dateCom.month && selecteddayCom.day==_dateCom.day);
    return ret;
}

-(BOOL)isExpired{
    NSDate* today=nil;
    if(_delegate!=nil){
        today=[_delegate todayForDayView:self];
    }
    if(today==nil){
        today=[NSDate date];
    }
    return ((long)[_date timeIntervalSince1970])<((long)[today timeIntervalSince1970]);
    
}

-(BOOL)willShowCircle{
    return [self isSelectedDay] || [self isToday];// || [self isExpired];

}

@end

@interface DayCell : UICollectionViewCell
@property (nonatomic,retain) DayView* dayView;
@end

@implementation DayCell
-(void)setDayView:(DayView *)dayView{
    _dayView=dayView;
    
    for(UIView* v in self.contentView.subviews){
        [v removeFromSuperview];
    }
    [self.contentView addSubview:_dayView];
}
@end

@interface RefreshCell : UICollectionViewCell{
    UILabel* _textLabel;
}
@end
@implementation RefreshCell
-(void)layoutSubviews{
    self.height=40;
    if(_textLabel==nil){
        _textLabel=[[UILabel alloc]init];
        [self.contentView addSubview:_textLabel];
        _textLabel.text=@"正在加载数据";
        _textLabel.textColor=COLOR_TEXT_NORMAL;
        _textLabel.font=FONT_TEXT_NORMAL;
        [_textLabel fit];
    }
    _textLabel.center=_textLabel.superview.innerCenterPoint;
}
@end


@interface MonthCell : UICollectionViewCell{
    UILabel* _monthLabel;
}
@property (nonatomic,assign) NSInteger month;
@property (nonatomic,assign) NSInteger space;
@end
@implementation MonthCell
-(void)setMonth:(NSInteger)month{
    _month=month;
    [self setNeedsLayout];
}
-(void)setSpace:(NSInteger)space{
    _space=space;
    [self setNeedsLayout];
}
-(void)layoutSubviews{
    if(_monthLabel==nil){
        _monthLabel=[[UILabel alloc]init];
        [self.contentView addSubview:_monthLabel];
    }
    CGFloat cellWidth=self.width/7;
    _monthLabel.textColor=[UIColor blackColor];
    _monthLabel.font=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:(cellWidth-10)*0.5];
    _monthLabel.text=[NSString stringWithFormat:@"%d月",_month];
    [_monthLabel fit];
    _monthLabel.centerX=_space*cellWidth+cellWidth/2;
    _monthLabel.centerY=self.height/2;
    self.backgroundColor=COLOR_TEXT_HIGHLIGHT_LIGHT;
}
@end

@interface TATeacherDateCalendarVC ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,DayViewDelegate,UIAlertViewDelegate>{
    HeaderView* _headView;
    
    UICollectionView* _collectionView;
    NSInteger _oneday;
    NSDate* _today;
    NSDate* _startDate;
    
    NSUInteger _showMonthBegin;
    NSUInteger _showMonthCount;
    
    NSString* _teacherid;
    NSDate* _selectedDate;
    
    CourseTimeTable* _timetable;
}

@end

@implementation TATeacherDateCalendarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _oneday=60*60*24;
    _showMonthBegin=0;
    _showMonthCount=3;
    
    _today=[NSDate date];
    NSDateComponents* todayCom=[Utility dateComponentsFromDate:_today];
    NSInteger _weekdayDel=(todayCom.weekday==1?6:(todayCom.weekday-2))*-1;
    _startDate=[[NSDate alloc]initWithTimeInterval:_weekdayDel*_oneday sinceDate:_today];
    
    [self reloadView];
    [self reloadRemoteData];
    
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote teacherAllTimeTable:_teacherid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            NSArray<CourseTimeTable*>* calendars=callback_data.data;
            if(calendars.count>0){
                _timetable=calendars[0];
            }else{
                runInMain(^{
                    [self showGotoTimeTableAlert];
                });
            }
            [self reloadData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
    
}


-(void)showGotoTimeTableAlert{
    UIAlertView* alertDeleteView=[[UIAlertView alloc]initWithTitle:@"需要设置课表"
                                                           message:@"您没有有效的课表\n没有课表您的学员就无法预约。\n现在去设置课表吗？"
                                                          delegate:self
                                                 cancelButtonTitle:@"设置课表"
                                                 otherButtonTitles:@"暂不设置",nil];
    alertDeleteView.tagObject=@{
                                @"action":@"createtimetable",
                                };
    [alertDeleteView show];
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* action=alertView.tagObject[@"action"];
    if([@"createtimetable" isEqualToString:action]){
        if(buttonIndex==0){
            [self gotoPageWithClass:[TATeacherTimeTableVC class] parameters:@{
                                                                              PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                              }];
        }
    }
}


-(void)reloadView{
    [super reloadView];
    
    UIView* leftButton=[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)];
    UIView* rightButton=[HeaderView genItemWithText:@"课程表" target:self action:@selector(showTimeTable:)];
    
    _headView=[[HeaderView alloc]initWithTitle:@"约车日历"
                                    leftButton:leftButton
                                   rightButton:rightButton];
    
    [self.view addSubview:_headView];
    
    
    UIView* weekView=[[UIView alloc]init];
    [self.view addSubview:weekView];
    weekView.backgroundColor=COLOR_HEADER_BG;
    weekView.origin=(CGPoint){0,_headView.bottom};
    weekView.size=(CGSize){weekView.superview.width,10};
    UILabel* w1=[Utility genLabelWithText:@"周一" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w2=[Utility genLabelWithText:@"周二" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w3=[Utility genLabelWithText:@"周三" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w4=[Utility genLabelWithText:@"周四" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w5=[Utility genLabelWithText:@"周五" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w6=[Utility genLabelWithText:@"周六" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    UILabel* w7=[Utility genLabelWithText:@"周日" bgcolor:nil textcolor:COLOR_HEADER_TEXT font:FONT_TEXT_SECONDARY];
    
    NSArray<UILabel*>* w=@[w1,w2,w3,w4,w5,w6,w7];
    for(int i=0;i<w.count;i++){
        [weekView addSubview:w[i]];
        [w[i] fit];
        w[i].textAlignment=NSTextAlignmentCenter;
        w[i].centerX=(w[i].superview.width/w.count)*i+((w[i].superview.width/w.count)/2);
        w[i].top=0;
    }
    [weekView fitHeightOfSubviews];
    weekView.height+=5;
    
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, weekView.bottom, self.view.width, self.view.height-weekView.bottom) collectionViewLayout:flowLayout];
    [_collectionView registerClass:[DayCell class] forCellWithReuseIdentifier:@"day_cell"];
    [_collectionView registerClass:[RefreshCell class] forCellWithReuseIdentifier:@"refresh_cell"];
    [_collectionView registerClass:[MonthCell class] forSupplementaryViewOfKind:@"UICollectionElementKindSectionHeader" withReuseIdentifier:@"month_cell"];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.backgroundColor=[UIColor whiteColor];
    _collectionView.bounces=false;
    [self.view addSubview:_collectionView];
    [_collectionView setContentOffset:(CGPoint){0,40} animated:false];
    
}
-(NSDate*)getDateWithIndexPath:(NSIndexPath*)indexPath{
    NSInteger month=_showMonthBegin+indexPath.section-1;
    NSInteger space=[self spaceOfSection:indexPath.section];
    if(indexPath.row<space){
        return nil;
    }else{
        NSDate* date=[Utility getDateFromDate:_today withMonth:month];
        NSDateComponents* dateCom=[Utility dateComponentsFromDate:date];
        [dateCom setDay:indexPath.row-space+1];
        return [Utility dateWithDateComponents:dateCom];
    }
}
-(NSInteger)spaceOfSection:(NSInteger)section{
    NSInteger month=_showMonthBegin+section-1;
    NSDate* date=[Utility getDateFromDate:_today withMonth:month];
    NSDate* firstDate=[Utility firstDaysOfMonthWithDate:date];
    NSInteger firstWeekday=[Utility getWeekdayWithDate:firstDate];
    return (firstWeekday==1?6:firstWeekday-2);
}

-(NSInteger)monthInSection:(NSInteger)section{
    NSInteger month=_showMonthBegin+section-1;
    NSDate* date=[Utility getDateFromDate:_today withMonth:month];
    NSDateComponents* dateCom=[Utility dateComponentsFromDate:date];
    return dateCom.month;
}

-(NSDate*)todayForDayView:(DayView *)dayView{
    return _today;
}
-(NSDate*)selectedForDayView:(DayView *)dayView{
    return _selectedDate;
}

//返回日期Cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        NSString* cellname=@"refresh_cell";
        RefreshCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellname forIndexPath:indexPath];
        return cell;
        
    }else{
        NSString* cellname=@"day_cell";
        DayCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellname forIndexPath:indexPath];
        NSDate* date=[self getDateWithIndexPath:indexPath];
        DayView* dayView=[[DayView alloc]init];
        dayView.delegate=self;
        dayView.date=date;
        cell.dayView=dayView;
        return cell;
    }
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _showMonthCount+1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0){
        return 1;
    }else{
        NSInteger month=_showMonthBegin+section-1;
        NSDate* date=[Utility getDateFromDate:_today withMonth:month];
        return [Utility daysOfMonthWithDate:date].length+[self spaceOfSection:section];
    }
}
//月份
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSInteger section=indexPath.section;
    if(section==0){
        return nil;
    }else{
        MonthCell* ret=[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"month_cell" forIndexPath:indexPath];
        ret.month=[self monthInSection:section];
        ret.space=[self spaceOfSection:indexPath.section];
        return ret;
    }
    
}
//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return (UIEdgeInsets){PADDING,PADDING,PADDING,PADDING};
}
//设置顶部的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section==0){
        return (CGSize){collectionView.width,0};
    }else{
        return (CGSize){collectionView.width,30};
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return (CGSize){0,0};
}

//设置元素大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return (CGSize){collectionView.width,40};
    }else{
        CGFloat w=collectionView.superview.width/7-(2*PADDING);
        return (CGSize){w,w*1.2};
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section>0){
        DayCell* dayCell=(DayCell*)[collectionView cellForItemAtIndexPath:indexPath];
        
        if(dayCell!=nil && [dayCell isKindOfClass:[dayCell class]] && dayCell.dayView.date!=nil){
            _selectedDate=dayCell.dayView.date;
            [self reloadData];

            runDelayInMain(^{
                NSString* dateString=[_selectedDate formatedString];
                [self gotoPageWithClass:[TATeacherRecordListOfOneDayVC class] parameters:@{
                                                                                                            PAGE_PARAM_DATE:dateString,
                                                                                                            PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                                                            }];
            }, 0.1);
        }
    }
    
}

-(void)reloadData{
    [_collectionView reloadData];
    [self scrollToFirstMonthIfNeed:false];
}
-(void)scrollToFirstMonthIfNeed:(BOOL)animate{
    if(_collectionView.contentOffset.y<40){
        CGRect targetRect=(CGRect){0,_collectionView.height+39,_collectionView.width,1};
        [_collectionView scrollRectToVisible:targetRect animated:animate];
    }
}
-(void)checkScrollPosition:(UIScrollView*)scrollView{
    if(scrollView.contentOffset.y<40){
        _showMonthBegin-=1;
        _showMonthCount+=1;
        [_collectionView reloadData];
        
    }
    [self scrollToFirstMonthIfNeed:true];
}

-(void)showTimeTable:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[TATeacherTimeTableVC class] parameters:@{
                                                                     PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                     }];
}

#pragma mark 上拉刷新
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGSize size=scrollView.contentSize;
    CGPoint p=scrollView.contentOffset;
    CGFloat h=scrollView.height;
    CGFloat scrollBottom=p.y+h;
    if(scrollBottom>size.height-20){
        _showMonthCount+=3;
        [self reloadData];
    }
}

-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [self checkScrollPosition:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self checkScrollPosition:scrollView];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }
}

@end
