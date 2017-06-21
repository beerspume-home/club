//
//  FindFriendVC.m
//  myim
//
//  Created by Sean Shi on 15/10/20.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "FindFriendVC.h"

@interface FindFriendVC ()<UITextFieldDelegate>{
    //标题栏
    UIView* _headView;
    //查找按钮
    UIView* _findView;
    //查找输入框
    UITextField* _findField;
}

@end

@implementation FindFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    //初始化标题栏
    _headView=[[UIView alloc]init];
    [self.view addSubview:_headView];
    _headView.backgroundColor=COLOR_HEADER_BG;
    _headView.size=CGSizeMake(_headView.superview.width, HEIGHT_HEAD_DEFAULT);
    _headView.origin=CGPointMake(0, 0);
    //返回按钮
    UIView* backView=[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT];
    [_headView addSubview:backView];
    backView.tintColor=COLOR_HEADER_TEXT;
    backView.width=43;
    backView.centerY=(backView.superview.height-20)/2+20;
    backView.left=0;
    //搜索图标
    UIImageView* findIconView=[[UIImageView alloc]init];
    [_headView addSubview:findIconView];
    findIconView.image=[[UIImage imageNamed:@"搜索_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    findIconView.tintColor=COLOR_HEADER_TEXT;
    findIconView.size=CGSizeMake(16, 16);
    findIconView.left=backView.right;
    findIconView.centerY=(backView.superview.height-20)/2+20;
    //搜索输入框
    _findField=[[UITextField alloc]init];
    [_headView addSubview:_findField];
    _findField.textColor=COLOR_HEADER_TEXT;
    _findField.borderStyle=UITextBorderStyleNone;
    _findField.attributedPlaceholder=[[NSAttributedString alloc] initWithString:@"搜索" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    _findField.textAlignment=NSTextAlignmentLeft;
    _findField.font=FONT_BUTTON;
    _findField.keyboardType=UIKeyboardTypeDefault;
    _findField.size=CGSizeMake(_findField.superview.width-backView.right-12.4, HEIGHT_BUTTON);
    _findField.left=findIconView.right+5;
    _findField.centerY=findIconView.centerY;
    _findField.returnKeyType=UIReturnKeySearch;
    _findField.delegate=self;
    [_findField addTarget:self action:@selector(findFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_findField becomeFirstResponder];
    //输入框下划线
    UIView* underLine=[[UIView alloc]init];
    [_headView addSubview:underLine];
    underLine.size=CGSizeMake(_findField.width, 1);
    underLine.backgroundColor=[UIColor brownColor];
    underLine.top=underLine.superview.height-10;
    underLine.left=backView.right;
    
}

- (void) findFieldDidChange:(UITextField *) textField{
    [self showFindButtonWithText:textField.text];
}
-(void) showFindButtonWithText:(NSString*)text {
    if(_findView==nil){
        _findView=[[UIView alloc]init];
        [self.view addSubview:_findView];
        _findView.backgroundColor=COLOR_FEATURE_BAR_BG;
        _findView.size=CGSizeMake(_findView.superview.width, 57);
        _findView.top=_headView.bottom;
        _findView.left=0;
        //图标
        UIImageView* iconView=[[UIImageView alloc]init];
        [_findView addSubview:iconView];
        iconView.image=[UIImage imageNamed:@"查找_icon"];
        iconView.size=CGSizeMake(43,43);
        iconView.left=12;
        iconView.centerY=iconView.superview.height/2;
        //搜索标题
        UILabel* findLabel=[Utility genLabelWithText:@"搜索:"
                                             bgcolor:nil
                                           textcolor:COLOR_TEXT_NORMAL
                                                font:FONT_TEXT_NORMAL
                            ];
        [_findView addSubview:findLabel];
        findLabel.left=iconView.right+15;
        findLabel.centerY=iconView.superview.height/2;
        
        //搜索内容
        UILabel* findTextLabel=[Utility genLabelWithText:@"搜索:"
                                             bgcolor:nil
                                           textcolor:UIColorFromRGB(0x45c01a)
                                                font:FONT_TEXT_NORMAL
                            ];
        [_findView addSubview:findTextLabel];
        findTextLabel.textAlignment=NSTextAlignmentLeft;
        findTextLabel.width=findTextLabel.superview.width-findLabel.right-15;
        findTextLabel.left=findLabel.right+3;
        findTextLabel.centerY=findLabel.centerY;

        _findView.tagObject=findTextLabel;
        [_findView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doSearch:)]];
        _findView.hidden=true;
    }
    if(_findView.tagObject!=nil){
        UILabel* findTextLabel=(UILabel*)_findView.tagObject;
        findTextLabel.text=text;
    }
    
    if(text.length==0){
        _findView.hidden=true;
    }else{
        _findView.hidden=false;
    }
}

-(void)doSearch:(UIGestureRecognizer*)sender{
    [self hiddenAll:nil];
    if(_findView!=nil){
        UILabel* findTextLabel=_findView.tagObject;
        NSString* findkey=findTextLabel.text;
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote searchPersonWithUsername:findkey callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Person* foundPerson=callback_data.data;
                [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                          PAGE_PARAM_PERSON:foundPerson
                                                                          }];
                [loadingView removeFromSuperview];
            }else if(callback_data.code==2){
                NSInteger start=0;
                NSInteger offset=30;
                [Remote searchSchool:findkey fuzzy:true start:start offset:offset callback:^(StorageCallbackData *callback_data) {
                    if(callback_data.code==0){
                        
                        [self gotoPageWithClass:[SearchSchoolResultVC class]
                                     parameters:@{
                                                  PAGE_PARAM_SCHOOL_SET:callback_data.data,
                                                  PAGE_PARAM_START:[NSNumber numberWithInteger:start],
                                                  PAGE_PARAM_OFFSET:[NSNumber numberWithInteger:offset],
                                                  PAGE_PARAM_SEARCHKEY:findkey,
                                                  PAGE_PARAM_FORWARD_CLASS:[SchoolMPPageVC class],
                                                  }];

                    }else if(callback_data.code==2){
                        [Utility showError:callback_data.message type:ErrorType_Business];
                    }else{
                        [Utility showError:callback_data.message type:ErrorType_Network];
                    }
                    [loadingView removeFromSuperview];
                }];
//                [Utility showError:callback_data.message type:ErrorType_Business];
            }else{
                [loadingView removeFromSuperview];
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
        }];
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self doSearch:nil];
    return true;
}

-(void)hiddenAll:(UIView *)v{
    if(![Utility isInputView:v]){
        [_findField resignFirstResponder];
    }
}
@end
