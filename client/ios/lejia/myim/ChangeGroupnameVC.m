//
//  ChangeGroupnameVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChangeGroupnameVC.h"

@interface ChangeGroupnameVC (){
    ChatGroup* _group;
    HeaderView* _header;
    
    UITextField* _textField;
}


@end

@implementation ChangeGroupnameVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}
-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"设置群组名称"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:[HeaderView genItemWithType:HeaderItemType_Save target:self action:@selector(save) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //群组名称输入框
    _textField=[[UITextField alloc]init];
    [self.view addSubview:_textField];
    _textField.borderStyle=UITextBorderStyleNone;
    _textField.placeholder=@"";
    _textField.textAlignment=NSTextAlignmentLeft;
    _textField.font=FONT_BUTTON;
    _textField.text=_group.name;
    _textField.keyboardType=UIKeyboardTypeDefault;
    _textField.size=CGSizeMake(_textField.superview.width-50, HEIGHT_BUTTON);
    _textField.top=_header.bottom+20;
    _textField.centerX=_textField.superview.width/2;
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
    explainLabel.text=@"起一个大家都喜欢的名字吧";
    explainLabel.textColor=COLOR_TEXT_SECONDARY;
    explainLabel.font=FONT_TEXT_SECONDARY;
    [Utility fitLabel:explainLabel];
    explainLabel.top=_textField.bottom+3;
    explainLabel.left=_textField.left;
    
}

-(void)save{
    NSString* groupname=_textField.text;
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote updateGroup:_group.id name:groupname callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            ChatGroup* group=callback_data.data;
            [self gotoBackWithParamaters:@{
                                           PAGE_PARAM_GROUP:group,
                                           }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_GROUP isEqualToString:key]){
        _group=value;
    }
}
@end