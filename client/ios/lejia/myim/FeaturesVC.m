//
//  FinderVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "FeaturesVC.h"

#define COLUMNS 4
//#define ROWS    4
#define CELL_WIDTH (self.view.width/COLUMNS)
#define CELL_HEIGHT (CELL_WIDTH*1.2)

@interface FeaturesVC (){
    Person* _me;
    Student* _student;
    Teacher* _teacher;
    CustomerService* _customerservice;
    Operation* _operation;
    NSString* _schoolid;
    
    NSMutableDictionary<NSString*,UIView*>* _allFeaturesButton;
    NSMutableArray<UIView*>* _showFeaturesButton;
}

@end

@implementation FeaturesVC

- (void)viewDidLoad {
    [super viewDidLoad];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _me=[Storage getLoginInfo];
    _student=[Storage getStudent];
    _teacher=[Storage getTeacher];
    _customerservice=[Storage getCustomerService];
    _operation=[Storage getOperation];
    _schoolid=@"";
    if(_student!=nil)_schoolid=_student.school.id;
    else if(_teacher!=nil)_schoolid=_teacher.school.id;
    else if(_teacher!=nil)_schoolid=_teacher.school.id;
    else if(_operation!=nil)_schoolid=_operation.school.id;
    
    _allFeaturesButton=[Utility initDictionary:nil];

    [self reloadView];
}
//整理可显示的按钮
-(void)reloadFeaturesButton{
    _showFeaturesButton=[Utility initArray:_showFeaturesButton];
    if([_me isOperation]){
        Operation* character=[Storage getOperation];
        BOOL me_certified=[character isCertified];
        BOOL school_certified=[character.school isCertified];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"提交认证信息"] enable:!(me_certified||school_certified)]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"公众号维护"] enable:me_certified]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"班级维护"] enable:me_certified]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"驾校员工"] enable:me_certified]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"学员报名"] enable:me_certified]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"驾校学员"] enable:me_certified]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"统计图表"] enable:me_certified]];
    }else if([_me isTeacher]){
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"约车"] enable:true]];
    }else if([_me isStudent]){
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"约车"] enable:true]];
        [_showFeaturesButton addObject:
         [self enableCellView:_allFeaturesButton[@"约车记录"] enable:true]];
    }else if([_me isCustomerService]){
        CustomerService* character=[Storage getCustomerService];
        BOOL me_certified=[character isCertified];
        [_showFeaturesButton addObject:
        [self enableCellView:_allFeaturesButton[@"学员报名"] enable:me_certified]];
    }
    
    int r=_showFeaturesButton.count/COLUMNS+(_showFeaturesButton.count%COLUMNS>0?1:0);
//    int c=_showFeaturesButton.count%COLUMNS;
    
    for(int i=1;i<=r;i++){
        UIView* splitView=[[UIView alloc]init];
        [self.view addSubview:splitView];
        splitView.backgroundColor=COLOR_SPLIT;
        splitView.size=CGSizeMake(COLUMNS*CELL_WIDTH, 0.5);
        splitView.origin=CGPointMake(0,i*CELL_HEIGHT);
    }
    for(int i=1;i<COLUMNS;i++){
        UIView* splitView=[[UIView alloc]init];
        [self.view addSubview:splitView];
        splitView.backgroundColor=COLOR_SPLIT;
        splitView.size=CGSizeMake(0.5, CELL_HEIGHT*r);
        splitView.origin=CGPointMake(i*CELL_WIDTH, 0);
    }
    
    for(int i=0;i<_showFeaturesButton.count;i++){
        [self putView:_showFeaturesButton[i] onRow:i/COLUMNS andColumn:i%COLUMNS];
    }
    
}
-(void)reloadView{
    [super reloadView];
    self.view.backgroundColor=[UIColor whiteColor];
    
    NSDictionary* featuresDesc=@{
                                 @"统计图表":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"约车":[UIImage imageNamed:@"Feature_icon_约车"],
                                 @"约车记录":[UIImage imageNamed:@"Feature_icon_约车"],
                                 @"模拟考试":[UIImage imageNamed:@"Feature_icon_模拟考试"],
                                 @"提交认证信息":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"公众号维护":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"班级维护":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"驾校员工":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"驾校学员":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 @"学员报名":[UIImage imageNamed:@"Feature_icon_统计图表"],
                                 };
    
    for(NSString* text in featuresDesc.keyEnumerator.allObjects){
        UIImage* icon=featuresDesc[text];
        _allFeaturesButton[text]=[self genCellViewWithText:text
                                                      icon:icon
                                                    target:self
                                                    action:@selector(buttonClick:)
                                  ];
    }
    

    [self reloadFeaturesButton];

}

