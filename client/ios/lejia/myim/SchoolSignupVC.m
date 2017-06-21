//
//  SchoolSignupVC.m
//  myim
//
//  Created by Sean Shi on 15/11/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SchoolSignupVC.h"

@interface SchoolSignupVC (){
    UIScrollView* _scrollView;
    
    School* _school;
    SchoolClass* _selectedClass;
    NSMutableArray<Dict*>* _dictClasses;
    
    UIView* _infoView;
    UIView* _nameView;
    UIView* _phoneView;
    UIView* _genderView;
    UIView* _ageView;
    UIView* _classView;
    UIView* _addressView;
    UIView* _remarkView;
    
    NSString* _name;
    NSString* _phone;
    NSString* _gender;
    NSString* _age;
    NSString* _address;
    NSString* _remark;
    
}

@end

@implementation SchoolSignupVC
-(BOOL)isEmptyString:(NSString*)s{
    return s==nil||[Utility trim:s].length==0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _name=[Storage getLoginInfo].name;
    _phone=[Storage getLoginInfo].phone;
    _dictClasses=[Utility initArray:nil];
    for(int i=0;i<_school.classes.count;i++){
        NSString* className=[NSString stringWithFormat:@"课程名称 : (%@)%@\n班级价格 : %@元\n训练时间 : %@\n训练车型 : %@",
                             _school.classes[i].licensetype,
                             _school.classes[i].name,
                             _school.classes[i].fee,
                             _school.classes[i].trainingtime,
                             _school.classes[i].cartype
                             ];
        Dict* dict=[Dict initWithDictionary:@{
                                              @"name":@"schoolclass",
                                              @"desc":className,
                                              @"value":_school.classes[i].id,
                                              @"order":[NSString stringWithFormat:@"%d",i],
                                              }];
        [_dictClasses addObject:dict];
    }
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIUtility setFeatureItem:_nameView text:[self isEmptyString:_name]?@"点击选择":_name];
    [UIUtility setFeatureItem:_phoneView text:[self isEmptyString:_phone]?@"点击选择":_phone];
    [UIUtility setFeatureItem:_genderView text:[self isEmptyString:_gender]?@"点击选择":[@"1" isEqualToString:_gender]?@"男":@"女"];
    NSString* className=_selectedClass==nil?@"点击选择":[NSString stringWithFormat:@"课程名称 : (%@)%@\n班级价格 : %@元\n训练时间 : %@\n训练车型 : %@",
                                                 _selectedClass.licensetype,
                                                 _selectedClass.name,
                                                 _selectedClass.fee,
                                                 _selectedClass.trainingtime,
                                                 _selectedClass.cartype
                                                 ];
    [UIUtility setFeatureItem:_classView text:className];
    [UIUtility setFeatureItem:_ageView text:[self isEmptyString:_age]?@"点击选择":_age];
    [UIUtility setFeatureItem:_addressView text:[self isEmptyString:_address]?@"点击选择":_address];
    [UIUtility setFeatureItem:_remarkView text:[self isEmptyString:_remark]?@"点击选择":_remark];
    
    _nameView.top=_infoView.bottom;
    _phoneView.top=_nameView.bottom;
    _genderView.top=_phoneView.bottom;
    _classView.top=_genderView.bottom;
    _ageView.top=_classView.bottom;
    _addressView.top=_ageView.bottom;
    _remarkView.top=_addressView.bottom;

    _scrollView.contentSize=CGSizeMake(_scrollView.width, _remarkView.bottom+12);
}

