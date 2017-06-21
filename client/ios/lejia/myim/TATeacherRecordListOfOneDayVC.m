//
//  TATeacherRecordListOfOneDayVC.m
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherRecordListOfOneDayVC.h"
#import "TATeacherRecordCell.h"

@interface TATeacherRecordListOfOneDayVC ()<UITableViewDataSource,UITableViewDelegate,TATeacherRecordCellDelegate>{
    HeaderView* _headView;
    UITableView* _tableView;

    BOOL _loading;
    BOOL _isend;
    NSInteger _start;
    NSInteger _offset;

    NSString* _dateString;
    NSDate* _date;
    
    NSString* _teacherid;

    NSMutableArray<CourseAppointment*>* _records;
}

@end

@implementation TATeacherRecordListOfOneDayVC

- (void)viewDidLoad {
    [super viewDidLoad];

    _start=0;
    _offset=30;
    
    [self reloadView];
    [self reloadRemoteData];
}

-(void)viewWillAppear:(BOOL)animated{
    
    NSString* title=[NSString stringWithFormat:@"%@ (%@)",[Utility formatStringFromDate:_date withFormat:@"yyyy年MM月dd日"],[Utility weekdayStringFromDate:_date]];
    _headView.title=title;
}

-(void)reloadRemoteData{
    if(!_loading){
        _loading=true;
        [Remote teacherAppointmentListOfOneDay:_teacherid date:_date start:_start offset:_offset callback:^(StorageCallbackData *callback_data) {
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

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@""
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:nil];
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
        TATeacherRecordCell* cell=[[TATeacherRecordCell alloc]init];
        cell.appointment=_records[index];
        cell.delegate=self;
        cell.height=[TATeacherRecordCell calcLayoutHeightWithAppointment:_records[index] andMaxWidth:_tableView.width];
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
        CGFloat height=[TATeacherRecordCell calcLayoutHeightWithAppointment:_records[index] andMaxWidth:tableView.width];
        return height;
    }else{
        return 90;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    if(index<_records.count-1 || _isend){
        CourseAppointment* appointment=_records[index];
        if(![appointment isDeleted]){
            [self gotoPageWithClass:[TAAppointmentInfoVC class] parameters:@{
                                                                      PAGE_PARAM_APPOINTMENT:appointment,
                                                                      PAGE_PARAM_TEACHER_ID:_teacherid,
                                                                      PAGE_PARAM_INDEX:[NSNumber numberWithInt:index],
                                                                      }];
        }
    }
}


-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_DATE isEqualToString:key]){
        _dateString=value;
        _date=[Utility parseDateFromString:_dateString withFormat:nil];
    }else if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }
}

@end
