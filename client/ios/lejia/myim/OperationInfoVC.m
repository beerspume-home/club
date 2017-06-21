//
//  OperationInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationInfoVC.h"

@interface OperationInfoVC (){
    Person* _person;
    Operation* _character;
    School* _choicedSchool;
    NSArray<Dict*>* _skills;
    
    
    //驾校选择
    UIView* _choiceSchool;
}

@end

@implementation OperationInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshData];
}
-(void)refreshData{
    [UIUtility setFeatureItem:_choiceSchool text:(_choicedSchool==nil?@"点击选择驾校":_choicedSchool.name)];
    
}
-(void)reloadView{
    [super reloadView];
    
    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"运营信息"
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];
    
    
    //身份图标
    UIImageView* characterIconView=[[UIImageView alloc]init];
    [self.view addSubview:characterIconView];
    CGFloat iconWidth=characterIconView.superview.width/4;
    characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    characterIconView.top=headView.bottom+12;
    characterIconView.centerX=characterIconView.superview.width/2;
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_运营_男":@"character_icon_运营_女"];
    
    _choiceSchool=[UIUtility genFeatureItemInSuperView:self.view
                                                   top:characterIconView.bottom+12
                                                 title:@"驾校"
                                                height:FEATURE_NORMAL_HEIGHT
                                              rightObj:[UIUtility genFeatureItemRightLabel]
                                                target:self
                                                action:@selector(choiceSchool)
                                             showSplit:false
                   ];
    
    
    
    
    
    
}

-(void)choiceSchool{
    [self gotoPageWithClass:[SearchSchoolVC class] parameters:@{
                                                                PAGE_PARAM_BACK_CLASS:[self class],
                                                                }];
}

-(void)ok{
    if(_choicedSchool==nil){
        [Utility showError:@"请选择驾校" type:ErrorType_Business];
    }else{
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote createOperation:_person.id schoolid:_choicedSchool.id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Operation* obj=callback_data.data;
                [self gotoBackToViewController:[MyInfoVC class] paramaters:@{
                                                                             PAGE_PARAM_OPERATION:obj,
                                                                             }
                 ];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
    }
}


-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_PERSON isEqualToString:key]){
        _person=value;
    }else if([PAGE_PARAM_OPERATION isEqualToString:key]){
        _character=value;
    }else if([PAGE_PARAM_SCHOOL isEqualToString:key]){
        _choicedSchool=value;
    }else if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([value isKindOfClass:[NSDictionary class]]){
            //            if([@"service_name" isEqualToString:value[PAGE_PARAM_TYPE]]){
            //                _serviceName=value[PAGE_PARAM_RETURN_VALUE];
            //                [self refreshData];
            //            }
        }
    }
}
@end
