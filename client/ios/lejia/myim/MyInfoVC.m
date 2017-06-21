//
//  MyInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/10/18.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "MyInfoVC.h"
#import "HeaderView.h"
#define MYINFO_HEADER_HEIGHT 70
#define MYINFO_NORMAL_HEIGHT 43
#define SPACE 12

@interface MyInfoVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    Person* _me;
    Teacher* _teacher;
    Student* _student;
    CustomerService* _customerService;
    Operation* _operation;
    
    UIImagePickerController* _picker;
    //标题栏
    HeaderView* _header;

    //头像
    UIView* _headerView;
    //昵称
    UIView* _nicknameView;
    
    //乐友号
    UIView* _usernameView;
    //二维码名片
    UIView* _qrcodeView;
    //真实姓名
    UIView* _nameView;
    //身份证号
    UIView* _idcardView;
    //性别
    UIView* _genderView;
    //地区
    UIView* _areaView;
    //个人信息保密声明
    UILabel* _infoExplain;
    
    //身份
    UIView* _characterView;
    

}

@end

@implementation MyInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _me=[Storage getLoginInfo];
    _student=[Storage getStudent];
    _teacher=[Storage getTeacher];
    _customerService=[Storage getCustomerService];
    _operation=[Storage getOperation];
    [self reloadView];

}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshData];
}
-(void)refreshData{
    _me=[Storage getLoginInfo];
    [UIUtility setFeatureItem:_headerView image:[_me.social getHeaderImage]];
    NSString* displayNickname=_me.socialname;
    if([_me isStaff]){
        displayNickname=[NSString stringWithFormat:@"%@\n(驾校员工只显示真实姓名)",_me.socialname];
    }
    [UIUtility setFeatureItem:_nicknameView text:displayNickname];
    [UIUtility setFeatureItem:_usernameView text:_me.username];
    [UIUtility setFeatureItem:_nameView text:_me.name];
    [UIUtility setFeatureItem:_idcardView text:[Utility maskIDCard:_me.idcard]];
    [UIUtility setFeatureItem:_genderView text:([_me isMale]?@"男":@"女")];
    [UIUtility setFeatureItem:_areaView text:_me.area.namepath];
    
    NSString* characterText=@"点击选择身份";
    if(_student!=nil){
        characterText=[NSString stringWithFormat:@"学员   %@",_student.school.name];
    }else if(_teacher!=nil){
        characterText=[NSString stringWithFormat:@"教练   %@",_teacher.school.name];
    }else if(_customerService!=nil){
        characterText=[NSString stringWithFormat:@"客服   %@",_customerService.school.name];
    }else if(_operation!=nil){
        characterText=[NSString stringWithFormat:@"运营   %@",_operation.school.name];
    }
    [UIUtility setFeatureItem:_characterView text:characterText];


    _headerView.top=SPACE;
    _nicknameView.top=_headerView.bottom;
    _usernameView.top=_nicknameView.bottom;
    _qrcodeView.top=_usernameView.bottom;

    _nameView.top=_qrcodeView.bottom+SPACE;
    _idcardView.top=_nameView.bottom;
    _genderView.top=_idcardView.bottom;
    _areaView.top=_genderView.bottom;
    _infoExplain.top=_areaView.bottom;

    _characterView.top=_infoExplain.bottom+SPACE;

}

