//
//  MeVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "MeVC.h"
#define ME_ITEM_NORMAL_HEIGHT 43
#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SPLIT_HEIGHT 0.5

#define COLOR_FEATURE_BAR_BG [UIColor whiteColor]

@interface MeVC (){
    Person* _person;
    
    //用户信息栏
    UIView* _personInfoView;
    UIImageView* _headerImage;
    UILabel* _nicknameLabel;
    UILabel* _usernameLabel;
    UIImageView* _qrcodeImage;
    
    //日记
    UIView* _diaryView;

    //收藏
    UIView* _collectView;

    //钱包
    UIView* _walletView;

    //设置
    UIView* _settingView;

    //退出
    UIView* _logoutView;

    //二维码名片
    UIView* _qrcardMaskView;

}

@end

@implementation MeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _person=[Storage getLoginInfo];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_headerImage setImage:[_person.social getHeaderImage]];
    _nicknameLabel.text=_person.socialname;
    [Utility fitLabel:_nicknameLabel];
    _nicknameLabel.textAlignment=NSTextAlignmentLeft;
    if(_nicknameLabel.right>_qrcodeImage.left-5){
        _nicknameLabel.width=_qrcodeImage.left-5-_nicknameLabel.left;
    }
    
}


-(void)reloadView{
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);
    UIColor* color_feature_bar_bg=[UIColor whiteColor];
    
    //初始化用户信息栏
    if(_personInfoView==nil){
        _personInfoView=[[UIView alloc]init];
        _personInfoView.backgroundColor=color_feature_bar_bg;
        _personInfoView.userInteractionEnabled=true;
        [_personInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPersonInfo)]];
        [self.view addSubview:_personInfoView];
    }
    _personInfoView.width=_personInfoView.superview.width;
    _personInfoView.height=71;
    _personInfoView.top=18;
    //用户头像
    if(_headerImage==nil){
        _headerImage=[[UIImageView alloc] init];
        _headerImage.contentMode=UIViewContentModeScaleAspectFit;
        [_personInfoView addSubview:_headerImage];
    }
    _headerImage.size=CGSizeMake(57, 57);
    _headerImage.left=11;
    _headerImage.centerY=_headerImage.superview.height/2;
    //姓名
    if(_nicknameLabel==nil){
        _nicknameLabel=[[UILabel alloc] init];
        _nicknameLabel.font=FONT_TEXT_NORMAL;
        _nicknameLabel.textColor=COLOR_TEXT_NORMAL;
        [_personInfoView addSubview:_nicknameLabel];
    }
    _nicknameLabel.text=_person.socialname;
    [Utility fitLabel:_nicknameLabel];
    _nicknameLabel.origin=CGPointMake(_headerImage.right+12, 15);
    //乐驾号
    if(_usernameLabel==nil){
        _usernameLabel=[[UILabel alloc] init];
        _usernameLabel.font=FONT_TEXT_SECONDARY;
        _usernameLabel.textColor=COLOR_TEXT_SECONDARY;
        [_personInfoView addSubview:_usernameLabel];
    }
    _usernameLabel.text=[NSString stringWithFormat:@"乐驾号: %@",(_person.username==nil?@"":_person.username)];
    [Utility fitLabel:_usernameLabel];
    _usernameLabel.textAlignment=NSTextAlignmentLeft;
    _usernameLabel.origin=CGPointMake(_nicknameLabel.left, _nicknameLabel.bottom+3);
    //二维码图标
    if(_qrcodeImage==nil){
        _qrcodeImage=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"me_icon_二维码"]];
        _qrcodeImage.userInteractionEnabled=true;
        [_qrcodeImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showQRCode)]];
        [_personInfoView addSubview:_qrcodeImage];
    }
    _qrcodeImage.size=CGSizeMake(25, 25);
    _qrcodeImage.right=_qrcodeImage.superview.width-28;
    _qrcodeImage.centerY=_qrcodeImage.superview.height/2;
    
    //日记
    _diaryView=[self genItemInSuperView:self.view
                                    top:_personInfoView.bottom+18
                                   icon:[UIImage imageNamed:@"me_icon_日记"]
                                  title:@"日记"
                                 height:ME_ITEM_NORMAL_HEIGHT
                                 target:self
                                 action:@selector(gotoDiary)
                              showSplit:false
                ];

    //收藏
    _collectView=[self genItemInSuperView:self.view
                                      top:_diaryView.bottom
                                     icon:[UIImage imageNamed:@"me_icon_收藏"]
                                    title:@"收藏"
                                   height:ME_ITEM_NORMAL_HEIGHT
                                   target:self
                                   action:@selector(gotoCollect)
                                showSplit:true
                  ];
    //钱包
    _walletView=[self genItemInSuperView:self.view
                                     top:_collectView.bottom
                                    icon:[UIImage imageNamed:@"me_icon_钱包"]
                                   title:@"钱包"
                                  height:ME_ITEM_NORMAL_HEIGHT
                                  target:self
                                  action:@selector(gotoWallet)
                               showSplit:true
                 ];
    
    //设置
    _settingView=[self genItemInSuperView:self.view
                                      top:_walletView.bottom+18
                                     icon:[UIImage imageNamed:@"me_icon_设置"]
                                    title:@"设置"
                                   height:ME_ITEM_NORMAL_HEIGHT
                                   target:self
                                   action:@selector(gotoSetting)
                                showSplit:false
                  ];

    //退出
    _logoutView=[self genItemInSuperView:self.view
                                      top:_settingView.bottom+18
                                     icon:nil
                                    title:@"退出"
                                   height:ME_ITEM_NORMAL_HEIGHT
                                   target:self
                                   action:@selector(logout)
                                showSplit:false
                  ];
}

