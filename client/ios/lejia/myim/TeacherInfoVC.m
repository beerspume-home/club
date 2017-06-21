//
//  TeacheInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TeacherInfoVC.h"

@interface TeacherInfoVC (){
    Person* _person;
    Teacher* _teacher;
    School* _choicedSchool;
    NSArray<Dict*>* _skills;
    
    
    //驾校选择
    UIView* _choiceSchool;
    //教学技能
    UIView* _skillView;
}

@end

@implementation TeacherInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshData];
}
-(void)refreshData{
    [UIUtility setFeatureItem:_choiceSchool text:(_choicedSchool==nil?@"点击选择驾校":_choicedSchool.name)];
    NSString* skillText=@"点击选择";
    if(_skills!=nil && _skills.count>0){
        skillText=@"";
        for(int i=0;i<_skills.count;i++){
            skillText=[skillText stringByAppendingFormat:(i==0?@"%@":@",%@"),_skills[i].desc];
        }
    }
    [UIUtility setFeatureItem:_skillView text:skillText];
    
}
-(void)reloadView{
    [super reloadView];

    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"教练信息"
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
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_教练_男":@"character_icon_教练_女"];
    
    _choiceSchool=[UIUtility genFeatureItemInSuperView:self.view
                                                   top:characterIconView.bottom+12
                                                 title:@"驾校"
                                                height:FEATURE_NORMAL_HEIGHT
                                              rightObj:[UIUtility genFeatureItemRightLabel]
                                                target:self
                                                action:@selector(choiceSchool)
                                             showSplit:false
                          ];

    _skillView=[UIUtility genFeatureItemInSuperView:self.view
                                                   top:_choiceSchool.bottom
                                                 title:@"教学科目"
                                                height:FEATURE_NORMAL_HEIGHT
                                              rightObj:[UIUtility genFeatureItemRightLabel]
                                                target:self
                                                action:@selector(choiceSkill)
                                             showSplit:true
                   ];

}

-(void)choiceSchool{
    [self gotoPageWithClass:[SearchSchoolVC class] parameters:@{
                                                                PAGE_PARAM_BACK_CLASS:[self class],
                                                                }];
}
-(void)choiceSkill{
    [self gotoPageWithClass:[SelectDictDataVC class] parameters:@{
                                                                  PAGE_PARAM_TITLE:@"教学科目",
                                                                  PAGE_PARAM_DICTNAME:@"teacher_skill",
                                                                  PAGE_PARAM_TYPE:@"teacher_skill",
                                                                  PAGE_PARAM_ORIGIN_VALUE:_skills==nil?[Utility initArray:nil]:_skills,
                                                                  PAGE_PARAM_MUTILSELECT:@"1",
                                                                  }];
}

-(NSString*)skillToString:(nonnull NSArray<Dict*>*) skills{
    NSString* ret=@"";
    for(int i=0;i<skills.count;i++){
        ret=[ret stringByAppendingFormat:(i==0?@"%@":@",%@"),skills[i].id];
    }
    return ret;
}

-(void)ok{
    if(_choicedSchool==nil){
        [Utility showError:@"请选择驾校" type:ErrorType_Business];
    }else{
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote createTeacher:_person.id schoolid:_choicedSchool.id skills:[self skillToString:_skills] callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Teacher* teacher=callback_data.data;
                [self gotoBackToViewController:[MyInfoVC class] paramaters:@{
                                                                             PAGE_PARAM_TEACHER:teacher,
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
    }else if([PAGE_PARAM_TEACHER isEqualToString:key]){
        _teacher=value;
    }else if([PAGE_PARAM_SCHOOL isEqualToString:key]){
        _choicedSchool=value;
    }else if([PAGE_PARAM_RETURN_VALUE isEqualToString:key]){
        if([value isKindOfClass:[NSDictionary class]]){
            if([@"teacher_skill" isEqualToString:value[PAGE_PARAM_TYPE]]){
                _skills=value[PAGE_PARAM_RETURN_VALUE];
                [self refreshData];
            }
        }
    }
}
@end