-(void)reloadView{
    [super reloadView];

    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"个人信息"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //滚动部分
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [scrollView fillSuperview:self.view underOf:_header];
    scrollView.bounces=false;
    
    //初始化头像栏
    UIImageView* headImageView=[[UIImageView alloc] init];
    headImageView.contentMode=UIViewContentModeScaleAspectFit;
    headImageView.userInteractionEnabled=true;
    [headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showHeaderImage:)]];
    headImageView.size=CGSizeMake(57, 57);
    _headerView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:SPACE
                                   title:@"头像"
                                  height:MYINFO_HEADER_HEIGHT
                                rightObj:headImageView
                                  target:self
                                  action:@selector(selectHeaderImage)
                               showSplit:false
                 ];
    
    //昵称栏
    _nicknameView=[UIUtility genFeatureItemInSuperView:scrollView
                                       top:_headerView.bottom
                                     title:@"昵称"
                                    height:MYINFO_NORMAL_HEIGHT
                                              rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                    target:self
                                    action:@selector(changeNickname)
                                 showSplit:true
                 ];
    
    //乐友号栏
    _usernameView=[UIUtility genFeatureItemInSuperView:scrollView
                                       top:_nicknameView.bottom
                                     title:@"乐友号"
                                    height:MYINFO_NORMAL_HEIGHT
                                  rightObj:[UIUtility genFeatureItemRightLabel]
                                    target:self
                                    action:@selector(changeUsername)
                                 showSplit:true
                   ];
    
    //二维码名片
    UIImageView* qrcodeImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_icon_二维码"]];
    qrcodeImage.size=CGSizeMake(17, 17);
    _qrcodeView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:_usernameView.bottom
                                   title:@"二维码名片"
                                  height:MYINFO_NORMAL_HEIGHT
                                rightObj:qrcodeImage
                                  target:self
                                  action:@selector(showQRCode)
                               showSplit:true
                 ];


    //真实姓名栏
    _nameView=[UIUtility genFeatureItemInSuperView:scrollView
                                   top:_qrcodeView.bottom+SPACE
                                 title:@"真实姓名"
                                height:MYINFO_NORMAL_HEIGHT
                              rightObj:[UIUtility genFeatureItemRightLabel]
                                target:self
                                action:@selector(changeName)
                             showSplit:false
               ];

    //身份证号码
    _idcardView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:_nameView.bottom
                                   title:@"身份证号码"
                                  height:MYINFO_NORMAL_HEIGHT
                                rightObj:[UIUtility genFeatureItemRightLabel]
                                  target:self
                                  action:@selector(changeIDCard)
                               showSplit:true
                 ];

    //性别
    _genderView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:_idcardView.bottom
                                   title:@"性别"
                                  height:MYINFO_NORMAL_HEIGHT
                                rightObj:[UIUtility genFeatureItemRightLabel]
                                  target:self
                                  action:@selector(changeGender)
                               showSplit:true
                 ];
    //地区
    _areaView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:_genderView.bottom
                                   title:@"地区"
                                  height:MYINFO_NORMAL_HEIGHT
                                rightObj:[UIUtility genFeatureItemRightLabel]
                                  target:self
                                  action:@selector(selectArea)
                               showSplit:true
                 ];
    //个人信息保密声明
    _infoExplain=[Utility genLabelWithText:@"个人信息仅自己可见，我们不会泄露您的个人资料。"
                                           bgcolor:nil
                                         textcolor:UIColorFromRGB(0x454545)
                                              font:FONT_TEXT_SECONDARY
                          ];
    [scrollView addSubview:_infoExplain];
    _infoExplain.top=_areaView.bottom+3;
    _infoExplain.left=_areaView.left+20;
    
    
    //身份
    _characterView=[UIUtility genFeatureItemInSuperView:scrollView
                                                    top:_infoExplain.bottom+SPACE
                                                  title:@"身份"
                                                 height:MYINFO_NORMAL_HEIGHT
                                               rightObj:[UIUtility genFeatureItemRightLabel]
                                                 target:self
                                                 action:@selector(selectChatacter)
                                              showSplit:false
                    ];
    
    //设置滚动区域
    scrollView.contentSize=CGSizeMake(scrollView.width, _characterView.bottom+SPACE);
}

//显示头像大图
-(void)showHeaderImage:(UIGestureRecognizer*)sender{
    if([sender.view isKindOfClass:[UIImageView class]]){
        UIImageView* view=(UIImageView*)sender.view;
        [self gotoPageWithClass:[ShowImageVC class] parameters:@{
                                                                 PAGE_PARAM_IMAGE:view.image,
                                                                 PAGE_PARAM_URL:_me.originimageurl,
                                                                 }];
    }
}

//从图片库中选择投降
-(void)selectHeaderImage{
    [UIUtility showImagePickerWithSourceType:99 fromViewController:self returnKey:@"headImage" size:CGSizeMake(300,300)];
    
//    if(_picker==nil){
//        _picker=[[UIImagePickerController alloc]init];
//        _picker.delegate=self;
//        _picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//        _picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
//        _picker.allowsEditing=true;
//    }
//    [self presentViewController:_picker animated:true completion:nil];
    
}

//图片库选择器的回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo{
    [picker dismissViewControllerAnimated:true completion:nil];
    if(image!=nil){
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote updateHeadImageWithImage:image callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [_me.social setHeaderImage:image];
                [UIUtility setFeatureItem:_headerView image:[_me.social getHeaderImage]];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
    }
}

