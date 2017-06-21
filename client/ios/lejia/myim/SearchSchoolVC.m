//
//  SelectSchoolVC.m
//  myim
//
//  Created by Sean Shi on 15/10/20.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SearchSchoolVC.h"

@interface SearchSchoolVC ()<UITextFieldDelegate>{
    //标题栏
    UIView* _headView;
    //查找按钮
    UIView* _findView;
    UITextField* findField;
    //自定义驾校
    UIView* _customView;
    //自定义驾校名称
    UIView* _customSchoolNameView;
    //自定义驾校地区
    UIView* _customSchoolAreaView;
    
    
    NSString* _searchkey;
    NSString* _customSchoolName;
    Area* _customSchoolArea;

    Class _backClass;

}

@end

@implementation SearchSchoolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
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
    findField=[[UITextField alloc]init];
    [_headView addSubview:findField];
    findField.textColor=COLOR_HEADER_TEXT;
    findField.borderStyle=UITextBorderStyleNone;
    findField.attributedPlaceholder=[[NSAttributedString alloc] initWithString:@"搜索驾校" attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}];
    findField.textAlignment=NSTextAlignmentLeft;
    findField.font=FONT_BUTTON;
    findField.keyboardType=UIKeyboardTypeDefault;
    findField.size=CGSizeMake(findField.superview.width-backView.right-12.4, HEIGHT_BUTTON);
    findField.left=findIconView.right+5;
    findField.centerY=findIconView.centerY;
    findField.returnKeyType=UIReturnKeySearch;
    findField.delegate=self;
    [findField addTarget:self action:@selector(findFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [findField becomeFirstResponder];
    //输入框下划线
    UIView* underLine=[[UIView alloc]init];
    [_headView addSubview:underLine];
    underLine.size=CGSizeMake(findField.width, 1);
    underLine.backgroundColor=[UIColor brownColor];
    underLine.top=underLine.superview.height-10;
    underLine.left=backView.right;
    
}

-(void)refreshCustomData{
    [UIUtility setFeatureItem:_customSchoolNameView text:(_customSchoolName==nil?@"点击输入驾校全称":_customSchoolName)];
    [UIUtility setFeatureItem:_customSchoolAreaView text:(_customSchoolArea==nil?@"点击选择地区":_customSchoolArea.namepath)];
}
-(void)showCustomSchool{
    _customSchoolName=_searchkey;
    if(_customView==nil){
        _customView=[[UIView alloc]init];
        [self.view addSubview:_customView];
        _customView.size=CGSizeMake(_customView.superview.width, 60);
        _customView.origin=CGPointMake(0, _findView.bottom+12);
        _customView.backgroundColor=[UIColor clearColor];
        
        
        //个人信息保密生命
        UILabel* infoExplain=[Utility genLabelWithText:@"没有找到你的驾校么？自己创建一个吧！"
                                               bgcolor:nil
                                             textcolor:UIColorFromRGB(0x454545)
                                                  font:FONT_TEXT_SECONDARY
                              ];
        [_customView addSubview:infoExplain];
        infoExplain.top=0;
        infoExplain.left=12;
        
        //驾校全称
        _customSchoolNameView=[UIUtility genFeatureItemInSuperView:_customView
                                                            top:infoExplain.bottom+2
                                                          title:@"驾校全称"
                                                         height:FEATURE_NORMAL_HEIGHT
                                                       rightObj:[UIUtility genFeatureItemRightLabel]
                                                         target:self
                                                         action:@selector(changeSchoolName)
                                                      showSplit:false
                            ];
        
        //驾校所属地区
        _customSchoolAreaView=[UIUtility genFeatureItemInSuperView:_customView
                                                               top:_customSchoolNameView.bottom
                                                             title:@"驾校所在地区"
                                                            height:FEATURE_NORMAL_HEIGHT
                                                          rightObj:[UIUtility genFeatureItemRightLabel]
                                                            target:self
                                                            action:@selector(changeSchoolArea)
                                                         showSplit:true
                               ];
        
        UILabel* createSchoolLabel=[UIUtility genButtonToSuperview:_customView
                                                               top:_customSchoolAreaView.bottom+5
                                                             title:@"创建驾校"
                                                            target:self
                                                            action:@selector(createSchool)
                                    ];
        
        _customView.height=createSchoolLabel.bottom;
        
    }
    _customView.hidden=false;
    [self refreshCustomData];
}

- (void) findFieldDidChange:(UITextField *) textField{
    [self showFindButtonWithText:textField.text];
}
-(void) showFindButtonWithText:(NSString*)text {
    _searchkey=text;
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
    if(_findView!=nil){
        NSInteger start=0;
        NSInteger offset=30;
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote searchSchool:_searchkey fuzzy:false  start:start offset:offset callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSArray<School*>* result=callback_data.data;
                [self gotoPageWithClass:[SearchSchoolResultVC class]
                             parameters:@{
                                          PAGE_PARAM_SCHOOL_SET:result,
                                          PAGE_PARAM_START:[NSNumber numberWithInteger:start],
                                          PAGE_PARAM_OFFSET:[NSNumber numberWithInteger:offset],
                                          PAGE_PARAM_SEARCHKEY:_searchkey,
                                          PAGE_PARAM_BACK_CLASS:_backClass,
                                          }];
                
            }else if(callback_data.code==2){
                [Utility showError:callback_data.message type:ErrorType_Business];
                [self showCustomSchool];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
        
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self doSearch:nil];
    return true;
}

-(void)changeSchoolName{
    [self gotoPageWithClass:[ChangeValueVC class]
                 parameters:@{
                              PAGE_PARAM_TITLE:@"输入驾校全称",
                              PAGE_PARAM_EXPLAIN:@"",
                              PAGE_PARAM_PLACEHOLDER:@"",
                              PAGE_PARAM_ORIGIN_VALUE:_customSchoolName,
                              PAGE_PARAM_TYPE:@"schollName",
                              }];
}
-(void)changeSchoolArea{
    [self gotoPageWithClass:[SelectAreaVC class]];
    
}

-(void)createSchool{
    _customSchoolName=[Utility trim:_customSchoolName];
    if(_customSchoolName.length==0){
        [Utility showError:@"请输入驾校全称" type:ErrorType_Business];
        return;
    }
    if(_customSchoolArea==nil){
        [Utility showError:@"请选择所在地区" type:ErrorType_Business];
        return;
    }
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote createSchool:_customSchoolName areaid:_customSchoolArea.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            School* school=callback_data.data;
            [self gotoBackWithParamaters:@{
                                           PAGE_PARAM_SCHOOL:school,
                                           }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([value isKindOfClass:[NSDictionary class]]){
            if([@"schollName" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _customSchoolName=value[PAGE_PARAM_RETURN_VALUE];
                [self refreshCustomData];
            }
        }
    }else if([PAGE_PARAM_AREA isEqualToString:key]){
        _customSchoolArea=value;
        [self refreshCustomData];
    }else if([PAGE_PARAM_BACK_CLASS isEqualToString:key]){
        _backClass=value;
    }
}

-(void)hiddenAll:(UIView *)v{
    if(![Utility isInputView:v]){
        [findField resignFirstResponder];
    }
}
@end
