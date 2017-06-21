//
//  OperationEditStaffVC.m
//  myim
//
//  Created by Sean Shi on 15/10/18.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditStaffVC.h"
#import "HeaderView.h"
#define SPACE 12

@interface OperationEditStaffVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    NSString* _personid;
    Person* _person;
    Teacher* _teacher;
    CustomerService* _customerService;
    Operation* _operation;
    
    UIImagePickerController* _picker;
    //标题栏
    HeaderView* _header;
    
    //认证
    UIView* _certifyView;

    //头像
    UIView* _headerView;
    //真实姓名
    UIView* _nameView;
    //身份证号
    UIView* _idcardView;
    //性别
    UIView* _genderView;
    //地区
    UIView* _areaView;
    
    //身份
    UISwitch* _certitySwitch;
    UIView* _characterView;
    
    
}

@end

@implementation OperationEditStaffVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [self reloadRemoteData];
//    [self refreshData];
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote getPersonWithId:_personid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _person=callback_data.data;
            [Remote availableCharacter:_personid callback:^(StorageCallbackData *callback_data) {
                if(callback_data.code==0){
                    NSString* characterType=callback_data.data[@"character_type"];
                    _teacher=nil;
                    _customerService=nil;
                    _operation=nil;
                    if([@"teacher" isEqualToString:characterType]){
                        _teacher=callback_data.data[@"obj"];
                    }else if([@"customerservice" isEqualToString:characterType]){
                        _customerService=callback_data.data[@"obj"];
                    }else if([@"operation" isEqualToString:characterType]){
                        _operation=callback_data.data[@"obj"];
                    }
                    [self refreshData];
                }else{
                    [Utility showError:callback_data.message type:ErrorType_Network];
                }
                [lv removeFromSuperview];
            }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
            [lv removeFromSuperview];
        }
    }];
}
-(void)refreshData{
    
    [UIUtility setFeatureItem:_headerView imageUrl:_person.imageurl defaultImage:[UIImage imageNamed:@"缺省头像"]];
    [UIUtility setFeatureItem:_nameView text:_person.name];
    [UIUtility setFeatureItem:_idcardView text:[Utility maskIDCard:_person.idcard]];
    [UIUtility setFeatureItem:_genderView text:([_person isMale]?@"男":@"女")];
    [UIUtility setFeatureItem:_areaView text:_person.area.namepath];
    
    NSString* characterText=@"点击选择身份";
    if(_teacher!=nil){
        characterText=[NSString stringWithFormat:@"教练   %@",_teacher.school.name];
    }else if(_customerService!=nil){
        characterText=[NSString stringWithFormat:@"客服   %@",_customerService.school.name];
    }else if(_operation!=nil){
        characterText=[NSString stringWithFormat:@"运营   %@",_operation.school.name];
    }
    [UIUtility setFeatureItem:_characterView text:characterText];
    [_certitySwitch setOn:[_person isCertified]];
    
    
    _headerView.top=SPACE;
    _nameView.top=_headerView.bottom;
    _idcardView.top=_nameView.bottom;
    _genderView.top=_idcardView.bottom;
    _areaView.top=_genderView.bottom;
    _characterView.top=_areaView.bottom;
    _certifyView.top=_characterView.bottom+SPACE;
}

-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"员工信息"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //滚动部分
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.origin=CGPointMake(0, _header.bottom);
    scrollView.size=CGSizeMake(scrollView.superview.width, scrollView.superview.height-scrollView.top);
    scrollView.bounces=false;
    
    //初始化头像栏
    UIImageView* headImageView=[[UIImageView alloc] init];
    headImageView.contentMode=UIViewContentModeScaleAspectFit;
    headImageView.userInteractionEnabled=true;
    [headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHeaderImage:)]];
    headImageView.size=CGSizeMake(57, 57);
    _headerView=[UIUtility genFeatureItemInSuperView:scrollView
                                                 top:0
                                               title:@"头像"
                                              height:70
                                            rightObj:headImageView
                                              target:self
                                              action:@selector(doNothing)
                                           showSplit:false
                 ];
    
    
    //真实姓名栏
    _nameView=[UIUtility genFeatureItemInSuperView:scrollView
                                               top:0
                                             title:@"真实姓名"
                                            height:FEATURE_NORMAL_HEIGHT
                                          rightObj:[UIUtility genFeatureItemRightLabel]
                                            target:self
                                            action:@selector(doNothing)
                                         showSplit:true
               ];
    
    //身份证号码
    _idcardView=[UIUtility genFeatureItemInSuperView:scrollView
                                                 top:0
                                               title:@"身份证号码"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(doNothing)
                                           showSplit:true
                 ];
    
    //性别
    _genderView=[UIUtility genFeatureItemInSuperView:scrollView
                                                 top:0
                                               title:@"性别"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:self
                                              action:@selector(doNothing)
                                           showSplit:true
                 ];
    //地区
    _areaView=[UIUtility genFeatureItemInSuperView:scrollView
                                               top:0
                                             title:@"地区"
                                            height:FEATURE_NORMAL_HEIGHT
                                          rightObj:[UIUtility genFeatureItemRightLabel]
                                            target:self
                                            action:@selector(doNothing)
                                         showSplit:true
               ];
    
    
    //身份
    _characterView=[UIUtility genFeatureItemInSuperView:scrollView
                                                    top:0
                                                  title:@"身份"
                                                 height:FEATURE_NORMAL_HEIGHT
                                               rightObj:[UIUtility genFeatureItemRightLabel]
                                                 target:self
                                                 action:@selector(doNothing)
                                              showSplit:true
                    ];

    //认证
    _certitySwitch=[[UISwitch alloc]init];
    if(![_personid isEqualToString:[Storage getLoginInfo].id]){//不能修改自己的认证状态
        [_certitySwitch addTarget:self action:@selector(switchCertify:) forControlEvents:UIControlEventValueChanged];
    }else{
        _certitySwitch.enabled=false;
    }
    _certifyView=[UIUtility genFeatureItemInSuperView:scrollView
                                                    top:0
                                                  title:@"是否认证"
                                                 height:FEATURE_NORMAL_HEIGHT
                                               rightObj:_certitySwitch
                                                 target:self
                                                 action:@selector(doNothing)
                                              showSplit:false
                    ];

    //设置滚动区域
    scrollView.contentSize=CGSizeMake(scrollView.width, _certifyView.bottom+SPACE);
}

//显示头像大图
-(void)showHeaderImage:(UIGestureRecognizer*)sender{
    if([sender.view isKindOfClass:[UIImageView class]]){
        UIImageView* view=(UIImageView*)sender.view;
        [self gotoPageWithClass:[ShowImageVC class] parameters:@{
                                                                 PAGE_PARAM_IMAGE:view.image,
                                                                 PAGE_PARAM_URL:_person.originimageurl,
                                                                 }];
    }
}

-(void)doNothing{
}

-(void)switchCertify:(UISwitch*)sender{
    BaseObject* character=_teacher!=nil?_teacher:(_customerService!=nil?_customerService:(_operation!=nil?_operation:nil));
    if(character!=nil){
        [Remote certify:character certify:[sender isOn]  callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code!=0){
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [self reloadRemoteData];
        }];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_PERSONID isEqualToString:key]){
        _personid=value;
    }
}
@end
