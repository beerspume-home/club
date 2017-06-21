//
//  ForgotPassowrdVC.m
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ForgotPassowrdVC.h"

@interface ForgotPassowrdVC (){
    UITextField* _phoneTextField;
    UITextField* _passwordTextField;
    UITextField* _smscodeTextField;
    UILabel* _sendSMSCodeLabel;
    UILabel* _regLabel;
    
    HeaderView* _header;
}
@end

@implementation ForgotPassowrdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    if(_header==nil){
        _header=[[HeaderView alloc]
                 initWithTitle:@"忘记密码"
                 leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                 rightButton:nil
                 backgroundColor:COLOR_HEADER_BG
                 titleColor:COLOR_HEADER_TEXT
                 height:HEIGHT_HEAD_DEFAULT
                 ];
        [self.view addSubview:_header];
    }
    
    //初始化手机号输入
    if(_phoneTextField==nil){
        _phoneTextField=[[UITextField alloc]init];
        _phoneTextField.borderStyle=UITextBorderStyleRoundedRect;
        _phoneTextField.placeholder=@"手机号码";
        _phoneTextField.textAlignment=NSTextAlignmentCenter;
        _phoneTextField.font=FONT_BUTTON;
        _phoneTextField.keyboardType=UIKeyboardTypePhonePad;
        [self.view addSubview:_phoneTextField];
    }
    _phoneTextField.size=CGSizeMake(_phoneTextField.superview.width-60.0, HEIGHT_BUTTON);
    _phoneTextField.top=100;
    _phoneTextField.centerX=_phoneTextField.superview.width/2;
    
    //重新设置密码输入
    if(_passwordTextField==nil){
        _passwordTextField=[[UITextField alloc]init];
        _passwordTextField.borderStyle=UITextBorderStyleRoundedRect;
        _passwordTextField.placeholder=@"新密码";
        _passwordTextField.textAlignment=NSTextAlignmentCenter;
        _passwordTextField.font=FONT_BUTTON;
        _passwordTextField.secureTextEntry=true;
        [self.view addSubview:_passwordTextField];
    }
    _passwordTextField.size=CGSizeMake(_phoneTextField.width, HEIGHT_BUTTON);
    _passwordTextField.top=_phoneTextField.bottom+10;
    _passwordTextField.centerX=_phoneTextField.centerX;
    
    //初始化验证码输入
    if(_smscodeTextField==nil){
        _smscodeTextField=[[UITextField alloc]init];
        _smscodeTextField.borderStyle=UITextBorderStyleRoundedRect;
        _smscodeTextField.placeholder=@"6位验证码";
        _smscodeTextField.textAlignment=NSTextAlignmentCenter;
        _smscodeTextField.font=FONT_BUTTON;
        _smscodeTextField.secureTextEntry=true;
        [self.view addSubview:_smscodeTextField];
    }
    _smscodeTextField.size=CGSizeMake(_passwordTextField.width/2, HEIGHT_BUTTON);
    _smscodeTextField.top=_passwordTextField.bottom+10;
    _smscodeTextField.left=_passwordTextField.left;
    
    //初始化发送验证码按钮
    if(_sendSMSCodeLabel==nil){
        _sendSMSCodeLabel=[[UILabel alloc]init];
        _sendSMSCodeLabel.backgroundColor=COLOR_BUTTON_BG;
        _sendSMSCodeLabel.textColor=COLOR_BUTTON_TEXT;
        _sendSMSCodeLabel.textAlignment=NSTextAlignmentCenter;
        _sendSMSCodeLabel.layer.masksToBounds=YES;
        _sendSMSCodeLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
        _sendSMSCodeLabel.text=@"发送验证码";
        _sendSMSCodeLabel.font=FONT_BUTTON;
        _sendSMSCodeLabel.userInteractionEnabled=true;
        [_sendSMSCodeLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doSendSMSCode)]];
        [self.view addSubview:_sendSMSCodeLabel];
    }
    _sendSMSCodeLabel.size=CGSizeMake(_passwordTextField.width/2-20, HEIGHT_BUTTON);
    _sendSMSCodeLabel.top=_smscodeTextField.top;
    _sendSMSCodeLabel.right=_passwordTextField.right;
    
    //初始化注册按钮
    if(_regLabel==nil){
        _regLabel=[[UILabel alloc]init];
        _regLabel.backgroundColor=COLOR_BUTTON_BG;
        _regLabel.textColor=COLOR_BUTTON_TEXT;
        _regLabel.textAlignment=NSTextAlignmentCenter;
        _regLabel.layer.masksToBounds=YES;
        _regLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
        _regLabel.text=@"设置新密码";
        _regLabel.font=FONT_BUTTON;
        _regLabel.userInteractionEnabled=true;
        [_regLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doResetPassword)]];
        [self.view addSubview:_regLabel];
    }
    _regLabel.size=CGSizeMake(_phoneTextField.width, HEIGHT_BUTTON);
    _regLabel.top=_smscodeTextField.bottom+15;
    _regLabel.centerX=_phoneTextField.centerX;
    
}

-(void)doSendSMSCode{
    if(!_sendSMSCodeLabel.enabled)return;
    _sendSMSCodeLabel.enabled=false;
    NSString* phone=_phoneTextField.text;
    [Remote sendSMSCodeWithPhone:phone callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Utility showMessage:@"请注意接收验证短信"];
            runInBackground(^{
                int totalSec=60;
                NSString* originText=_sendSMSCodeLabel.text;
                for(int i=0;i<totalSec;i++){
                    runInMain(^{
                        [_sendSMSCodeLabel setText:[NSString stringWithFormat:@"%d秒后重发",(totalSec-i)]];
                        if(_sendSMSCodeLabel.enabled){
                            [_sendSMSCodeLabel setEnabled:false];
                        }
                    });
                    [NSThread sleepForTimeInterval:1.0];
                }
                runInMain(^{
                    [_sendSMSCodeLabel setEnabled:true];
                    [_sendSMSCodeLabel setText:originText];
                });
            });
        }else{
            _sendSMSCodeLabel.enabled=true;
            [Utility showError:@"发送验证码失败" type:ErrorType_Network];
        }
    }];
}

-(void)doResetPassword{
    NSString* phone=_phoneTextField.text;
    NSString* smscode=_smscodeTextField.text;
    NSString* password=_passwordTextField.text;
    
    [Remote resetPasswordWithPhone:phone smscode:smscode password:password callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Utility showMessage:@"重设密码成功"];
            [self gotoBack];
        }else{
            [Utility showError:[NSString stringWithFormat:@"重设密码失败:%@",callback_data.message] type:ErrorType_Network];
        }
    }];
}

-(void)hiddenAll:(UIView *)v{
    if(![Utility isInputView:v]){
        [_phoneTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
        [_smscodeTextField resignFirstResponder];
    }
}

@end