-(void)reloadView{
    [super reloadView];
    NSString* title=[NSString stringWithFormat:@"%@-报名",_school.name];
    HeaderView* headView=[[HeaderView alloc]initWithTitle:title
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                              rightButton:[HeaderView genItemWithText:@"提交" target:self action:@selector(submitSignup)]
                          ];
    [self.view addSubview:headView];
    
    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=CGPointMake(0, headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    
    //报名须知
    _infoView=[[UIView alloc]init];
    [_scrollView addSubview:_infoView];
    _infoView.width=100;
    _infoView.height=40;
    _infoView.right=_infoView.superview.width;
    _infoView.top=0;
    _infoView.userInteractionEnabled=true;
    [_infoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfo)]];

    UILabel* infoLabel=[[UILabel alloc]init];
    infoLabel.backgroundColor=[UIColor clearColor];
    infoLabel.textColor=COLOR_TEXT_LINK;
    infoLabel.text=@"报名须知";
    infoLabel.font=FONT_TEXT_SECONDARY;
    [_infoView addSubview:infoLabel];
    [Utility fitLabel:infoLabel];
    infoLabel.right=infoLabel.superview.width-15;
    infoLabel.bottom=infoLabel.superview.height-5;

    _nameView=[UIUtility genFeatureItemInSuperView:_scrollView
                                     top:_infoView.bottom
                                   title:@"真实姓名"
                                  height:FEATURE_NORMAL_HEIGHT
                                rightObj:[UIUtility genFeatureItemRightLabel]
                                  target:self
                                  action:@selector(changeName)
                               showSplit:false
     ];

    _phoneView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                      top:_nameView.bottom
                                                    title:@"联系电话"
                                                   height:FEATURE_NORMAL_HEIGHT
                                                 rightObj:[UIUtility genFeatureItemRightLabel]
                                                   target:self
                                                   action:@selector(changePhone)
                                                showSplit:true
                      ];
    
    _genderView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_phoneView.bottom
                                               title:@"性别"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(changeGender)
                                           showSplit:true
                 ];

    _ageView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_genderView.bottom
                                               title:@"年龄"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(changeAge)
                                           showSplit:true
                 ];
    
    _classView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                top:_ageView.bottom
                                              title:@"选择班级"
                                             height:FEATURE_NORMAL_HEIGHT
                                           rightObj:[UIUtility genFeatureItemRightLabel]
                                             target:self
                                             action:@selector(changeClass)
                                          showSplit:true
                ];

    _addressView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_classView.bottom
                                               title:@"地址"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(changeAddress)
                                           showSplit:true
                 ];
    
    _remarkView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_addressView.bottom
                                               title:@"备注"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(changeRemark)
                                           showSplit:true
                 ];


}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL isEqualToString:key]){
        _school=value;
    }else if([PAGE_PARAM_SCHOOLCLASS isEqualToString:key]){
        _selectedClass=value;
    }else if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([value isKindOfClass:[NSDictionary class]]){
            if([@"name" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _name=value[PAGE_PARAM_RETURN_VALUE];
            }else if([@"phone" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _phone=value[PAGE_PARAM_RETURN_VALUE];
            }else if([@"gender" isEqualToString:value[PAGE_PARAM_TYPE]]){
                NSArray<Dict*>* returnValue=value[PAGE_PARAM_RETURN_VALUE];
                _gender=(returnValue==nil?nil:(returnValue.count>0?returnValue[0].value:nil));
            }else if([@"age" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _age=value[PAGE_PARAM_RETURN_VALUE];
            }else if([@"address" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _address=value[PAGE_PARAM_RETURN_VALUE];
            }else if([@"schoolclass" isEqualToString:value[PAGE_PARAM_TYPE]]){
                NSArray<Dict*>* returnValue=value[PAGE_PARAM_RETURN_VALUE];
                NSString* classid=(returnValue==nil?nil:(returnValue.count>0?returnValue[0].value:nil));
                for(int i=0;i<_school.classes.count;i++){
                    if([_school.classes[i].id isEqualToString:classid]){
                        _selectedClass=_school.classes[i];
                        break;
                    }
                }
            }else if([@"remark" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _remark=value[PAGE_PARAM_RETURN_VALUE];
            }
        }
    }
}

-(void)changeName{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"真实姓名",
                                                               PAGE_PARAM_EXPLAIN:@"",
                                                               PAGE_PARAM_ORIGIN_VALUE:_name==nil?@"":_name,
                                                               PAGE_PARAM_TYPE:@"name",
                                                               }];
}
-(void)changePhone{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"联系电话",
                                                               PAGE_PARAM_EXPLAIN:@"",
                                                               PAGE_PARAM_ORIGIN_VALUE:_phone==nil?@"":_phone,
                                                               PAGE_PARAM_TYPE:@"phone",
                                                               PAGE_PARAM_INPUTTYPE:CHANGEVALUE_INPUTTYPE_PhonePad,
                                                               }];
}