-(void)putView:(UIView*)v onRow:(NSUInteger)row andColumn:(NSUInteger)column{
    CGPoint centerPoint=CGPointMake(CELL_WIDTH*column+CELL_WIDTH/2, CELL_HEIGHT*row+CELL_HEIGHT/2);
    if(v.superview==nil || v.superview!=self.view){
        [v removeFromSuperview];
        [self.view addSubview:v];
    }
    v.center=centerPoint;
}

-(UIView*)enableCellView:(UIView*)v enable:(BOOL)enable{
    if([v.tagObject isKindOfClass:[NSDictionary class]] && ((NSDictionary*)v.tagObject)[@"iconView"]!=nil){
        ((UIImageView*)((NSDictionary*)v.tagObject)[@"iconView"]).image=((NSDictionary*)v.tagObject)[enable?@"icon_enable":@"icon_disable"];
        ((NSMutableDictionary*)v.tagObject)[@"enabled"]=enable?@"1":@"0";
        v.userInteractionEnabled=enable;
    }
    return v;
}

-(NSString*)getCellViewText:(UIView*)v{
    NSString* ret=@"";
    if([v.tagObject isKindOfClass:[NSDictionary class]] && ((NSDictionary*)v.tagObject)[@"text"]!=nil){
        ret=((NSDictionary*)v.tagObject)[@"text"];
    }
    return ret;
}

-(UIView*)genCellViewWithText:(NSString*)text icon:(UIImage*)icon target:(id)target action:(SEL)action{
    UIView* ret=[[UIView alloc]init];
    ret.size=CGSizeMake(CELL_WIDTH-2,CELL_HEIGHT-2);
    
    if(icon==nil){
        icon=[UIImage imageNamed:@"空白_icon"];
    }
    UIImageView* iconView=[[UIImageView alloc]init];
    [ret addSubview:iconView];
    iconView.image=icon;
    CGFloat iconWidth=ret.width/2;
    iconView.size=CGSizeMake(iconWidth, iconWidth);

    UILabel* textLable=[[UILabel alloc]init];
    [ret addSubview:textLable];
    textLable.text=text;
    textLable.textColor=COLOR_HEADER_BG;
    textLable.font=FONT_TEXT_SECONDARY;
    [Utility fitLabel:textLable];

    iconView.centerY=iconView.superview.height/2-(textLable.height+3)/2;
    iconView.centerX=iconView.superview.width/2;
    textLable.centerX=iconView.centerX;
    textLable.top=iconView.bottom+3;

    ret.tagObject=[NSMutableDictionary dictionaryWithDictionary:@{
                    @"iconView":iconView,
                    @"icon_enable":icon,
                    @"icon_disable":icon.greyImage,
                    @"enabled":@"1",
                    @"text":text,
                    }];
    
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    return ret;
}

-(void)buttonClick:(UIGestureRecognizer*)sender{
    NSString* text=[self getCellViewText:sender.view];
    if([@"提交认证信息" isEqualToString:text]){
        [self gotoPageWithClass:[OperationSubmitCertificateVC class]];
    }else if([@"公众号维护" isEqualToString:text]){
        [self gotoPageWithClass:[OperationEditSchoolInfoVC class] parameters:@{
                                                                               PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                               }];
    }else if([@"班级维护" isEqualToString:text]){
        [self gotoPageWithClass:[OperationEditClasses class]parameters:@{
                                                                      PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                      }];
    }else if([@"驾校员工" isEqualToString:text]){
        [self gotoPageWithClass:[SchoolStaffListVC class]parameters:@{
                                                                      PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                      PAGE_PARAM_CHARACTERTYPE:@"",
                                                                      PAGE_PARAM_TITLE:[NSString stringWithFormat:@"%@-%@",_me.school_name,@"员工"],
                                                                      PAGE_PARAM_EDIT:@"",
                                                                      
                                                                      }];
    }else if([@"学员报名" isEqualToString:text]){
        [self gotoPageWithClass:[OperationSignupListVC class]parameters:@{
                                                                      PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                      }];
    }else if([@"驾校学员" isEqualToString:text]){
        [self gotoPageWithClass:[OperationStudentSearchVC class]parameters:@{
                                                                          PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                          }];
    }else if([@"约车" isEqualToString:text]){
        if([_me isTeacher]){
            [self gotoPageWithClass:[TATeacherMainVC class]parameters:@{
                                                                                     PAGE_PARAM_TEACHER_ID:_teacher.id==nil?@"":_teacher.id
                                                                                     }];
        }else if([_me isStudent]){
            [self gotoPageWithClass:[TAStudentTeacherListVC class]parameters:@{
                                                                                     PAGE_PARAM_STUDENT_ID:_student.id
                                                                                               }];
        }
    }else if([@"约车记录" isEqualToString:text]){
        [self gotoPageWithClass:[TAStudentRecordListVC class]parameters:@{
                                                                                     PAGE_PARAM_STUDENT_ID:_student.id
                                                                                     }];
    }
}
@end