-(void)showQRCode{
    [self gotoPageWithClass:[QRCodeVC class]];
}
-(void)changeNickname{
    if(![_me isStaff]){
        [self gotoPageWithClass:[ChangeNicknameVC class]];
    }
}

-(void)changeName{
    [self gotoPageWithClass:[ChangeNameVC class]];
}
-(void)changeIDCard{
    [self gotoPageWithClass:[ChangeIDCardVC class]];
}
-(void)changeGender{
    [self gotoPageWithClass:[ChangeGenderVC class]];
}
-(void)changeUsername{
    if(_me.username==nil || _me.username.length<=0){
        [self gotoPageWithClass:[ChangeUsernameVC class]];
    }
}
-(void)selectArea{
    [self gotoPageWithClass:[SelectAreaVC class] parameters:@{
                                                              PAGE_PARAM_AREA:_me.area==nil?[NSNull null]:_me.area,
                                                              }];
}

-(void)selectChatacter{
    
//    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
//    [Remote allCharacter:_me.id  callback:^(StorageCallbackData *callback_data) {
//        if(callback_data.code==0){
//            if(((NSArray*)callback_data.data).count>0){
//
//                NSString* characterid=@"";
//                if(_student!=nil){
//                    characterid=_student.id;
//                }else if(_teacher!=nil){
//                    characterid=_teacher.id;
//                }else if(_customerService!=nil){
//                    characterid=_customerService.id;
//                }else if(_operation!=nil){
//                    characterid=_operation.id;
//                }
//                
//                [self gotoPageWithClass:[SelectCharacterVC class] parameters:@{
//                                                                           PAGE_PARAM_PERSON:_me,
//                                                                           PAGE_PARAM_CHARACTER_SET:callback_data.data,
//                                                                           PAGE_PARAM_CHARACTER_ID:characterid,
//                                                                           }];
//            }else{
//                [self gotoPageWithClass:[ChangeCharacterVC class] parameters:@{
//                                                                               PAGE_PARAM_PERSON:_me,
//                                                                               }];
//            }
//        }else{
//            [Utility showError:callback_data.message type:ErrorType_Network];
//        }
//        [lv removeFromSuperview];
//    }];
    [self gotoPageWithClass:[SelectCharacterVC class] parameters:nil];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_PERSON isEqualToString:key]){
        if(value!=nil && [value isKindOfClass:[Person class]]){
            [RCIMDelegate refreshPersonInCache:value];
        }
    }else if([PAGE_PARAM_AREA isEqualToString:key]){
        Area* area=value;
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote updatePersonArea:area.id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Person* person=callback_data.data;
                [Storage setLoginInfo:person];
                [self refreshData];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
        
    }else if([PAGE_PARAM_STUDENT isEqualToString:key]){
        _student=value;
        _customerService=nil;
        _operation=nil;
        _teacher=nil;
        [Storage setStudent:value];
        _me.character_type=@"student";
        _me.certified=_student.certified;
        [Storage setLoginInfo:_me];
    }else if([PAGE_PARAM_TEACHER isEqualToString:key]){
        _student=nil;
        _customerService=nil;
        _operation=nil;
        _teacher=value;
        [Storage setTeacher:value];
        _me.character_type=@"teacher";
        _me.certified=_teacher.certified;
        [Storage setLoginInfo:_me];
    }else if([PAGE_PARAM_CUSTOMERSERVICE isEqualToString:key]){
        _student=nil;
        _teacher=nil;
        _operation=nil;
        _customerService=value;
        [Storage setCustomerService:value];
        _me.character_type=@"customerservice";
        _me.certified=_customerService.certified;
        [Storage setLoginInfo:_me];
    }else if([PAGE_PARAM_OPERATION isEqualToString:key]){
        _student=nil;
        _teacher=nil;
        _customerService=nil;
        _operation=value;
        [Storage setOperation:value];
        _me.character_type=@"operation";
        _me.certified=_operation.certified;
        [Storage setLoginInfo:_me];
    }else if([@"headImage" isEqualToString:key]){
        UIImage* image=value;
        if(image!=nil){
            __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
            [Remote updateHeadImageWithImage:image callback:^(StorageCallbackData *callback_data) {
                if(callback_data.code==0){
                    [_me.social setHeaderImage:image];
                    [UIUtility setFeatureItem:_headerView image:[_me.social getHeaderImage]];
                }else{
                    [Utility showError:callback_data.message type:ErrorType_Network];
                }
                [loadingView removeFromSuperview];
            }];
        }
    }
}
@end
