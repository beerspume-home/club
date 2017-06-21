//
//  TAStudentTeacherListVC.m
//  myim
//
//  Created by Sean Shi on 15/11/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TAStudentTeacherListVC.h"

@interface ViewCell : UITableViewCell
@end
@protocol ViewCellDelegate <NSObject>
@end
@interface ViewCell(){
    UIImageView* _headIcon;
    UILabel* _certifiedLabel;
    UILabel* _nameLabel;
    
}
@property (nonatomic,retain) Teacher* teacher;
@property (nonatomic,retain) id<ViewCellDelegate> delegate;
@end
@implementation ViewCell
-(instancetype)init{
    ViewCell* ret=[super init];
    self.height=60;
    return ret;
}
-(void)layoutSubviews{
    if(_headIcon==nil){
        _headIcon=[[UIImageView alloc]init];
        [self addSubview:_headIcon];
    }
    NSURL* headUrl=[NSURL URLWithString:_teacher.person.imageurl];
    [_headIcon sd_setImageWithURL:headUrl placeholderImage:[UIImage imageNamed:@"缺省头像"]];
    CGFloat iconWidth=self.height*0.8;
    _headIcon.size=CGSizeMake(iconWidth, iconWidth);
    _headIcon.centerY=_headIcon.superview.height/2;
    _headIcon.left=15;
    
    if(_certifiedLabel!=nil){
        [_certifiedLabel removeFromSuperview];
    }
    _certifiedLabel=[UIUtility genCertifiedLabel:[_teacher isCertified]];
    [self addSubview:_certifiedLabel];
    
    if(_nameLabel==nil ){
        _nameLabel=[[UILabel alloc]init];
        [self addSubview:_nameLabel];
        _nameLabel.textColor=COLOR_TEXT_NORMAL;
        _nameLabel.font=FONT_TEXT_NORMAL;
    }
    _nameLabel.text=_teacher.person.name;
    [Utility fitLabel:_nameLabel];
    _nameLabel.centerY=_headIcon.centerY-_certifiedLabel.height/2-1.5;
    _nameLabel.left=_headIcon.right+10;
    if(_nameLabel.width>_nameLabel.superview.width-15-_nameLabel.left){
        _nameLabel.width=_nameLabel.superview.width-15-_nameLabel.left;
    }
    _certifiedLabel.origin=CGPointMake(_nameLabel.left, _nameLabel.bottom+3);
    
}

@end


@interface TAStudentTeacherListVC ()<UITableViewDataSource,UITableViewDelegate>{
    HeaderView* _headView;
    UITableView* _tableView;
    
    NSString* _studentid;
    NSArray<Teacher*>* _teachers;
    
    NSMutableArray<ViewCell*>* _viewcells;
}

@end

@implementation TAStudentTeacherListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
    [self reloadRemoteData];
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote appointmentTeacherList:_studentid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _teachers=callback_data.data;
            [_tableView reloadData];
        }else{
            [Utility showError:callback_data.message];
        }
        [lv removeFromSuperview];
    }];
}

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@"可预约教练"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:nil];
    [self.view addSubview:_headView];
    
    _tableView=[[UITableView alloc]init];
    [_tableView fillSuperview:self.view underOf:_headView];
    _tableView.delegate=self;
    _tableView.dataSource=self;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _teachers==nil?0:_teachers.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewCell* cell=[self getViewCellAtIndex:indexPath.row];
    if([[NSNull null] isEqual:cell]){
        return 0;
    }else{
        return cell.height;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ViewCell* cell=[self getViewCellAtIndex:indexPath.row];
    cell.teacher=_teachers[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Teacher* teacher=_teachers[indexPath.row];
    [self gotoPageWithClass:[TAStudentCalendarVC class] parameters:@{
                                                                           PAGE_PARAM_STUDENT_ID:_studentid,
                                                                           PAGE_PARAM_TEACHER_ID:teacher.id,
                                                                           PAGE_PARAM_TEACHER:teacher,
                                                                           }];
}
-(ViewCell*)getViewCellAtIndex:(NSInteger)index{
    if(_viewcells==nil){
        _viewcells=[Utility initArray:nil];
    }
    if(index<0){
        return nil;
    }
    if(index>((int)_viewcells.count)-1){
        for(int i=_viewcells.count;i<=index;i++){
            [_viewcells addObject:(ViewCell*)[NSNull null]];
        }
        [_viewcells replaceObjectAtIndex:index withObject:[[ViewCell alloc]init]];
    }
    return _viewcells[index];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_STUDENT_ID isEqualToString:key]){
        _studentid=value;
    }
}
@end

