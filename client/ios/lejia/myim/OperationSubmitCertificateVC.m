//
//  OperationSubmitCertificateVC.m
//  myim
//
//  Created by Sean Shi on 15/11/12.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationSubmitCertificateVC.h"

@interface OperationSubmitCertificateVC ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    Person* _me;
    School* _school;
    Operation* _operation;
    
    HeaderView* headView;
    UIScrollView* _scrollView;
    
    //真实姓名
    FeatureItem* _nameItem;
    //手机号
    FeatureItem* _phoneItem;
    //身份证号码
    FeatureItem* _idcardItem;
    //身份证照
    UIView* _idImageView;
    UIImageView* _idcardFrontPictureView;
    UIImageView* _idcardBackPictureView;
    
    //驾校名称
    FeatureItem* _schoolNameItem;
    //组织机构代码
    FeatureItem* _companyCodeItem;
    //工商执照注册号
    FeatureItem* _licenceCodeItem;
    //法人代表/企业负责人姓名
    FeatureItem* _representativeItem;
    
    
    //组织机构代码证照片
    UIView* _companyPictureView;
    UIImageView* _companyPictureImageView;
    //工商执照照片
    UIView* _licencePictureView;
    UIImageView* _licencePictureImageView;

    
    UIImage* _idcardFrontPicture;
    UIImage* _idcardBackPicture;
    UIImage* _companyPicture;
    UIImage* _licencePicture;
    
    UIImageView* _pickPhotoImageView;
    
    UIImage* _emptyImage;
    
    BOOL _submited;
    BOOL _certified;
    NSArray* _submitedItems;
    UIView* _submitedMaskView;
    
    UIView* _headRightButton_submit;
    UIView* _headRightButton_revoke;
    
}

@end

@implementation OperationSubmitCertificateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _submited=false;
    _me=[Storage getLoginInfo];
    _operation=[Storage getOperation];
    _certified=[_operation isCertified];
    _school=_operation==nil?nil:_operation.school;
    _emptyImage=[[UIImage imageNamed:@"无图片"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _headRightButton_submit=[HeaderView genItemWithText:@"提交认证申请" target:self action:@selector(submit) height:HEIGHT_HEAD_ITEM_DEFAULT];
    _headRightButton_revoke=[HeaderView genItemWithText:@"取消申请" target:self action:@selector(revoke) height:HEIGHT_HEAD_ITEM_DEFAULT];
    [self checkWhetherSubmited];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)checkWhetherSubmited{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote operationCertificate:_operation.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _submited=true;
            _submitedItems=callback_data.data;
        }else if(callback_data.code==2){
            _submited=false;
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [self reloadView];
        [lv removeFromSuperview];
    }];
}

