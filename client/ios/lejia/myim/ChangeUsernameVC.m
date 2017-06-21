//
//  ChangeUsernameVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChangeUsernameVC.h"

@interface ChangeUsernameVC ()<UITextFieldDelegate>{
    Person* _person;
    HeaderView* _header;
    
    UITextField* _textField;
}


@end

@implementation ChangeUsernameVC
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
             initWithTitle:@"设置乐驾号"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:[HeaderView genItemWithType:HeaderItemType_Save target:self action:@selector(save) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //昵称输入框
    _textField=[[UITextField alloc]init];
    [self.view addSubview:_textField];
    _textField.borderStyle=UITextBorderStyleNone;
    _textField.returnKeyType=UIReturnKeyDone;
    _textField.delegate=self;
    _textField.placeholder=@"";
    _textField.textAlignment=NSTextAlignmentLeft;
    _textField.font=FONT_BUTTON;
    _textField.text=@"";
    _textField.keyboardType=UIKeyboardTypeASCIICapable;
    _textField.size=CGSizeMake(_textField.superview.width-50, HEIGHT_BUTTON);
    _textField.top=_header.bottom+20;
    _textField.centerX=_textField.superview.width/2;
    _textField.spellCheckingType=UITextSpellCheckingTypeNo;
    _textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [_textField becomeFirstResponder];
    //输入框下划线
    UIView* underLine=[[UIView alloc]init];
    [self.view addSubview:underLine];
    underLine.size=CGSizeMake(_textField.width+10, 1);
    underLine.backgroundColor=[UIColor brownColor];
    underLine.top=_textField.bottom-8;
    underLine.centerX=_textField.centerX;
    //说明
    UILabel* explainLabel=[[UILabel alloc]init];
    [self.view addSubview:explainLabel];
    explainLabel.text=@"乐驾号即用户名，可以使用它进行登录。\n不能和其他人的乐驾号重复。";
    explainLabel.numberOfLines=0;
    explainLabel.textColor=COLOR_TEXT_SECONDARY;
    explainLabel.font=FONT_TEXT_SECONDARY;
    [Utility fitLabel:explainLabel];
    explainLabel.textAlignment=NSTextAlignmentLeft;
    explainLabel.top=_textField.bottom+3;
    explainLabel.left=_textField.left;
    
}

-(void)save{
    NSString* username=[Utility trim:_textField.text];
    if(username.length==0){
        [Utility showError:@"请输入用户名" type:ErrorType_Business];
        return;
    }
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote updatePersonUsername:username callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            Person* person=callback_data.data;
            [Storage setLoginInfo:person];
            [self gotoBackWithParamaters:@{
                                           PAGE_PARAM_PERSON:person,
                                           }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self save];
    return true;
}
@end