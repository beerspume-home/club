//
//  SchoolMPPageVC.m
//  myim
//
//  Created by Sean Shi on 15/10/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SchoolMPPageVC.h"

@interface SchoolMPPageVC ()<UIWebViewDelegate>{
    School* _school;
    BOOL _isInterestedSchool;
    UILabel* _interestLabel;
}

@end

@implementation SchoolMPPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [Remote log:@"enter_school_mp" ext:@[_school.id] callback:nil];
    _isInterestedSchool=false;
    [self reloadView];
}

-(void)reloadInterestButton{
    if(_isInterestedSchool){
        _interestLabel.text=@"取消关注";
    }else{
        _interestLabel.text=@"关注驾校";
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(getSystemVersion()>=7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote isInterestedSchool:_school.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _isInterestedSchool=[@"1" isEqualToString:callback_data.data];
            [self reloadInterestButton];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

-(void)reloadView{
    [super reloadView];
    self.view.backgroundColor=[UIColor whiteColor];
    
    //返回按钮
    UIView* backView=[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT];
    [self.view addSubview:backView];
    backView.width=43;
    backView.centerY=42;
    backView.left=0;
    backView.tintColor=[UIColor blackColor];
    
    //驾校Logo
    UIImageView* logoView=[[UIImageView alloc]init];
    [self.view addSubview:logoView];
    [logoView sd_setImageWithURL:[NSURL URLWithString:_school.imageurl] placeholderImage:[UIImage imageNamed:@"驾校缺省Logo"]];
    logoView.size=CGSizeMake(60, 60);
    logoView.origin=CGPointMake(backView.right+5, 40);
    logoView.layer.cornerRadius=logoView.width/2;
    
    //驾校名称
    UILabel* nameLabel=[[UILabel alloc]init];
    [self.view addSubview:nameLabel];
    nameLabel.font=FONT_TEXT_NORMAL;
    nameLabel.textColor=COLOR_TEXT_NORMAL;
    nameLabel.text=_school.name;
    [Utility fitLabel:nameLabel];
    nameLabel.left=logoView.right+10;
    nameLabel.top=logoView.top+5;
    
    //所属地区
    UILabel* areaLabel=[[UILabel alloc]init];
    [self.view addSubview:areaLabel];
    areaLabel.font=FONT_TEXT_SECONDARY;
    areaLabel.textColor=COLOR_TEXT_SECONDARY;
    areaLabel.text=_school.area.namepath;
    [Utility fitLabel:areaLabel];
    areaLabel.left=nameLabel.left;
    areaLabel.top=nameLabel.bottom+5;
    
    //认证标记
    UILabel* certifiedLabel=[UIUtility genCertifiedLabel:[_school isCertified]];
    [self.view addSubview:certifiedLabel];
    certifiedLabel.top=areaLabel.bottom+5;
    certifiedLabel.left=areaLabel.left;
    
    
    static CGFloat bottonSpace=20;
    CGFloat bottonWidth=(self.view.width-(bottonSpace*4))/3;
    //在线咨询
    UILabel* serviceLabel=[UIUtility genButtonToSuperview:self.view top:logoView.bottom+10 title:@"在线咨询" target:nil action:nil];
    serviceLabel.font=FONT_TEXT_SECONDARY;
    serviceLabel.origin=CGPointMake(bottonSpace, logoView.bottom+10);
    serviceLabel.size=CGSizeMake(bottonWidth, 30);
    serviceLabel.userInteractionEnabled=true;
    [serviceLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showCustomerService)]];

    //关注驾校
    _interestLabel=[UIUtility genButtonToSuperview:self.view top:logoView.bottom+10 title:@"关注驾校" target:nil action:nil];
    _interestLabel.font=FONT_TEXT_SECONDARY;
    _interestLabel.origin=CGPointMake(serviceLabel.right+bottonSpace, logoView.bottom+10);
    _interestLabel.size=CGSizeMake(bottonWidth, 30);
    _interestLabel.userInteractionEnabled=true;
    [_interestLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(interestSchool)]];
    //查看教练
    UILabel* teacherLabel=[UIUtility genButtonToSuperview:self.view top:logoView.bottom+10 title:@"查看教练" target:nil action:nil];
    teacherLabel.font=FONT_TEXT_SECONDARY;
    teacherLabel.origin=CGPointMake(_interestLabel.right+bottonSpace, logoView.bottom+10);
    teacherLabel.size=CGSizeMake(bottonWidth, 30);
    teacherLabel.userInteractionEnabled=true;
    [teacherLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTeacher)]];
    
    //滚动部分
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.origin=CGPointMake(0, serviceLabel.bottom+20);
    scrollView.size=CGSizeMake(scrollView.superview.width, scrollView.superview.height-scrollView.top);
    scrollView.bounces=false;


    //驾校介绍标题
    UILabel* introTitleLabel=[[UILabel alloc]init];
    [scrollView addSubview:introTitleLabel];
    introTitleLabel.font=FONT_TEXT_NORMAL;
    introTitleLabel.textColor=COLOR_TEXT_NORMAL;
    introTitleLabel.text=@"驾校介绍";
    [introTitleLabel fit];
    introTitleLabel.left=15;
    introTitleLabel.top=0;
    
    CGFloat maxWitdh=scrollView.width-(introTitleLabel.right+10)-12;
    //驾校介绍
    UILabel* introLabel=[[UILabel alloc]init];
    [scrollView addSubview:introLabel];
    introLabel.font=FONT_TEXT_SECONDARY;
    introLabel.textColor=COLOR_TEXT_NORMAL;
    introLabel.text=[Utility isEmptyString:_school.introduction]?@"暂无介绍":_school.introduction;
    introLabel.left=introTitleLabel.right+10;
    introLabel.top=introTitleLabel.top;
    [introLabel fitWithWidth:maxWitdh];
    introLabel.lineBreakMode=NSLineBreakByTruncatingTail;
    introLabel.height=introLabel.height>60?60:introLabel.height;
    introLabel.userInteractionEnabled=true;
    [introLabel addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showIntro)]];
    
    CGFloat productListTop=introLabel.bottom>introTitleLabel.bottom?introLabel.bottom:introTitleLabel.bottom;
    if(_school.pictures!=nil && _school.pictures.count>0){
        //驾校一景标题
        UILabel* picturesTitleLabel=[[UILabel alloc]init];
        [scrollView addSubview:picturesTitleLabel];
        picturesTitleLabel.font=FONT_TEXT_NORMAL;
        picturesTitleLabel.textColor=COLOR_TEXT_NORMAL;
        picturesTitleLabel.text=@"驾校一景";
        [picturesTitleLabel fit];
        picturesTitleLabel.right=introTitleLabel.right;
        picturesTitleLabel.top=introLabel.bottom+10;
    
        //驾校一景
        UIScrollView* picturesScrollView=[[UIScrollView alloc]init];
        [scrollView addSubview:picturesScrollView];
        picturesScrollView.size=CGSizeMake(picturesScrollView.superview.width-20, 60);
        picturesScrollView.origin=CGPointMake(10, picturesTitleLabel.bottom+5);
        picturesScrollView.bounces=false;
        CGFloat picX=0;
        for(int i=0;i<_school.pictures.count;i++){
            NSString* pictureUrl=_school.pictures[i];
            //驾校照片
            UIImageView* imageView=[[UIImageView alloc]init];
            [picturesScrollView addSubview:imageView];
            [imageView sd_setImageWithURL:[NSURL URLWithString:pictureUrl] placeholderImage:[UIImage imageNamed:@"图片找不到"]];
            imageView.size=CGSizeMake(90, 60);
            imageView.origin=CGPointMake(picX, 0);
            imageView.userInteractionEnabled=true;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPicture:)]];
            picX=imageView.right+5;
        }
        [picturesScrollView fitContentWidthWithPadding:5];
        productListTop=picturesScrollView.bottom;
    }
    
    //驾校班级
    UIView* productListView=[[UIView alloc]init];
    [scrollView addSubview:productListView];
    productListView.origin=CGPointMake(0, productListTop+20);
    productListView.size=CGSizeMake(productListView.superview.width, 0);
    
    CGFloat y=0;
    UIFont* font=FONT_TEXT_NORMAL;
    CGFloat splitPadding=10;
    CGFloat leftWidth= getStringSize(@"四个字宽", font).width+20;
    CGFloat rightWidth=productListView.width-leftWidth-splitPadding*2-12;
    for(int i=0;i<_school.classes.count;i++){
        NSArray* contentDict=@[
                               @{@"课程名称:":[NSString stringWithFormat:@"(%@) %@",_school.classes[i].licensetype,_school.classes[i].name]},
                               @{@"价格:":[NSString stringWithFormat:@"%@ 元",_school.classes[i].fee]},
                               @{@"训练时间:":_school.classes[i].trainingtime},
                               @{@"训练车型:":_school.classes[i].cartype},
                               ];
        
        
        UIView* classView=[[UIView alloc]init];
        [productListView addSubview:classView];
        classView.top=y;
        classView.left=12;
        classView.size=CGSizeMake(classView.superview.width-24, 0);
        classView.backgroundColor=[UIColor whiteColor];
        classView.layer.masksToBounds=false;
        classView.layer.borderWidth=1;
        classView.layer.borderColor=[COLOR_BUTTON_BG CGColor];
        classView.layer.cornerRadius=3;
        classView.layer.shadowColor=[[UIColor blackColor]CGColor];
        classView.layer.shadowOpacity=0.5;
        classView.layer.shadowOffset=CGSizeMake(0, 0);
        
        UIView* split0View=[[UIView alloc]init];
        [classView addSubview:split0View];
        split0View.origin=CGPointMake(leftWidth+(splitPadding/2), 0);
        split0View.size=CGSizeMake(0.5, 0);
        split0View.backgroundColor=COLOR_SPLIT;
        
        CGFloat yy=10;
        for(int j=0;j<contentDict.count;j++){
            NSDictionary* line=contentDict[j];
            NSString* name=[line keyEnumerator].nextObject;
            NSString* value=[line objectForKey:name];

            //标题
            UILabel* titleLabel=[Utility genLabelWithText:name bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
            [classView addSubview:titleLabel];
            titleLabel.right=leftWidth;
            titleLabel.top=yy;
            //内容
            UILabel* valueLabel=[Utility genLabelWithText:value bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
            [classView addSubview:valueLabel];
            valueLabel.text=value;
            [valueLabel fitWithWidth:rightWidth];
            valueLabel.origin=CGPointMake(leftWidth+splitPadding, titleLabel.top);
            
            UIView* splitView=[[UIView alloc]init];
            [classView addSubview:splitView];
            splitView.left=0;
            splitView.top=(titleLabel.bottom>valueLabel.bottom?titleLabel.bottom:valueLabel.bottom)+10;
            splitView.size=CGSizeMake(0, 0.5);
            splitView.backgroundColor=COLOR_SPLIT;
            splitView.width=splitView.superview.width;
            
            yy=splitView.bottom+10;
            split0View.height=splitView.bottom;
        }
        

        //报名
        UILabel* signupLabel=[UIUtility genButtonToSuperview:classView
                                                         top:yy
                                                       title:@"我要报名"
                                             backgroundColor:COLOR_BUTTON_BG
                                                   textColor:COLOR_BUTTON_TEXT
                                                       width:80
                                                      height:30
                                                      target:self
                                                      action:@selector(signup:)
                              ];
        
        signupLabel.centerX=signupLabel.superview.width/2;
        signupLabel.tagObject=_school.classes[i];

        [classView fitHeightOfSubviews];
        classView.height+=10;
        y=classView.bottom+20;
    }

    [productListView fitHeightOfSubviews];
    [scrollView fitContentHeightWithPadding:20];

}

-(void)showPicture:(UIGestureRecognizer*)sender{
    if([sender.view isKindOfClass:[UIImageView class]]){
        UIImageView* v=(UIImageView*)sender.view;
        [self gotoPageWithClass:[ShowImageVC class] parameters:@{
                                                             PAGE_PARAM_IMAGE:v.image,
                                                             }];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL isEqualToString:key]){
        _school=value;
    }
}

