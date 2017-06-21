//
//  OperationSignupInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/11/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationSignupInfoVC.h"

@interface OperationSignupInfoVC (){
    UIScrollView* _scrollView;
    SchoolSignup* _signup;
    SchoolClass* _schoolclass;

    UIView* _infoView;
    UIView* _nameView;
    UIView* _phoneView;
    UIView* _genderView;
    UIView* _ageView;
    UIView* _classView;
    UIView* _addressView;
    UIView* _remarkView;

    //已报名开关
    UIView* _signupSwichView;
    UISwitch* _signupSwich;
    //放弃开关
    UIView* _abandonSwichView;
    UISwitch* _abandonSwich;
    
    
}

@end

@implementation OperationSignupInfoVC
-(BOOL)isEmptyString:(NSString*)s{
    return s==nil||[Utility trim:s].length==0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshData];
}

-(void)refreshData{

    [UIUtility setFeatureItem:_nameView text:_signup.name];
    [UIUtility setFeatureItem:_phoneView text:_signup.phone];
    [UIUtility setFeatureItem:_genderView text:[_signup isMale]?@"男":@"女"];
    NSString* className=[NSString stringWithFormat:@"课程名称 : (%@)%@\n班级价格 : %@元\n训练时间 : %@\n训练车型 : %@",
                         _schoolclass.licensetype,
                         _schoolclass.name,
                         _schoolclass.fee,
                         _schoolclass.trainingtime,
                         _schoolclass.cartype
                         ];
    [UIUtility setFeatureItem:_classView text:className];
    [UIUtility setFeatureItem:_ageView text:_signup.age];
    [UIUtility setFeatureItem:_addressView text:_signup.address];
    [UIUtility setFeatureItem:_remarkView text:_signup.remark];
    if([_signup isNew]){
        [_signupSwich setOn:false];
        [_abandonSwich setOn:false];
    }else if([_signup isSignup]){
        [_signupSwich setOn:true];
        [_abandonSwich setOn:false];
    }else if([_signup isAbandon]){
        [_signupSwich setOn:false];
        [_abandonSwich setOn:true];
    }
    
    _nameView.top=_infoView.bottom;
    _phoneView.top=_nameView.bottom;
    _genderView.top=_phoneView.bottom;
    _classView.top=_genderView.bottom;
    _ageView.top=_classView.bottom;
    _addressView.top=_ageView.bottom;
    _remarkView.top=_addressView.bottom;
    _signupSwichView.top=_remarkView.bottom+12;
    _abandonSwichView.top=_signupSwichView.bottom;
    
    UILabel* _phoneLabel=_phoneView.tagObject[@"rightObj"];
    _phoneLabel.textColor=[UIColor blueColor];
    UIImageView* phoneIcon=[[UIImageView alloc]init];
    [_phoneView addSubview:phoneIcon];
    phoneIcon.image=[[UIImage imageNamed:@"icon_拨打电话"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    phoneIcon.tintColor=_phoneLabel.textColor;
    CGFloat phoneIconWidth=phoneIcon.superview.height*0.4;
    phoneIcon.size=(CGSize){phoneIconWidth,phoneIconWidth};
    phoneIcon.right=_phoneLabel.left-5;
    phoneIcon.centerY=phoneIcon.superview.height/2;
    
    _scrollView.contentSize=CGSizeMake(_scrollView.width, _abandonSwich.bottom+12);

}

-(void)reloadView{
    [super reloadView];
    NSString* title=[NSString stringWithFormat:@"报名信息"];
    HeaderView* headView=[[HeaderView alloc]initWithTitle:title
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(doBack)]
                                              rightButton:nil
                          ];
    [self.view addSubview:headView];
    
    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=CGPointMake(0, headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    
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
                                            target:nil
                                            action:nil
                                         showSplit:false
               ];
    
    _phoneView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                top:_nameView.bottom
                                              title:@"联系电话"
                                             height:FEATURE_NORMAL_HEIGHT
                                           rightObj:[UIUtility genFeatureItemRightLabel]
                                             target:self
                                             action:@selector(dial:)
                                          showSplit:true
                ];
    
    _genderView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_phoneView.bottom
                                               title:@"性别"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:nil
                                              action:nil
                                           showSplit:true
                 ];
    
    _ageView=[UIUtility genFeatureItemInSuperView:_scrollView
                                              top:_genderView.bottom
                                            title:@"年龄"
                                           height:FEATURE_NORMAL_HEIGHT
                                         rightObj:[UIUtility genFeatureItemRightLabel]
                                           target:nil
                                           action:nil
                                        showSplit:true
              ];
    
    _classView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                top:_ageView.bottom
                                              title:@"选择班级"
                                             height:FEATURE_NORMAL_HEIGHT
                                           rightObj:[UIUtility genFeatureItemRightLabel]
                                             target:nil
                                             action:nil
                                          showSplit:true
                ];
    
    _addressView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                  top:_classView.bottom
                                                title:@"地址"
                                               height:FEATURE_NORMAL_HEIGHT
                                             rightObj:[UIUtility genFeatureItemRightLabel]
                                               target:nil
                                               action:nil
                                            showSplit:true
                  ];
    
    _remarkView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                 top:_addressView.bottom
                                               title:@"备注"
                                              height:FEATURE_NORMAL_HEIGHT
                                            rightObj:[UIUtility genFeatureItemRightLabel]
                                              target:nil
                                              action:nil
                                           showSplit:true
                 ];
    
    
    _signupSwich=[[UISwitch alloc]init];
    [_signupSwich addTarget:self action:@selector(setStatusSignup:) forControlEvents:UIControlEventValueChanged];
    _signupSwichView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                  top:0
                                                title:@"学员已报名"
                                               height:FEATURE_NORMAL_HEIGHT
                                             rightObj:_signupSwich
                                               target:nil
                                               action:nil
                                            showSplit:false
                  ];
    _abandonSwich=[[UISwitch alloc]init];
    [_abandonSwich addTarget:self action:@selector(setStatusAbandon:) forControlEvents:UIControlEventValueChanged];
    _abandonSwichView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                      top:0
                                                    title:@"学员已放弃"
                                                   height:FEATURE_NORMAL_HEIGHT
                                                 rightObj:_abandonSwich
                                                   target:nil
                                                   action:nil
                                                showSplit:true
                      ];
    
}
-(void)setStatusSignup:(UISwitch*)sender{
    [_abandonSwich setOn:false];
    [self updateSignupStatus];
}
-(void)setStatusAbandon:(UISwitch*)sender{
    [_signupSwich setOn:false];
    [self updateSignupStatus];
}
-(void)dial:(UIGestureRecognizer*)sender{
    NSString* phone=_signup.phone;
    if(![Utility isEmptyString:phone]){
        NSString* tel=[NSString stringWithFormat:@"telprompt://%@",phone];
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:tel]];
    }
}

-(void)updateSignupStatus{
    NSString* status=@"new";
    if([_signupSwich isOn]){
        status=@"signup";
    }else if([_abandonSwich isOn]){
        status=@"abandon";
    }
    
    __block LoadingView*  lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote updateSchoolSignupStatus:_signup.id status:status callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _signup.status=status;
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [self refreshData];
        [lv removeFromSuperview];
    }];
}
-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_SIGNUP isEqualToString:key]){
        _signup=value;
        _schoolclass=_signup.schoolclass;
    }
}

-(void)doBack{
    [self gotoBackWithParamaters:@{
                                   PAGE_PARAM_SCHOOL_SIGNUP:_signup,
                                   }];
}
@end
