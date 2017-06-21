//
//  QRCodeVC.m
//  myim
//
//  Created by Sean Shi on 15/10/18.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "QRCodeVC.h"

@interface QRCodeVC (){
    Person* _person;
    HeaderView* _header;
    
    //二维码名片
    UIView* _qrcardView;
    UIImageView* _qrcardHeaderImage;
    UILabel* _qrcardNameLabel;
    UILabel* _qrcardUsernameLabel;
    UIImageView* _qrcardGenderImage;
    UIImageView* _qrcardQRCodeImage;
    UILabel* _qrcardExplainLabel;
}

@end

@implementation QRCodeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _person=[Storage getLoginInfo];
    [self reloadView];
}
-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"二维码名片"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];

    //初始化二维码卡片
    _qrcardView=[[UIView alloc] init];
    [self.view addSubview:_qrcardView];
    _qrcardView.layer.masksToBounds=true;
    _qrcardView.layer.cornerRadius=3.0;
    _qrcardView.backgroundColor=[UIColor whiteColor];
    _qrcardView.size=CGSizeMake(_qrcardView.superview.width,_qrcardView.superview.height-_header.height);
    _qrcardView.top=_header.bottom;
    _qrcardView.centerX=_qrcardView.superview.width/2;
    //头像
    if(_qrcardHeaderImage==nil){
        _qrcardHeaderImage=[[UIImageView alloc] init];
        [_qrcardView addSubview:_qrcardHeaderImage];
    }
    _qrcardHeaderImage.size=CGSizeMake(57, 57);
    _qrcardHeaderImage.origin=CGPointMake(25, 25);
    [_qrcardHeaderImage setImage:[_person.social getHeaderImage]];
    //姓名
    if(_qrcardNameLabel==nil){
        _qrcardNameLabel=[[UILabel alloc] init];
        _qrcardNameLabel.font=FONT_TEXT_NORMAL;
        _qrcardNameLabel.textColor=COLOR_TEXT_NORMAL;
        [_qrcardView addSubview:_qrcardNameLabel];
    }
    _qrcardNameLabel.text=_person.name;
    [Utility fitLabel:_qrcardNameLabel];
    _qrcardNameLabel.origin=CGPointMake(_qrcardHeaderImage.right+5, 41.5);
    //性别图标
    if(_qrcardGenderImage==nil){
        _qrcardGenderImage=[[UIImageView alloc] init];
        [_qrcardView addSubview:_qrcardGenderImage];
    }
    _qrcardGenderImage.size=CGSizeMake(14, 14);
    _qrcardGenderImage.left=_qrcardNameLabel.right+5;
    _qrcardGenderImage.centerY=_qrcardNameLabel.centerY;
    if([_person isMale]){
        [_qrcardGenderImage setImage:[UIImage imageNamed:@"缺省头像_男"]];
    }else{
        [_qrcardGenderImage setImage:[UIImage imageNamed:@"缺省头像_女"]];
    }
    //乐驾号
    if(_qrcardUsernameLabel==nil){
        _qrcardUsernameLabel=[[UILabel alloc] init];
        _qrcardUsernameLabel.font=FONT_TEXT_SECONDARY;
        _qrcardUsernameLabel.textColor=COLOR_TEXT_SECONDARY;
        [_qrcardView addSubview:_qrcardUsernameLabel];
    }
    _qrcardUsernameLabel.text=[NSString stringWithFormat:@"乐驾号: %@",(_person.username==nil?@"":_person.username)];
    [Utility fitLabel:_qrcardUsernameLabel];
    _qrcardUsernameLabel.origin=CGPointMake(_qrcardNameLabel.left, _qrcardNameLabel.bottom+10);
    //二维码
    if(_qrcardQRCodeImage==nil){
        _qrcardQRCodeImage=[[UIImageView alloc] init];
        [_qrcardView addSubview:_qrcardQRCodeImage];
    }
    _qrcardQRCodeImage.size=CGSizeMake(206, 206);
    _qrcardQRCodeImage.top=_qrcardHeaderImage.bottom+50;
    _qrcardQRCodeImage.centerX=_qrcardQRCodeImage.superview.width/2;
    [_qrcardQRCodeImage setImage:[_person genQRCodeWithSize:206]];
    //说明
    if(_qrcardExplainLabel==nil){
        _qrcardExplainLabel=[[UILabel alloc]init];
        _qrcardExplainLabel.textColor=COLOR_TEXT_SECONDARY;
        _qrcardExplainLabel.font=FONT_TEXT_SECONDARY;
        _qrcardExplainLabel.text=@"扫一扫上面的二维码图案，添加好友";
        [_qrcardView addSubview:_qrcardExplainLabel];
    }
    [Utility fitLabel:_qrcardExplainLabel];
    _qrcardExplainLabel.top=_qrcardQRCodeImage.bottom+15;
    _qrcardExplainLabel.centerX=_qrcardExplainLabel.superview.width/2;
}
@end
