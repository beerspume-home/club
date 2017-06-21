//
//  OperationEditClasses.m
//  myim
//
//  Created by Sean Shi on 15/11/16.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditClasses.h"
@interface ClassCell : UITableViewCell
@end
@protocol ClassCellDelegate <NSObject>
@required
-(void)classCell:(ClassCell*)classCell deleteSchoolClas:(SchoolClass*)schoolClass;
-(void)classCell:(ClassCell*)classCell changePublishOn:(BOOL)on schoolClas:(SchoolClass*)schoolClass;

@end

@interface ClassCell(){
    UIView* _classView;
    UISwitch* _publishSwitch;
    
    BOOL _inited;
}
@property (nonatomic,retain) SchoolClass* schoolClass;
@property (nonatomic,retain) id<ClassCellDelegate> delegate;
-(void)setPublish:(BOOL)on;
@end
@implementation ClassCell
#define PADDING 10

-(void)setPublish:(BOOL)on{
    if(_publishSwitch!=nil){
        [_publishSwitch setOn:on];
    }
}
-(void)initView{

    
    if(_classView==nil){
        UIFont* font=FONT_TEXT_SECONDARY;
        CGFloat splitPadding=10;
        CGFloat leftWidth= getStringSize(@"四个字宽", font).width+20;
        CGFloat rightWidth=self.contentView.width-leftWidth-splitPadding*2-12;
        NSArray* contentDict=@[
                               @{@"课程名称:":[NSString stringWithFormat:@"(%@) %@",_schoolClass.licensetype,_schoolClass.name]},
                               @{@"价格:":[NSString stringWithFormat:@"%@ 元",_schoolClass.fee]},
                               @{@"训练时间:":_schoolClass.trainingtime},
                               @{@"训练车型:":_schoolClass.cartype},
                               @{@"到期日期:":_schoolClass.expiredate},
                               @{@"备注:":_schoolClass.remark},
                               ];
    
        _classView=[[UIView alloc]init];
        [self.contentView addSubview:_classView];
        _classView.top=PADDING;
        _classView.left=12;
        _classView.size=CGSizeMake(_classView.superview.width-24, 0);
        _classView.backgroundColor=[UIColor whiteColor];
        _classView.layer.masksToBounds=false;
        _classView.layer.borderWidth=1;
        _classView.layer.borderColor=[COLOR_BUTTON_BG CGColor];
        _classView.layer.cornerRadius=3;
        _classView.layer.shadowColor=[[UIColor blackColor]CGColor];
        _classView.layer.shadowOpacity=0.5;
        _classView.layer.shadowOffset=CGSizeMake(0, 0);
        
        UIView* split0View=[[UIView alloc]init];
        [_classView addSubview:split0View];
        split0View.origin=CGPointMake(leftWidth+(splitPadding/2), 0);
        split0View.size=CGSizeMake(0.5, 0);
        split0View.backgroundColor=COLOR_SPLIT;
        
        CGFloat yy=10;
        for(int j=0;j<contentDict.count;j++){
            NSDictionary* line=contentDict[j];
            NSString* name=[line keyEnumerator].nextObject;
            NSString* value=[line objectForKey:name];
            
            //标题
            UILabel* titleLabel=[Utility genLabelWithText:name bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:font];
            [_classView addSubview:titleLabel];
            titleLabel.right=leftWidth;
            titleLabel.top=yy;
            //内容
            UILabel* valueLabel=[Utility genLabelWithText:value bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:font];
            [_classView addSubview:valueLabel];
            valueLabel.numberOfLines=0;
            valueLabel.text=value;
            [valueLabel fitWithWidth:rightWidth-10];
            valueLabel.origin=CGPointMake(leftWidth+splitPadding, titleLabel.top);
            
            UIView* splitView=[[UIView alloc]init];
            [_classView addSubview:splitView];
            splitView.left=0;
            splitView.top=(titleLabel.bottom>valueLabel.bottom?titleLabel.bottom:valueLabel.bottom)+10;
            splitView.size=CGSizeMake(0, 0.5);
            splitView.backgroundColor=COLOR_SPLIT;
            splitView.width=splitView.superview.width;
            
            yy=splitView.bottom+10;
            split0View.height=splitView.bottom;
        }
        
        //删除按钮
        UILabel* deleteLabel=[UIUtility genButtonToSuperview:_classView
                                                         top:yy
                                                       title:@"删除"
                                             backgroundColor:COLOR_BUTTON_BG
                                                   textColor:COLOR_BUTTON_TEXT
                                                       width:80
                                                      height:30
                                                      target:self
                                                      action:@selector(delete:)
                              ];
        
        deleteLabel.left=10;

        //发布状态
        if(_publishSwitch==nil){
            _publishSwitch=[[UISwitch alloc]init];
            [_classView addSubview:_publishSwitch];
            [_publishSwitch addTarget:self action:@selector(switchPublish:) forControlEvents:UIControlEventValueChanged];
            
        }
        _publishSwitch.right=_publishSwitch.superview.width-10;
        _publishSwitch.centerY=deleteLabel.centerY;
        [_publishSwitch setOn:[@"published" isEqualToString:_schoolClass.status]];
        UILabel* publishLabel=[Utility genLabelWithText:@"发布状态" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
        [_classView addSubview:publishLabel];
        publishLabel.right=_publishSwitch.left-5;
        publishLabel.centerY=_publishSwitch.centerY;

        
        [_classView fitHeightOfSubviews];
        _classView.height+=10;
        
        self.height=_classView.bottom+PADDING;
    }
    if(!_inited){
        _inited=true;
    }
}
-(void)layoutSubviews{
    [self initView];
    _classView.left=12;
    _classView.centerY=self.contentView.height/2;
}


-(void)switchPublish:(UISwitch*)sender{
    if(_delegate!=nil){
        [_delegate classCell:self changePublishOn:[sender isOn] schoolClas:_schoolClass];
    }
}

-(void)delete:(UIGestureRecognizer*)sender{
    if(_delegate!=nil){
        [_delegate classCell:self deleteSchoolClas:_schoolClass];
    }
}
@end



@interface OperationEditClasses ()<UITableViewDataSource,UITableViewDelegate,ClassCellDelegate>{
    NSString* _schoolid;
    NSMutableArray<SchoolClass*>* _schoolClasses;
    HeaderView* _headView;
    
    UITableView* _tableView;
    NSMutableArray<ClassCell*>* _cells;
    
}

@end

@implementation OperationEditClasses

- (void)viewDidLoad {
    [super viewDidLoad];
    _schoolClasses=[Utility initArray:nil];
    _cells=[Utility initArray:nil];
    [self reloadView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadRemoteData];
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote allSchoolClass:_schoolid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _schoolClasses=callback_data.data;
            _cells=[Utility initArray:_cells];
            [self refreshData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}
-(void)refreshData{
    [_tableView reloadData];
}

-(void)reloadView{
    [super reloadView];
    
    _headView=[[HeaderView alloc]
               initWithTitle:@"驾校班级"
               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
               rightButton:[HeaderView genItemWithText:@"添加" target:self action:@selector(add:)]
               backgroundColor:COLOR_HEADER_BG
               titleColor:COLOR_HEADER_TEXT
               height:HEIGHT_HEAD_DEFAULT
               ];
    [self.view addSubview:_headView];
    
    _tableView=[[UITableView alloc]init];
    [self.view addSubview:_tableView];
    _tableView.origin=(CGPoint){0,_headView.bottom};
    _tableView.size=(CGSize){_tableView.superview.width,_tableView.superview.height-_tableView.top};
    _tableView.delegate=self;
    _tableView.dataSource=self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _schoolClasses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    ClassCell* cell=[self getCell:index];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    ClassCell* cell=[self getCell:index];
    return cell.height;
}
- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    return false;
}
-(void)classCell:(ClassCell *)classCell deleteSchoolClas:(SchoolClass *)schoolClass{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote changeStatusSchoolClass:[Storage getOperation].id schoolclassid:schoolClass.id status:@"delete" callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [self reloadRemoteData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}
-(void)classCell:(ClassCell *)classCell changePublishOn:(BOOL)on schoolClas:(SchoolClass *)schoolClass{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote changeStatusSchoolClass:[Storage getOperation].id schoolclassid:schoolClass.id status:on?@"published":@"new" callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
            [classCell setPublish:!on];
        }
        [lv removeFromSuperview];
    }];
}

-(ClassCell*)getCell:(NSInteger)index{
    if(index<0 || index>=_schoolClasses.count)return nil;
    if(index>=_cells.count){
        for(int i=_cells.count;i<=index;i++){
            [_cells addObject:(ClassCell*)[NSNull null]];
        }
    }
    ClassCell* cell=_cells[index];
    if([cell isEqual:[NSNull null]]){
        NSString* cellname=@"cell";
        cell=[[ClassCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
        cell.schoolClass=_schoolClasses[index];
        cell.delegate=self;
        [cell layoutSubviews];
        [_cells replaceObjectAtIndex:index withObject:cell];
    }
    return cell;
}
-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }
}

-(void)add:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[OperationEditClassAddVC class] parameters:@{
                                                                         PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                         }];
}
@end



