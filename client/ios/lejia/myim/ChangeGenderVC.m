//
//  ChangeUsernameVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChangeGenderVC.h"


@interface ChangeGenderVC (){
    Person* _person;
    HeaderView* _header;
    NSString* _gender;
    
    UIView* _maleView;
    UIView* _femaleView;
}


@end

@implementation ChangeGenderVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _person=[Storage getLoginInfo];
    _gender=_person.gender;
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self updateViewWhenChangeGender];
}
-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@"更改性别"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil //[HeaderView genItemWithType:HeaderItemType_Save target:self action:@selector(save) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //选择项-男
    UIImageView* maleSelectIcon=[[UIImageView alloc]init];
    maleSelectIcon.size=CGSizeMake(20, 20);
    _maleView=[UIUtility genFeatureItemInSuperView:self.view
                                          top:_header.bottom+12
                                        title:@"男"
                                       height:FEATURE_NORMAL_HEIGHT
                                     rightObj:maleSelectIcon
                                       target:self
                                       action:@selector(setMale)
                                    showSplit:false
                      ];
    
    //选择项-女
    UIImageView* femaleSelectIcon=[[UIImageView alloc]init];
    femaleSelectIcon.size=CGSizeMake(20, 20);
    _femaleView=[UIUtility genFeatureItemInSuperView:self.view
                                          top:_maleView.bottom
                                        title:@"女"
                                       height:FEATURE_NORMAL_HEIGHT
                                     rightObj:femaleSelectIcon
                                       target:self
                                       action:@selector(setFemale)
                                    showSplit:true
                      ];
    
}


-(void)updateViewWhenChangeGender{
    if(_maleView!=nil && _maleView.tagObject!=nil){
        if([Utility isMale:_gender]){
            [UIUtility setFeatureItem:_maleView image:[UIImage imageNamed:@"selectdict_选中圆点"]];
        }else{
            [UIUtility setFeatureItem:_maleView image:[UIImage imageNamed:@"selectdict_未选中圆点"]];
        }
    }
    if(_femaleView!=nil && _femaleView.tagObject!=nil){
        if([Utility isMale:_gender]){
            [UIUtility setFeatureItem:_femaleView image:[UIImage imageNamed:@"selectdict_未选中圆点"]];
        }else{
            [UIUtility setFeatureItem:_femaleView image:[UIImage imageNamed:@"selectdict_选中圆点"]];
        }
    }
    
}

-(void)setMale{
    [self setGender:@"1"];
}
-(void)setFemale{
    [self setGender:@"2"];
}

-(void)setGender:(NSString*)gender{
    _gender=gender;
    [self updateViewWhenChangeGender];
    runDelayInMain(^{
        [self save];
    }, 0.2);
    
}

-(void)save{
    _person.gender=_gender;
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote updatePerson:_person callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Storage setLoginInfo:_person];
            [self gotoBackWithParamaters:@{
                                           PAGE_PARAM_PERSON:_person,
                                           }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}
@end