-(UIView*)genItemInSuperView:(nonnull UIView*)superview top:(CGFloat)top icon:(nullable UIImage*)icon title:(nonnull NSString*)title height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit{
    //信息栏
    UIView* ret=[[UIView alloc]init];
    ret.backgroundColor=COLOR_FEATURE_BAR_BG;
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    [superview addSubview:ret];
    [ret setFrame:CGRectMake(0, top, ret.superview.width, height)];
    //图标
    UIImageView* iconView=[[UIImageView alloc]init];
    iconView.image=icon;
    iconView.contentMode=UIViewContentModeScaleAspectFit;
    [ret addSubview:iconView];
    iconView.size=CGSizeMake(25, 25);
    iconView.left=PADDING_LEFT+8;
    iconView.centerY=iconView.superview.height/2;
    //信息栏文字
    UILabel* titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.text=title;
    [ret addSubview:titleLabel];
    [Utility fitLabel:titleLabel usePadding:true];
    titleLabel.left=iconView.right+10;
    titleLabel.centerY=titleLabel.superview.height/2;
    //分割线
    if(showSplit){
        UIView* split=[[UIView alloc]init];
        split.backgroundColor=COLOR_SPLIT;
        [ret addSubview:split];
        split.size=CGSizeMake(split.superview.width-PADDING_LEFT-PADDING_RIGHT, SPLIT_HEIGHT);
        split.top=0;
        split.centerX=split.superview.width/2;
        
    }
    
    return ret;
}