-(void)reloadView{
    [super reloadView];
    UIView* rightButton=nil;
    if(!_certified){
        if(_submited){
            rightButton=_headRightButton_revoke;
        }else{
            rightButton=_headRightButton_submit;
        }
    }
    
    headView=[[HeaderView alloc]
                          initWithTitle:_school.name
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(cancel) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:rightButton
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];

    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=CGPointMake(0, headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    _scrollView.bounces=false;
    
    
    
    
    //个人信息Title
    UILabel* perosnInfoLabel=[Utility genLabelWithText:@"个人信息" bgcolor:nil textcolor:COLOR_TEXT_SECONDARY font:FONT_TEXT_SECONDARY];
    [_scrollView addSubview:perosnInfoLabel];
    perosnInfoLabel.origin=CGPointMake(15, 15);
    
    _nameItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                              top:perosnInfoLabel.bottom+5
                                            title:@"真实姓名"
                                            value:nil//_me.name
                                           height:FEATURE_NORMAL_HEIGHT
                                        showSplit:false
                                        inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _phoneItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                               top:_nameItem.view.bottom
                                             title:@"手机号码"
                                             value:_me.phone
                                            height:FEATURE_NORMAL_HEIGHT
                                         showSplit:true
                                         inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _idcardItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                top:_phoneItem.view.bottom
                                              title:@"身份证号码"
                                              value:_me.idcard
                                             height:FEATURE_NORMAL_HEIGHT
                                          showSplit:true
                                          inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _idImageView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                  top:_idcardItem.view.bottom
                                                title:nil
                                               height:90
                                             rightObj:nil
                                               target:nil
                                               action:nil
                                            showSplit:true];
    //证件照标题
    UILabel* idImageTitleLabel=[Utility genLabelWithText:@"身份证照" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [_idImageView addSubview:idImageTitleLabel];
    idImageTitleLabel.top=10;
    idImageTitleLabel.left=15;
    UILabel* idImageExpainLabel=[Utility genLabelWithText:@"如果是二代身份证请拍摄正反面。\n需要本人手持证件正面拍照。请确保照片证件部分清晰可见。" bgcolor:nil textcolor:COLOR_TEXT_SECONDARY font:FONT_TEXT_SECONDARY];
    [_idImageView addSubview:idImageExpainLabel];
    CGFloat maxWidth=_idImageView.width-30;
    [idImageExpainLabel fitWithWidth:maxWidth];
    idImageExpainLabel.top=idImageTitleLabel.bottom+5;
    idImageExpainLabel.left=idImageTitleLabel.left;

    CGFloat idcardImageWidth=(_scrollView.width-30-20)/2;
    
    //证件照1
    _idcardFrontPictureView=[[UIImageView alloc]init];
    [_idImageView addSubview:_idcardFrontPictureView];
    _idcardFrontPictureView.size=CGSizeMake(idcardImageWidth, idcardImageWidth*1.5);
    _idcardFrontPictureView.origin=CGPointMake(idImageTitleLabel.left, idImageExpainLabel.bottom+30);
    _idcardFrontPictureView.layer.borderWidth=0.5;
    _idcardFrontPictureView.layer.borderColor=COLOR_SPLIT.CGColor;
    _idcardFrontPictureView.layer.cornerRadius=3;
    _idcardFrontPictureView.backgroundColor=COLOR_SPLIT;
    _idcardFrontPictureView.contentMode=UIViewContentModeScaleAspectFit;
    _idcardFrontPictureView.image=_emptyImage;
    _idcardFrontPictureView.tintColor=[UIColor whiteColor];
    _idcardFrontPictureView.tagObject=@"idcardfront";
    _idcardFrontPictureView.userInteractionEnabled=true;
    [_idcardFrontPictureView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickPhoto:)]];
    //证件照1标题
    UILabel* idImage1Label=[Utility genLabelWithText:@"身份证正面照" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_SECONDARY];
    [_idImageView addSubview:idImage1Label];
    idImage1Label.bottom=_idcardFrontPictureView.top-5;
    idImage1Label.centerX=_idcardFrontPictureView.centerX;
    
    //证件照2
    _idcardBackPictureView=[[UIImageView alloc]init];
    [_idImageView addSubview:_idcardBackPictureView];
    _idcardBackPictureView.size=_idcardFrontPictureView.size;
    _idcardBackPictureView.origin=CGPointMake(_idcardFrontPictureView.right+20, _idcardFrontPictureView.top);
    _idcardBackPictureView.layer.borderWidth=_idcardFrontPictureView.layer.borderWidth;
    _idcardBackPictureView.layer.borderColor=_idcardFrontPictureView.layer.borderColor;
    _idcardBackPictureView.layer.cornerRadius=_idcardFrontPictureView.layer.cornerRadius;
    _idcardBackPictureView.backgroundColor=_idcardFrontPictureView.backgroundColor;
    _idcardBackPictureView.contentMode=_idcardFrontPictureView.contentMode;
    _idcardBackPictureView.image=_idcardFrontPictureView.image;
    _idcardBackPictureView.tintColor=_idcardFrontPictureView.tintColor;
    _idcardBackPictureView.tagObject=@"idcardback";
    _idcardBackPictureView.userInteractionEnabled=true;
    [_idcardBackPictureView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickPhoto:)]];
    //证件照2标题
    UILabel* idImage2Label=[Utility genLabelWithText:@"身份证反面照" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_SECONDARY];
    [_idImageView addSubview:idImage2Label];
    idImage2Label.bottom=_idcardBackPictureView.top-5;
    idImage2Label.centerX=_idcardBackPictureView.centerX;
    
    //自适应内部元素高度
    [_idImageView fitHeightOfSubviews];
    _idImageView.height+=10;
    
    
    //个人信息Title
    UILabel* schoolInfoLabel=[Utility genLabelWithText:@"驾校资质信息" bgcolor:nil textcolor:COLOR_TEXT_SECONDARY font:FONT_TEXT_SECONDARY];
    [_scrollView addSubview:schoolInfoLabel];
    schoolInfoLabel.origin=CGPointMake(15, _idImageView.bottom+15);
    
    _schoolNameItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                    top:schoolInfoLabel.bottom+5
                                                  title:@"驾校全称"
                                                  value:_school.name
                                                 height:FEATURE_NORMAL_HEIGHT
                                              showSplit:false
                                              inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _companyCodeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                     top:_schoolNameItem.view.bottom
                                                   title:@"组织机构代码"
                                                   value:@""
                                                  height:FEATURE_NORMAL_HEIGHT
                                               showSplit:true
                                               inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _licenceCodeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                     top:_companyCodeItem.view.bottom
                                                   title:@"工商执照注册号"
                                                   value:@""
                                                  height:FEATURE_NORMAL_HEIGHT
                                               showSplit:true
                                               inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    _representativeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                        top:_licenceCodeItem.view.bottom
                                                      title:@"法人代表/企业负责人姓名"
                                                      value:@""
                                                     height:FEATURE_NORMAL_HEIGHT
                                                  showSplit:true
                                               inputType:CHANGEVALUE_INPUTTYPE_Default];
    
    CGFloat picWidth=_scrollView.width-30;
    //企业组织机构证照片
    _companyPictureView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                  top:_representativeItem.view.bottom
                                                title:nil
                                               height:90
                                             rightObj:nil
                                               target:nil
                                               action:nil
                                            showSplit:true];
    //组织机构代码证照片标题
    UILabel* companyPictureTitleLabel=[Utility genLabelWithText:@"组织机构证照片" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [_companyPictureView addSubview:companyPictureTitleLabel];
    companyPictureTitleLabel.top=10;
    companyPictureTitleLabel.left=15;
    //组织机构代码证照片
    _companyPictureImageView=[[UIImageView alloc]init];
    [_companyPictureView addSubview:_companyPictureImageView];
    
    _companyPictureImageView.size=CGSizeMake(picWidth, picWidth*2/3);
    _companyPictureImageView.origin=CGPointMake(companyPictureTitleLabel.left, companyPictureTitleLabel.bottom+10);
    _companyPictureImageView.layer.borderWidth=0.5;
    _companyPictureImageView.layer.borderColor=COLOR_SPLIT.CGColor;
    _companyPictureImageView.layer.cornerRadius=3;
    _companyPictureImageView.backgroundColor=COLOR_SPLIT;
    _companyPictureImageView.contentMode=UIViewContentModeScaleToFill;
    _companyPictureImageView.image=_emptyImage;
    _companyPictureImageView.tintColor=[UIColor whiteColor];
    _companyPictureImageView.userInteractionEnabled=true;
    [_companyPictureImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickCompanyPhoto:)]];
    
    //自适应内部元素高度
    [_companyPictureView fitHeightOfSubviews];
    _companyPictureView.height+=10;

    
    //工商执照照片
    _licencePictureView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                         top:_companyPictureView.bottom
                                                       title:nil
                                                      height:90
                                                    rightObj:nil
                                                      target:nil
                                                      action:nil
                                                   showSplit:true];
    //工商执照照片标题
    UILabel* licencePictureTitleLabel=[Utility genLabelWithText:@"工商执照照片" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [_licencePictureView addSubview:licencePictureTitleLabel];
    licencePictureTitleLabel.top=10;
    licencePictureTitleLabel.left=15;
    //工商执照照片
    _licencePictureImageView=[[UIImageView alloc]init];
    [_licencePictureView addSubview:_licencePictureImageView];
    _licencePictureImageView.size=CGSizeMake(picWidth, picWidth*2/3);
    _licencePictureImageView.origin=CGPointMake(licencePictureTitleLabel.left, licencePictureTitleLabel.bottom+10);
    _licencePictureImageView.layer.borderWidth=0.5;
    _licencePictureImageView.layer.borderColor=COLOR_SPLIT.CGColor;
    _licencePictureImageView.layer.cornerRadius=3;
    _licencePictureImageView.backgroundColor=COLOR_SPLIT;
    _licencePictureImageView.contentMode=UIViewContentModeScaleToFill;
    _licencePictureImageView.image=_emptyImage;
    _licencePictureImageView.tintColor=[UIColor whiteColor];
    _licencePictureImageView.userInteractionEnabled=true;
    [_licencePictureImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pickLicencePhoto:)]];
    
    //自适应内部元素高度
    [_licencePictureView fitHeightOfSubviews];
    _licencePictureView.height+=10;


    _scrollView.contentSize=CGSizeMake(_scrollView.width, _licencePictureView.bottom+20);
    
    if(_submited){
        [self loadSubmitedData];
        [self showSubmitMaskView];
    }else{
        [self loadDraft];
    }

}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([@"pickphoto" isEqualToString:key]){
        if(_pickPhotoImageView!=nil){
            if([@"idcardfront" isEqualToString:_pickPhotoImageView.tagObject]){
                _idcardFrontPicture=value;
            }else if ([@"idcardback" isEqualToString:_pickPhotoImageView.tagObject]){
                _idcardBackPicture=value;
            }
            _pickPhotoImageView.image=value;
            _pickPhotoImageView=nil;
        }
    }else if([@"companyphoto" isEqualToString:key]){
        _companyPicture=value;
        _companyPictureImageView.image=value;
    }else if([@"licencephoto" isEqualToString:key]){
        _licencePicture=value;
        _licencePictureImageView.image=value;
    }
}