-(void)changeGender{
    Dict* male=[Dict initWithDictionary:@{
                                          @"name":@"gender",
                                          @"desc":@"男",
                                          @"value":@"1",
                                          @"order":@"1",
                                          }];
    Dict* female=[Dict initWithDictionary:@{
                                          @"name":@"gender",
                                          @"desc":@"女",
                                          @"value":@"2",
                                          @"order":@"2",
                                          }];
    [self gotoPageWithClass:[SelectDictDataVC class] parameters:@{
                                                                  PAGE_PARAM_TITLE:@"性别",
                                                                  PAGE_PARAM_DICTNAME:@"gender",
                                                                  PAGE_PARAM_TYPE:@"gender",
                                                                  PAGE_PARAM_ORIGIN_VALUE:@[_gender==nil?@"":_gender],
//                                                                  PAGE_PARAM_MUTILSELECT:@"1",
                                                                  PAGE_PARAM_DATA:@[male,female],
                                                                  }];
}

-(void)changeAge{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"年龄",
                                                               PAGE_PARAM_EXPLAIN:@"",
                                                               PAGE_PARAM_ORIGIN_VALUE:_age==nil?@"":_age,
                                                               PAGE_PARAM_TYPE:@"age",
                                                               PAGE_PARAM_INPUTTYPE:CHANGEVALUE_INPUTTYPE_NumberPad,
                                                               }];
}

-(void)changeClass{
    [self gotoPageWithClass:[SelectDictDataVC class] parameters:@{
                                                                  PAGE_PARAM_TITLE:@"驾校班级",
                                                                  PAGE_PARAM_DICTNAME:@"schoolclass",
                                                                  PAGE_PARAM_TYPE:@"schoolclass",
                                                                  PAGE_PARAM_ORIGIN_VALUE:@[_selectedClass==nil?@"":_selectedClass.id],
                                                                  //                                                                  PAGE_PARAM_MUTILSELECT:@"1",
                                                                  PAGE_PARAM_DATA:_dictClasses,
                                                                  }];

}

-(void)changeAddress{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"地址",
                                                               PAGE_PARAM_EXPLAIN:@"",
                                                               PAGE_PARAM_ORIGIN_VALUE:_address==nil?@"":_address,
                                                               PAGE_PARAM_TYPE:@"address",
                                                               }];
}

-(void)changeRemark{
    [self gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                               PAGE_PARAM_TITLE:@"备注",
                                                               PAGE_PARAM_EXPLAIN:@"",
                                                               PAGE_PARAM_ORIGIN_VALUE:_remark==nil?@"":_remark,
                                                               PAGE_PARAM_TYPE:@"remark",
                                                               }];
}

-(void)submitSignup{
    BOOL checked=true;
    if([Storage getLoginInfo]==nil){
        [Utility showError:@"需要登录" type:ErrorType_Network];
        checked=false;
    }
    if(_school==nil){
        [Utility showError:@"请选择驾校" type:ErrorType_Network];
        checked=false;
    }
    if(_selectedClass==nil){
        [Utility showError:@"请选择班级" type:ErrorType_Network];
        checked=false;
    }
    if([self isEmptyString:_name]){
        [Utility showError:@"请输入真实姓名" type:ErrorType_Network];
        checked=false;
    }
    if(![Utility checkPhoneFormat:_phone]){
        [Utility showError:@"请输入正确地手机号" type:ErrorType_Network];
        checked=false;
    }
    if([self isEmptyString:_gender]){
        [Utility showError:@"请选择性别" type:ErrorType_Network];
        checked=false;
    }
    if([self isEmptyString:_age]){
        [Utility showError:@"请输入年龄" type:ErrorType_Network];
        checked=false;
    }
    if([self isEmptyString:_address]){
        [Utility showError:@"请输入地址" type:ErrorType_Network];
        checked=false;
    }
    if(!checked){
        return;
    }
    
    
    NSString* personid=[Storage getLoginInfo].id;
    NSString* schoolid=_school.id;
    NSString* classid=_selectedClass.id;
    NSString* name=_name;
    NSString* phone=_phone;
    NSString* gender=_gender;
    NSString* age=_age;
    NSString* address=_address;
    NSString* remark=_remark==nil?@"":_remark;
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote schoolSignup:personid school:schoolid classid:classid name:name phone:phone gender:gender age:age address:address remark:remark callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Utility showMessage:@"报名成功"];
            [self gotoBack];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

-(void)showInfo{
    [self gotoPageWithClass:[SchoolSignupInfoVC class]];
}
@end