//显示二维码卡片
-(void)showQRCode{
    UIView* rootview=self.view.superview;
    while(rootview.superview!=nil){
        rootview=rootview.superview;
    }
    //蒙版
    _qrcardMaskView=[[UIView alloc]initWithFrame:rootview.frame];
    [rootview addSubview:_qrcardMaskView];
    _qrcardMaskView.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.3];
    _qrcardMaskView.userInteractionEnabled=true;
    [_qrcardMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideQRCode)]];
    //卡片底板
    UIView* _qrcardView=[[UIView alloc] init];
    _qrcardView.layer.masksToBounds=true;
    _qrcardView.layer.cornerRadius=3.0;
    _qrcardView.backgroundColor=[UIColor whiteColor];
    [_qrcardMaskView addSubview:_qrcardView];
    _qrcardView.size=CGSizeMake(249,369);
    _qrcardView.center=_qrcardView.superview.innerCenterPoint;
    //头像
    UIImageView* _qrcardHeaderImage=[[UIImageView alloc] init];
    [_qrcardView addSubview:_qrcardHeaderImage];
    _qrcardHeaderImage.size=CGSizeMake(57, 57);
    _qrcardHeaderImage.origin=CGPointMake(21, 32);
    [_qrcardHeaderImage setImage:[_person.social getHeaderImage]];
    //姓名
    UILabel* _qrcardNameLabel=[[UILabel alloc] init];
    _qrcardNameLabel.font=FONT_TEXT_NORMAL;
    _qrcardNameLabel.textColor=COLOR_TEXT_NORMAL;
    [_qrcardView addSubview:_qrcardNameLabel];
    _qrcardNameLabel.text=_person.socialname;
    [Utility fitLabel:_qrcardNameLabel];
    _qrcardNameLabel.origin=CGPointMake(_qrcardHeaderImage.right+5, 41.5);
    //性别图标
    UIImageView* _qrcardGenderImage=[[UIImageView alloc] init];
    [_qrcardView addSubview:_qrcardGenderImage];
    _qrcardGenderImage.size=CGSizeMake(14, 14);
    _qrcardGenderImage.left=_qrcardNameLabel.right+5;
    _qrcardGenderImage.centerY=_qrcardNameLabel.centerY;
    if([_person isMale]){
        [_qrcardGenderImage setImage:[UIImage imageNamed:@"缺省头像_男"]];
    }else{
        [_qrcardGenderImage setImage:[UIImage imageNamed:@"缺省头像_女"]];
    }
    //乐驾号
    UILabel* _qrcardUsernameLabel=[[UILabel alloc] init];
    _qrcardUsernameLabel.font=FONT_TEXT_SECONDARY;
    _qrcardUsernameLabel.textColor=COLOR_TEXT_SECONDARY;
    [_qrcardView addSubview:_qrcardUsernameLabel];
    _qrcardUsernameLabel.text=[NSString stringWithFormat:@"乐驾号: %@",(_person.username==nil?@"":_person.username)];
    [Utility fitLabel:_qrcardUsernameLabel];
    _qrcardUsernameLabel.origin=CGPointMake(_qrcardNameLabel.left, _qrcardNameLabel.bottom+10);
    //二维码
    UIImageView* _qrcardQRCodeImage=[[UIImageView alloc] init];
    [_qrcardView addSubview:_qrcardQRCodeImage];
    _qrcardQRCodeImage.size=CGSizeMake(206, 206);
    _qrcardQRCodeImage.top=_qrcardHeaderImage.bottom+14.5;
    _qrcardQRCodeImage.centerX=_qrcardQRCodeImage.superview.width/2;
    [_qrcardQRCodeImage setImage:[_person genQRCodeWithSize:206]];
    //说明
    UILabel* _qrcardExplainLabel=[[UILabel alloc]init];
    _qrcardExplainLabel.textColor=COLOR_TEXT_SECONDARY;
    _qrcardExplainLabel.font=FONT_TEXT_SECONDARY;
    _qrcardExplainLabel.text=@"扫一扫上面的二维码图案，添加好友";
    [_qrcardView addSubview:_qrcardExplainLabel];
    [Utility fitLabel:_qrcardExplainLabel];
    _qrcardExplainLabel.top=_qrcardQRCodeImage.bottom+15;
    _qrcardExplainLabel.centerX=_qrcardExplainLabel.superview.width/2;
}
-(void)hideQRCode{
    if(_qrcardMaskView!=nil && _qrcardMaskView.superview!=nil){
        [_qrcardMaskView removeFromSuperview];
    }
}
-(void)gotoPersonInfo{
    [self gotoPageWithClass:[MyInfoVC class]];
}
-(void)gotoDiary{
    //TODO
}
-(void)gotoCollect{
    //TODO
}
-(void)gotoWallet{
    [self gotoPageWithClass:[WalletVC class]];
}
-(void)gotoSetting{
    //TODO
}
-(void)logout{
    [Storage setLoginInfo:nil];
    [Storage setTeacher:nil];
    [Storage setStudent:nil];
    [Storage setCustomerService:nil];
    [Storage setOperation:nil];
    [Storage setUserImage:nil];
    [Storage setRCUserToken:nil];
    [[RCIM sharedRCIM] logout];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:PAGE_PARAM_UNCERTIFY];
    [self.navigationController popToRootViewControllerAnimated:false];
}
@end