-(void)pickPhoto:(UIGestureRecognizer*)sender{
    _pickPhotoImageView=(UIImageView*)sender.view;
    [UIUtility showImagePickerWithSourceType:99 fromViewController:self returnKey:@"pickphoto" size:CGSizeMake(300,450)];
}
-(void)pickCompanyPhoto:(UIGestureRecognizer*)sender{
    [UIUtility showImagePickerWithSourceType:99 fromViewController:self returnKey:@"companyphoto" size:CGSizeMake(450,300)];
}
-(void)pickLicencePhoto:(UIGestureRecognizer*)sender{
    [UIUtility showImagePickerWithSourceType:99 fromViewController:self returnKey:@"licencephoto" size:CGSizeMake(450,300)];
}


-(void)showSubmitMaskView{
    if(_submitedMaskView==nil){
        _submitedMaskView=[[UIView alloc]init];
        [_scrollView addSubview:_submitedMaskView];
        _submitedMaskView.backgroundColor=[UIColor whiteColor];
        _submitedMaskView.alpha=0.5;
    }
    _submitedMaskView.origin=CGPointMake(0, 0);
    _submitedMaskView.size=_scrollView.contentSize;
    _submitedMaskView.hidden=false;
}
-(void)hideSubmitMaskView{
    if(_submitedMaskView!=nil){
        _submitedMaskView.hidden=true;
    }
}

