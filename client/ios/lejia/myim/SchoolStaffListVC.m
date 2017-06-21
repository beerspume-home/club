//
//  SchoolStaffListVC.m
//  myim
//
//  Created by Sean Shi on 15/11/4.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SchoolStaffListVC.h"

@interface SchoolStaffListVC ()<UITableViewDelegate,UITableViewDataSource>{
    UIView* _headView;
    NSString* _schoolid;
    NSMutableArray* _contacts_all;
    NSArray* _letter_order;
    NSMutableDictionary* _letter_mapping;
    
    UITableView* _tableView;
    
    NSString* _charactertype;
    NSString* _title;
    BOOL _editmode;
    UIImage* _defaultIcon;

    MenuView* _menu;
}

@end

@implementation SchoolStaffListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _defaultIcon=[UIImage imageNamed:@"缺省头像"];
    _letter_order=[Utility initArray:nil];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadRemoteData];
}
-(void)reloadRemoteData{
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote allStaffOfSchool:_schoolid charactertype:_charactertype callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [self orderContacts:(NSMutableArray*)callback_data.data];
            [_tableView reloadData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)orderContacts:(NSMutableArray*)contacts{
    _contacts_all=contacts;
    _letter_mapping=[Utility initDictionary:nil];
    NSMutableArray* __letter_order=[Utility initArray:nil];
    for(Person* person in _contacts_all){
        NSString* firstletter=person.socialname_firstletter;
        if(![__letter_order containsObject:firstletter]){
            [__letter_order addObject:firstletter];
        }
        NSMutableArray* letterArray=(NSMutableArray*)_letter_mapping[firstletter];
        if(letterArray==nil){
            letterArray=[Utility initArray:nil];
            _letter_mapping[firstletter]=letterArray;
        }
        [letterArray addObject:person];
    }
    _letter_order=[__letter_order sortedArrayUsingSelector:@selector(compare:)];
}
-(Person*)personWithIndexPath:(NSIndexPath*)indexPath{
    NSString* letter=_letter_order[indexPath.section];
    return (((NSMutableArray*)_letter_mapping[letter])[indexPath.row]);
}

-(void)reloadView{
    [super reloadView];
    
    UIView* rightButton=nil;
    if(_editmode){
        rightButton=[HeaderView genItemWithText:@"筛选" target:self action:@selector(showMenu:)];
    }
    
    _headView=[[HeaderView alloc]initWithTitle:_title
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                              rightButton:rightButton
                          ];
    [self.view addSubview:_headView];
    
    if(_tableView==nil){
        _tableView=[[UITableView alloc]init];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorInset=UIEdgeInsetsMake(
                                                   _tableView.separatorInset.top,
                                                   _tableView.separatorInset.left,
                                                   _tableView.separatorInset.bottom,
                                                   _tableView.separatorInset.left);
        [self.view addSubview:_tableView];
        _tableView.origin=CGPointMake(0, _headView.bottom);
        _tableView.size=CGSizeMake(_tableView.superview.width, _tableView.superview.height-_tableView.top);
        _tableView.bounces=false;
    }
    
}

-(UIView*) genLineViewInSuperView:(nonnull UIView*)superview person:(Person*)person{
    NSString* title=person.socialname;
    NSURL* url=[[NSURL alloc]initWithString:person.imageurl];

    
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.width=ret.superview.width;
    ret.height=46;
    UIImageView* iconView=[[UIImageView alloc]init];
    if(url==nil){
        iconView.image=_defaultIcon;
    }else{
        [iconView sd_setImageWithURL:url placeholderImage:_defaultIcon];
    }
    [ret addSubview:iconView];
    CGFloat iconWidth=ret.height*0.8;
    iconView.size=CGSizeMake(iconWidth, iconWidth);
    iconView.centerY=iconView.superview.height/2;
    iconView.left=15;
    
    //认证标记
    UILabel* certifiedLabel=[UIUtility genCertifiedLabel:[person isCertified]];
    [ret addSubview:certifiedLabel];
    
    //昵称
    UILabel* titleLabel=[[UILabel alloc]init];
    [ret addSubview:titleLabel];
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.text=title;
    [Utility fitLabel:titleLabel];
    titleLabel.centerY=iconView.centerY-certifiedLabel.height/2-1.5;
    titleLabel.left=iconView.right+10;
    if(titleLabel.width>superview.width-15-titleLabel.left){
        titleLabel.width=superview.width-15-titleLabel.left;
    }
    certifiedLabel.origin=CGPointMake(titleLabel.left, titleLabel.bottom+3);

    NSString* rightText=[NSString stringWithFormat:@"%@ ",person.school_name];
    if(_editmode){//编辑模式
        //真实姓名
        NSString* name=[NSString stringWithFormat:@"姓名:%@",[Utility isEmptyString:person.name]?@"[尚未输入]":person.name];
        UILabel* nameLabel=[Utility genLabelWithText:name bgcolor:nil textcolor:COLOR_TEXT_SECONDARY font:FONT_TEXT_SECONDARY];
        [ret addSubview:nameLabel];
        nameLabel.left=certifiedLabel.right+5;
        nameLabel.centerY=certifiedLabel.centerY;
        rightText=@"";
    }
    //展示模式
    if([person isTeacher]){
        rightText=[rightText stringByAppendingFormat:@"%@",@"教练"];
    }else if ([person isCustomerService]){
        rightText=[rightText stringByAppendingFormat:@"%@",@"客服"];
    }else if([person isOperation]){
        rightText=[rightText stringByAppendingFormat:@"%@",@"运营"];
    }
    
    if(rightText!=nil){
        UILabel* teacherLabel=[Utility genLabelWithText:rightText
                                                bgcolor:[UIColor clearColor]
                                              textcolor:COLOR_TEXT_SECONDARY
                                                   font:FONT_TEXT_SECONDARY];
        [superview addSubview:teacherLabel];
        teacherLabel.textAlignment=NSTextAlignmentRight;
        teacherLabel.numberOfLines=0;
        teacherLabel.right=teacherLabel.superview.width-15;
        teacherLabel.centerY=teacherLabel.superview.height/2;
    }
    return ret;
}
-(UITableViewCell*) getTableCellWithIndexPath:(NSIndexPath*)indexPath{
//    NSInteger section=indexPath.section;
//    NSInteger index=indexPath.row;
    
    UITableViewCell* cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    cell.contentView.width=_tableView.width;
    Person* person=[self personWithIndexPath:indexPath];
    [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                       person:person
                                  ]
     ];
    return cell;
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _letter_order.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString* letter=_letter_order[section];
    return  ((NSArray*)_letter_mapping[letter]).count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableCellWithIndexPath:indexPath];
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view=[[UIView alloc]init];
    view.height=20;
    view.backgroundColor=COLOR_TABLE_SECTION_BG;
    UILabel* letterLabel=[[UILabel alloc]init];
    [view addSubview:letterLabel];
    letterLabel.font=FONT_TEXT_SECONDARY;
    letterLabel.textColor=COLOR_TABLE_SECTION_TEXT;
    letterLabel.text=_letter_order[section];
    [Utility fitLabel:letterLabel];
    letterLabel.left=15;
    letterLabel.centerY=letterLabel.superview.height/2;
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person* selectedPerson=[self personWithIndexPath:indexPath];
    if(_editmode){
        [self gotoPageWithClass:[OperationEditStaffVC class] parameters:@{
                                                                          PAGE_PARAM_PERSONID:selectedPerson.id,
                                                                          }];
    }else{
        [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                  PAGE_PARAM_PERSON:selectedPerson,
                                                                  }];
    }
}

