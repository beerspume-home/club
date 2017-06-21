//
//  PersonInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/10/20.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "PersonInfoVC.h"
#import <UIImageView+WebCache.h>

@interface PersonInfoVC (){
    Person* _myself;
    Person* _person;
    NSString* _personid;
    HeaderView* _header;
    BOOL _isMyFirend;
    BOOL _inited;
}

@end

@implementation PersonInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _inited=false;
    _myself=[Storage getLoginInfo];
    _isMyFirend=false;
    if(_person==nil && _personid!=nil){
        _person=[Cache getPerson:_personid];
    }
    [self reloadView];
    if(_person==nil && _personid!=nil){
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote getPersonWithId:_personid callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _person=callback_data.data;
                [loadingView removeFromSuperview];
                [self isFriend];
            }else{
                [loadingView removeFromSuperview];
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            
            
        }];
    }else{
        [self isFriend];
    }
}

-(void)isFriend{
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote isFriendBetweenMe:_myself.id andOther:_person.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _isMyFirend=[@"1" isEqualToString: callback_data.data];
        }
        [loadingView removeFromSuperview];
        _inited=true;
        [self reloadView];
    }];
}

-(void)reloadView{
    [super reloadView];
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"详细资料"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    if(_inited){
        //初始化信息栏
        UIView* infoView=[[UIView alloc]init];
        [self.view addSubview:infoView];
        infoView.backgroundColor=COLOR_FEATURE_BAR_BG;
        infoView.size=CGSizeMake(infoView.superview.width, 79);
        infoView.top=_header.bottom+18;
        infoView.left=0;
        //头像
        UIImageView* headImageView=[[UIImageView alloc]init];
        [infoView addSubview:headImageView];
        [headImageView sd_setImageWithURL:[[NSURL alloc] initWithString:_person.imageurl] placeholderImage:[UIImage imageNamed:@"缺省头像"]];
        headImageView.size=CGSizeMake(57, 57);
        headImageView.left=18;
        headImageView.centerY=headImageView.superview.height/2;
        //昵称
        UILabel* nicknameLabel=[Utility genLabelWithText:_person.socialname
                                                 bgcolor:nil
                                               textcolor:COLOR_TEXT_NORMAL
                                                    font:FONT_TEXT_NORMAL
                                ];
        [infoView addSubview:nicknameLabel];
        nicknameLabel.top=15;
        nicknameLabel.left=headImageView.right+22;
        //性别图标
        UIImageView* genderView=[[UIImageView alloc]init];
        [infoView addSubview:genderView];
        genderView.image=[UIImage imageNamed:([_person isMale]?@"缺省头像_男":@"缺省头像_女")];
        genderView.size=CGSizeMake(14, 14);
        genderView.centerY=nicknameLabel.centerY;
        genderView.left=nicknameLabel.right+12;
        //乐友号
        UILabel* usernameLabel=[Utility genLabelWithText:[NSString stringWithFormat:@"乐驾号: %@",_person.username]
                                                 bgcolor:nil
                                               textcolor:COLOR_TEXT_SECONDARY
                                                    font:FONT_TEXT_SECONDARY
                                ];
        [infoView addSubview:usernameLabel];
        usernameLabel.textAlignment=NSTextAlignmentLeft;
        usernameLabel.top=nicknameLabel.bottom+5;
        usernameLabel.left=nicknameLabel.left;
        
        
        NSString* characterText=@"";
        if([_person isTeacher]){
            characterText=[NSString stringWithFormat:@"%@ 教练",_person.school_name];
        }else if([_person isCustomerService]){
            characterText=[NSString stringWithFormat:@"%@ 客服",_person.school_name];
        }else if([_person isOperation]){
            characterText=[NSString stringWithFormat:@"%@ 运营",_person.school_name];
        }
        if(![Utility isEmptyString:characterText]){
            UIView* certifiedView=[UIUtility genCertifiedLabel:[_person isCertified]];
            [infoView addSubview:certifiedView];
            certifiedView.top=usernameLabel.bottom+5;
            certifiedView.left=usernameLabel.left;
            
            //身份信息
            UILabel* teacherLabel=[Utility genLabelWithText:characterText
                                                    bgcolor:nil
                                                  textcolor:COLOR_TEXT_SECONDARY
                                                       font:FONT_TEXT_SECONDARY];
            [infoView addSubview:teacherLabel];
            teacherLabel.textAlignment=NSTextAlignmentLeft;
            teacherLabel.left=certifiedView.right+5;
            teacherLabel.centerY=certifiedView.centerY;
        }
        
        if(_isMyFirend){
            //聊天按钮
            UILabel* chatLabel=[[UILabel alloc]init];
            chatLabel.backgroundColor=COLOR_BUTTON_BG;
            chatLabel.textColor=COLOR_BUTTON_TEXT;
            chatLabel.textAlignment=NSTextAlignmentCenter;
            chatLabel.layer.masksToBounds=YES;
            chatLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
            chatLabel.text=@"发消息";
            chatLabel.font=FONT_BUTTON;
            chatLabel.userInteractionEnabled=true;
            [chatLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toChat)]];
            [self.view addSubview:chatLabel];
            chatLabel.size=CGSizeMake(chatLabel.superview.width-60, HEIGHT_BUTTON);
            chatLabel.top=infoView.bottom+18;
            chatLabel.centerX=chatLabel.superview.width/2;
        }else{
            //关注按钮
            UILabel* addContactLabel=[[UILabel alloc]init];
            addContactLabel.backgroundColor=COLOR_BUTTON_BG;
            addContactLabel.textColor=COLOR_BUTTON_TEXT;
            addContactLabel.textAlignment=NSTextAlignmentCenter;
            addContactLabel.layer.masksToBounds=YES;
            addContactLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
            addContactLabel.text=@"添加到通讯录";
            addContactLabel.font=FONT_BUTTON;
            addContactLabel.userInteractionEnabled=true;
            [addContactLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addContact)]];
            [self.view addSubview:addContactLabel];
            addContactLabel.size=CGSizeMake(addContactLabel.superview.width-60, HEIGHT_BUTTON);
            addContactLabel.top=infoView.bottom+18;
            addContactLabel.centerX=addContactLabel.superview.width/2;
        }
    }

}
-(void)toChat{
    CVC* conversationVC=[[CVC alloc]
                         initWithConversationType:ConversationType_PRIVATE
                         targetId:_person.id
                         title:_person.socialname
                         ];
    
    [self.navigationController pushViewController:conversationVC animated:true];
}
-(void)addContact{
    [Remote addContacts:_person.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _isMyFirend=true;
            [Cache addContacts:@[_person]];
            [self reloadView];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
    }];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([key isEqualToString:PAGE_PARAM_PERSON]){
        _person=value;
    }else if([PAGE_PARAM_PERSONID isEqualToString:key]){
        _personid=value;
    }
}
@end