-(void)submit{
    BOOL complete=true;
    if([Utility  isEmptyString:_nameItem.rightValue]){
        [Utility showError:@"请填写姓名" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_phoneItem.rightValue]){
        [Utility showError:@"请填写手机号码" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_idcardItem.rightValue]){
        [Utility showError:@"请填写身份证号码" type:ErrorType_Network];
        complete=false;
    }
    if(_idcardFrontPicture==nil){
        [Utility showError:@"需要证件正面照" type:ErrorType_Network];
        complete=false;
    }
    if(_idcardBackPicture==nil){
        [Utility showError:@"需要证件背面照" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_schoolNameItem.rightValue]){
        [Utility showError:@"请填写驾校名称" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_companyCodeItem.rightValue]){
        [Utility showError:@"请填写组织机构代码" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_licenceCodeItem.rightValue]){
        [Utility showError:@"请填写工商执照注册号" type:ErrorType_Network];
        complete=false;
    }
    if([Utility  isEmptyString:_representativeItem.rightValue]){
        [Utility showError:@"请填写法人代表/企业负责人姓名" type:ErrorType_Network];
        complete=false;
    }
    if(_companyPicture==nil){
        [Utility showError:@"需要组织机构证照片" type:ErrorType_Network];
        complete=false;
    }
    if(_licencePicture==nil){
        [Utility showError:@"需要工商执照照片" type:ErrorType_Network];
        complete=false;
    }
    
    if(complete){
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote submitOperationCertificate:[self genSubmitData] callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [headView setRightBarItem:_headRightButton_revoke];
                [self showSubmitMaskView];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [lv removeFromSuperview];
        }];
    }
}