#pragma mark 事件方法

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }else if([PAGE_PARAM_CHARACTERTYPE isEqualToString:key]){
        _charactertype=value;
    }else if([PAGE_PARAM_TITLE isEqualToString:key]){
        _title=value;
    }else if([PAGE_PARAM_EDIT isEqualToString:key]){
        _editmode=true;
    }
}


-(void)showMenu:(UIGestureRecognizer*)sender{
    if(_menu==nil){
        CGFloat w=100;
        _menu=[[MenuView alloc] initWithFrame:CGRectMake(getScreenSize().width-w-10, _headView.bottom, w, 0)];
        sender.view.tagObject=_menu;
        _menu.layer.shadowColor = [UIColor blackColor].CGColor;
        _menu.layer.shadowOffset = CGSizeMake(0,0);
        _menu.layer.shadowOpacity = 0.3;
        _menu.layer.shadowRadius = 3.0;
        [_menu addItem:@"全部员工" target:self action:@selector(menu_filter_all)];
        [_menu addItem:@"教练" target:self action:@selector(menu_filter_teacher)];
        [_menu addItem:@"客服" target:self action:@selector(menu_filter_customerservice)];
        [_menu addItem:@"运营" target:self action:@selector(menu_filter_operation)];
        [self.view addSubview:_menu];
        [_menu reloadView];
        _menu.hidden=true;
    }
    [self.view bringSubviewToFront:_menu];
    if(_menu.hidden){
        _menu.right=self.view.width-10;
        _menu.top=_headView.bottom+2;
        _menu.hidden=false;
        _menu.alpha=0.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        _menu.alpha=1.0;
        [UIView commitAnimations];
    }
    
}

-(void)menu_filter_all{
    _menu.hidden=true;
    _charactertype=@"";
    [self reloadRemoteData];
}


-(void)menu_filter_teacher{
    _menu.hidden=true;
    _charactertype=@"teacher";
    [self reloadRemoteData];
}

-(void)menu_filter_customerservice{
    _menu.hidden=true;
    _charactertype=@"customerservice";
    [self reloadRemoteData];
}
-(void)menu_filter_operation{
    _menu.hidden=true;
    _charactertype=@"operation";
    [self reloadRemoteData];
}

-(void)hiddenAll:(UIView *)v{
    BOOL isMenu=false;
    if((v.tagObject!=nil && [v.tagObject isKindOfClass:[MenuView class]]) || [v isKindOfClass:[MenuView class]]){
        isMenu=true;
    }
    if(!isMenu){
        _menu.hidden=true;
    }
}

@end