-(void)interestSchool{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    if(_isInterestedSchool){
        [Remote uninterestSchool:_school.id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _isInterestedSchool=false;
                [self reloadInterestButton];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [lv removeFromSuperview];
        }];
    }else{
        [Remote interestSchool:_school.id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _isInterestedSchool=true;
                [self reloadInterestButton];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [lv removeFromSuperview];
        }];
    }
}

-(void)showTeacher{
    [self gotoPageWithClass:[SchoolStaffListVC class] parameters:@{
                                                                   PAGE_PARAM_SCHOOL_ID:_school.id,
                                                                   PAGE_PARAM_TITLE:[NSString stringWithFormat:@"%@-教练",_school.name],
                                                                   PAGE_PARAM_CHARACTERTYPE:@"teacher"
                                                                   }];
}
-(void)showCustomerService{
    [self gotoPageWithClass:[SchoolStaffListVC class] parameters:@{
                                                                   PAGE_PARAM_SCHOOL_ID:_school.id,
                                                                   PAGE_PARAM_TITLE:[NSString stringWithFormat:@"%@-客服",_school.name],
                                                            PAGE_PARAM_CHARACTERTYPE:@"customerservice"
                                                                   }];
}
-(void)showIntro{
    //http://eqxiu.com/s/uQaVdQ
//    NSString* url=@"http://eqxiu.com/s/uQaVdQ";
    NSString* url=@"http://www.jiaxiao.com.cn/wap/about.html";
    [self gotoPageWithClass:[WebPageVC class] parameters:@{
//                                                           PAGE_PARAM_TITLE:_school.name,
                                                           PAGE_PARAM_URL:url,
                                                           }];
}

-(void)signup:(UIGestureRecognizer*)sender{
    SchoolClass* class=sender.view.tagObject;
    [self gotoPageWithClass:[SchoolSignupVC class] parameters:@{
                                                                PAGE_PARAM_SCHOOL:_school,
                                                                PAGE_PARAM_SCHOOLCLASS:class,
                                                                }];
}
@end