-(void)revoke{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote revokeOperationCertificate:_operation.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _idcardFrontPicture=_idcardFrontPictureView.image;
            _idcardBackPicture=_idcardBackPictureView.image;
            _companyPicture=_companyPictureImageView.image;
            _licencePicture=_licencePictureImageView.image;
            [self hideSubmitMaskView];
            [headView setRightBarItem:_headRightButton_submit];
            
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

-(void)cancel{
    if(!_submited){
        [self saveDraft];
    }
    [self gotoBack];
}

-(NSMutableDictionary<NSString*,id>*) genSubmitData{
    NSMutableDictionary<NSString*,id>* data=[NSMutableDictionary dictionaryWithDictionary:
                                                  @{
                                                    @"operationid":_operation.id,
                                                    @"name":[_nameItem getRightValue],
                                                    @"phone":[_phoneItem getRightValue],
                                                    @"idcard":[_idcardItem getRightValue],
                                                    @"schoolName":[_schoolNameItem getRightValue],
                                                    @"companyCode":[_companyCodeItem getRightValue],
                                                    @"licenceCode":[_licenceCodeItem getRightValue],
                                                    @"representative":[_representativeItem getRightValue],
                                                    }
                                                  ];
    if(_idcardFrontPicture!=nil){
        [data setObject:UIImageJPEGRepresentation(_idcardFrontPicture, 1) forKey:@"idcardFrontPicture"];
    }
    if(_idcardBackPicture!=nil){
        [data setObject:UIImageJPEGRepresentation(_idcardBackPicture, 1) forKey:@"idcardBackPicture"];
    }
    if(_companyPicture!=nil){
        [data setObject:UIImageJPEGRepresentation(_companyPicture, 1) forKey:@"companyPicture"];
    }
    if(_licencePicture!=nil){
        [data setObject:UIImageJPEGRepresentation(_licencePicture, 1) forKey:@"licencePicture"];
    }
    return data;
}
-(void)saveDraft{
    NSMutableDictionary<NSString*,id>* draftData=[self genSubmitData];
    [[NSUserDefaults standardUserDefaults] setObject:draftData forKey:@"CertificateDraft"];
}
-(void)loadDraft{
    NSDictionary<NSString*,id>* draftData=[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"CertificateDraft"];
    if([_operation.id isEqualToString:draftData[@"operationid"]]){
        _nameItem.rightValue=draftData[@"name"];
        _phoneItem.rightValue=draftData[@"phone"];
        _idcardItem.rightValue=draftData[@"idcard"];
        _schoolNameItem.rightValue=draftData[@"schoolName"];
        _companyCodeItem.rightValue=draftData[@"companyCode"];
        _licenceCodeItem.rightValue=draftData[@"licenceCode"];
        _representativeItem.rightValue=draftData[@"representative"];
        
        _idcardFrontPicture= draftData[@"idcardFrontPicture"]==nil?nil:[UIImage imageWithData:draftData[@"idcardFrontPicture"]];
        _idcardBackPicture=draftData[@"idcardBackPicture"]==nil?nil:[UIImage imageWithData:draftData[@"idcardBackPicture"]];
        _companyPicture=draftData[@"companyPicture"]==nil?nil:[UIImage imageWithData:draftData[@"companyPicture"]];
        _licencePicture=draftData[@"licencePicture"]==nil?nil:[UIImage imageWithData:draftData[@"licencePicture"]];
        
        _idcardFrontPictureView.image=_idcardFrontPicture==nil?_emptyImage:_idcardFrontPicture;
        _idcardBackPictureView.image=_idcardBackPicture==nil?_emptyImage:_idcardBackPicture;
        _companyPictureImageView.image=_companyPicture==nil?_emptyImage:_companyPicture;
        _licencePictureImageView.image=_licencePicture==nil?_emptyImage:_licencePicture;
    }else{
        _nameItem.rightValue=_me.name;
        _phoneItem.rightValue=_me.phone;
        _idcardItem.rightValue=_me.idcard;
        _schoolNameItem.rightValue=_school.name;
    }
    
}

-(void)loadSubmitedData{
    for(OperationCertificateItem* item in _submitedItems){
        if([@"name" isEqualToString:item.name]){
            _nameItem.rightValue=item.value;
        }else if([@"phone" isEqualToString:item.name]){
            _phoneItem.rightValue=item.value;
        }else if([@"idcard" isEqualToString:item.name]){
            _idcardItem.rightValue=item.value;
        }else if([@"schoolName" isEqualToString:item.name]){
            _schoolNameItem.rightValue=item.value;
        }else if([@"companyCode" isEqualToString:item.name]){
            _companyCodeItem.rightValue=item.value;
        }else if([@"licenceCode" isEqualToString:item.name]){
            _licenceCodeItem.rightValue=item.value;
        }else if([@"representative" isEqualToString:item.name]){
            _representativeItem.rightValue=item.value;
        }else if([@"idcardFrontPicture" isEqualToString:item.name]){
            [_idcardFrontPictureView sd_setImageWithURL:[NSURL URLWithString:item.imageurl] placeholderImage:_emptyImage];
        }else if([@"idcardBackPicture" isEqualToString:item.name]){
            [_idcardBackPictureView sd_setImageWithURL:[NSURL URLWithString:item.imageurl] placeholderImage:_emptyImage];
        }else if([@"companyPicture" isEqualToString:item.name]){
            [_companyPictureImageView sd_setImageWithURL:[NSURL URLWithString:item.imageurl] placeholderImage:_emptyImage];
        }else if([@"licencePicture" isEqualToString:item.name]){
            [_licencePictureImageView sd_setImageWithURL:[NSURL URLWithString:item.imageurl] placeholderImage:_emptyImage];
        }
    }
}

@end
