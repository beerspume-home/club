//
//  LoginVC.m
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC (){
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
    UILabel* _loginLabel;
    UILabel* _regLabel;
    UILabel* _forgotLabel;
}

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(getSystemVersion()>=7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

-(void) reloadView{
    //背景图片
    UIImageView* backgroundView=[[UIImageView alloc]init];
    [self.view addSubview:backgroundView];
    backgroundView.size=backgroundView.superview.size;
    backgroundView.origin=CGPointMake(0, 0);
    backgroundView.image=[UIImage imageNamed:@"登录背景"];
    
    //初始化Logo
    UIImageView* logoImageView=[[UIImageView alloc]init];
    logoImageView.image=[UIImage imageNamed:@"Logo"];
    [self.view addSubview:logoImageView];
    logoImageView.size=CGSizeMake(80, 80);
    logoImageView.top=72;
    logoImageView.centerX=logoImageView.superview.width/2;
    
    
    //初始化用户名输入
    if(_usernameTextField==nil){
        _usernameTextField=[[UITextField alloc]init];
        _usernameTextField.borderStyle=UITextBorderStyleNone;
        _usernameTextField.placeholder=@"手机号码/用户名/邮箱";
        _usernameTextField.textAlignment=NSTextAlignmentCenter;
        _usernameTextField.font=FONT_BUTTON;
        _usernameTextField.keyboardType=UIKeyboardTypeASCIICapable;
        _usernameTextField.backgroundColor=[UIColor whiteColor];
        _usernameTextField.spellCheckingType=UITextSpellCheckingTypeNo;
        _usernameTextField.autocapitalizationType=UITextAutocapitalizationTypeNone;
        [self.view addSubview:_usernameTextField];
    }
    _usernameTextField.size=CGSizeMake(_usernameTextField.superview.width, HEIGHT_BUTTON);
    _usernameTextField.top=logoImageView.bottom+41;
    _usernameTextField.centerX=_usernameTextField.superview.width/2;

    //初始化密码输入
    if(_passwordTextField==nil){
        _passwordTextField=[[UITextField alloc]init];
        _passwordTextField.borderStyle=UITextBorderStyleNone;
        _passwordTextField.placeholder=@"密码";
        _passwordTextField.textAlignment=NSTextAlignmentCenter;
        _passwordTextField.font=FONT_BUTTON;
        _passwordTextField.secureTextEntry=true;
        _passwordTextField.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:_passwordTextField];
    }
    _passwordTextField.size=CGSizeMake(_usernameTextField.width, HEIGHT_BUTTON);
    _passwordTextField.top=_usernameTextField.bottom+0.5;
    _passwordTextField.centerX=_usernameTextField.centerX;

    //初始化登录按钮
    if(_loginLabel==nil){
        _loginLabel=[[UILabel alloc]init];
        _loginLabel.backgroundColor=COLOR_BUTTON_BG;
        _loginLabel.textColor=COLOR_BUTTON_TEXT;
        _loginLabel.textAlignment=NSTextAlignmentCenter;
        _loginLabel.layer.masksToBounds=YES;
        _loginLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
        _loginLabel.text=@"登录";
        _loginLabel.font=FONT_BUTTON;
        _loginLabel.userInteractionEnabled=true;
        [_loginLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doLogin)]];
        [self.view addSubview:_loginLabel];
    }
    _loginLabel.size=CGSizeMake(_loginLabel.superview.width-30, HEIGHT_BUTTON);
    _loginLabel.top=_passwordTextField.bottom+15;
    _loginLabel.centerX=_usernameTextField.centerX;
    
    //初始化忘记密码按钮
    if(_forgotLabel==nil){
        _forgotLabel=[[UILabel alloc]init];
        _forgotLabel.backgroundColor=[UIColor clearColor];
        _forgotLabel.textColor=COLOR_TEXT_LINK;
        _forgotLabel.text=@"忘记密码";
        _forgotLabel.font=FONT_TEXT_NORMAL;
        _forgotLabel.userInteractionEnabled=true;
        [_forgotLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doForgot)]];
        [self.view addSubview:_forgotLabel];
    }
    [Utility fitLabel:_forgotLabel];
    _forgotLabel.width=_loginLabel.width/3;
    _forgotLabel.height=_forgotLabel.height*2;
    _forgotLabel.textAlignment=NSTextAlignmentLeft;
    _forgotLabel.top=_loginLabel.bottom+5;
    _forgotLabel.left=_loginLabel.left;

    
    //初始化注册按钮
    if(_regLabel==nil){
        _regLabel=[[UILabel alloc]init];
        _regLabel.backgroundColor=[UIColor clearColor];
        _regLabel.textColor=COLOR_TEXT_LINK;
        _regLabel.text=@"注册";
        _regLabel.font=FONT_TEXT_NORMAL;
        _regLabel.userInteractionEnabled=true;
        [_regLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doReg)]];
        [self.view addSubview:_regLabel];
    }
    [Utility fitLabel:_regLabel];
    _regLabel.width=_loginLabel.width/3;
    _regLabel.height=_regLabel.height*2;
    _regLabel.textAlignment=NSTextAlignmentRight;
    _regLabel.top=_loginLabel.bottom+5;
    _regLabel.right=_loginLabel.right;
    
}

-(void)hiddenAll:(UIView *)v{
    if(![Utility isInputView:v]){
        [_usernameTextField resignFirstResponder];
        [_passwordTextField resignFirstResponder];
        
    }
}

//登录
-(void)doLogin{
    NSString* username=_usernameTextField.text;
    NSString* password=_passwordTextField.text;
    
    if(username==nil || username.length==0){
        [Utility showMessage:@"请输入用户名"];
        return;
    }
    if(password==nil || password.length==0){
        [Utility showMessage:@"请输入密码"];
        return;
    }
    
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote loginWithUsername:username password:password
    callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            Person* person=callback_data.data;
            [Remote headImageWithURL:person.imageurl callback:^(StorageCallbackData *callback_data) {
                if(callback_data.code==0){
                    UIImage* headImage=(UIImage*)callback_data.data;
                    [Storage setLoginInfo:person];
                    [Storage setUserImage:headImage];
                    [Storage updateCharacter];
                    [Utility connectRongCloud];
                    [self gotoPageWithClass:[MainVC class]];
                }else{
                    [Utility showError:callback_data.message type:ErrorType_Network];
                }
                [loadingView removeFromSuperview];
            }];
        }else{
            [loadingView removeFromSuperview];
            [Utility showError:@"登录失败" type:ErrorType_Network];
        }
    }];
}

//转向忘记密码页面
-(void)doForgot{
    [self gotoPageWithClass:[ForgotPassowrdVC class]];
}

//转向注册页面
-(void)doReg{
    [self gotoPageWithClass:[RegVC class]];
}

@end
