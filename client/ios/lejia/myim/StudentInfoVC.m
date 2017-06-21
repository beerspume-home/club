//
//  StudentInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "StudentInfoVC.h"

@interface StudentInfoVC (){
    Person* _person;

    School* _choicedSchool;

    
    //角色图标
    UIImageView* _characterIconView;
    
    UIScrollView* _scrollView;
    
    //驾校选择
    UIView* _choiceSchoolView;
    //学车阶段选择
    FeatureItem* _statusItem;
    //科目一考试成绩
    FeatureItem* _km1ScoreItem;
    //科目二考试成绩
    FeatureItem* _km2ScoreItem;
    //科目三考试成绩
    FeatureItem* _km3aScoreItem;
    //科目四考试成绩
    FeatureItem* _km3bScoreItem;
    //报名日期
    FeatureItem* _signupDateItem;
    //领证日期
    FeatureItem* _licenceDateItem;

    //学习阶段字典
//    NSArray<Dict*>* _statusDict;
}

@end

@implementation StudentInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self initDictData];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self refreshData];
}
-(void)refreshData{
    [UIUtility setFeatureItem:_choiceSchoolView text:(_choicedSchool==nil?@"点击选择驾校":_choicedSchool.name)];

    _characterIconView.top=12;
    _choiceSchoolView.top=_characterIconView.bottom+12;
    _statusItem.view.top=_choiceSchoolView.bottom;
    _signupDateItem.view.top=_statusItem.view.bottom;
    _km1ScoreItem.view.top=_signupDateItem.view.bottom;
    _km2ScoreItem.view.top=_km1ScoreItem.view.bottom;
    _km3aScoreItem.view.top=_km2ScoreItem.view.bottom;
    _km3bScoreItem.view.top=_km3aScoreItem.view.bottom;
    _licenceDateItem.view.top=_km3bScoreItem.view.bottom;
    
    
    _km1ScoreItem.view.hidden=true;
    _km2ScoreItem.view.hidden=true;
    _km3aScoreItem.view.hidden=true;
    _km3bScoreItem.view.hidden=true;
    _licenceDateItem.view.hidden=true;
    
    CGFloat scrollHeight=_licenceDateItem.view.bottom;
    if([Utility isEmptyString:_statusItem.rightValue] || [@"signup" isEqualToString:_statusItem.rightValue] || [@"km1" isEqualToString:_statusItem.rightValue]){
        // do nothing
        scrollHeight=_signupDateItem.view.bottom;
    }else if([@"km2" isEqualToString:_statusItem.rightValue]){
        _km1ScoreItem.view.hidden=false;
        scrollHeight=_km1ScoreItem.view.bottom;
    }else if([@"km3a" isEqualToString:_statusItem.rightValue]){
        _km1ScoreItem.view.hidden=false;
        _km2ScoreItem.view.hidden=false;
        scrollHeight=_km2ScoreItem.view.bottom;
    }else if([@"km3b" isEqualToString:_statusItem.rightValue]){
        _km1ScoreItem.view.hidden=false;
        _km2ScoreItem.view.hidden=false;
        _km3aScoreItem.view.hidden=false;
        scrollHeight=_km3aScoreItem.view.bottom;
    }else{
        _km1ScoreItem.view.hidden=false;
        _km2ScoreItem.view.hidden=false;
        _km3aScoreItem.view.hidden=false;
        _km3bScoreItem.view.hidden=false;
        _licenceDateItem.view.hidden=false;
        scrollHeight=_licenceDateItem.view.bottom;
    }
    
    _scrollView.contentSize=(CGSize){_scrollView.width,scrollHeight+12};
    
}

-(void)reloadView{
    [super reloadView];

    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"学员信息"
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];

    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=(CGPoint){0,headView.bottom};
    _scrollView.size=(CGSize){_scrollView.superview.width,_scrollView.superview.height-_scrollView.top};
    _scrollView.bounces=false;
    
    //身份图标
    _characterIconView=[[UIImageView alloc]init];
    [_scrollView addSubview:_characterIconView];
    CGFloat iconWidth=_characterIconView.superview.width/4;
    _characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    _characterIconView.top=0;
    _characterIconView.centerX=_characterIconView.superview.width/2;
    _characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_学员_男":@"character_icon_学员_女"];
    
    _choiceSchoolView=[UIUtility genFeatureItemInSuperView:_scrollView
                                                   top:0
                                                 title:@"驾校"
                                                height:FEATURE_NORMAL_HEIGHT
                                                  rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                target:self
                                                action:@selector(choiceSchool)
                                             showSplit:false
                   ];

    _statusItem=[[FeatureItem alloc]initSelectInSuperView:_scrollView
                                                     top:0
                                                   title:@"学习进度"
                                                   value:@""
                                                  height:FEATURE_NORMAL_HEIGHT
                                               showSplit:true
                                                    dict:DICT_STUDENT_STUDY_STATUS
                                             mutliSelect:false];
    
    _km1ScoreItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                       top:0
                                                     title:@"科目一成绩"
                                                     value:@""
                                                    height:FEATURE_NORMAL_HEIGHT
                                                 showSplit:true
                                                 inputType:CHANGEVALUE_INPUTTYPE_NumberPad];
    _km2ScoreItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                       top:0
                                                     title:@"科目二成绩"
                                                     value:@""
                                                    height:FEATURE_NORMAL_HEIGHT
                                                 showSplit:true
                                                 inputType:CHANGEVALUE_INPUTTYPE_NumberPad];
    _km3aScoreItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                       top:0
                                                     title:@"科目三成绩"
                                                     value:@""
                                                    height:FEATURE_NORMAL_HEIGHT
                                                 showSplit:true
                                                 inputType:CHANGEVALUE_INPUTTYPE_NumberPad];
    _km3bScoreItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                       top:0
                                                     title:@"科目四成绩"
                                                     value:@""
                                                    height:FEATURE_NORMAL_HEIGHT
                                                 showSplit:true
                                                 inputType:CHANGEVALUE_INPUTTYPE_NumberPad];
    
    _licenceDateItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                         top:0
                                                       title:@"领证日期"
                                                       value:@""
                                                      height:FEATURE_NORMAL_HEIGHT
                                                   showSplit:true
                                                   inputType:CHANGEVALUE_INPUTTYPE_Date];
    
    _signupDateItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                         top:0
                                                       title:@"报名日期"
                                                       value:@""
                                                      height:FEATURE_NORMAL_HEIGHT
                                                   showSplit:true
                                                   inputType:CHANGEVALUE_INPUTTYPE_Date];
}

-(void)choiceSchool{
    [self gotoPageWithClass:[SearchSchoolVC class] parameters:@{
                                                                PAGE_PARAM_BACK_CLASS:[self class],
                                                                }];
}


-(void)ok{
    BOOL complete=true;
    if(_choicedSchool==nil){
        [Utility showError:@"请选择驾校" type:ErrorType_Network];
        complete=false;
    }
    if([Utility isEmptyString:_statusItem.rightValue]){
        [Utility showError:@"学习进度" type:ErrorType_Network];
        complete=false;
    }
    if([Utility isEmptyString:_signupDateItem.rightValue]){
        [Utility showError:@"报名日期" type:ErrorType_Network];
        complete=false;
    }
    
    if (complete){
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote createStudent:_person.id  schoolid:_choicedSchool.id  status:_statusItem.rightValue signupdate:_signupDateItem.rightValue km1score:_km1ScoreItem.rightValue km2score:_km2ScoreItem.rightValue km3ascore:_km3aScoreItem.rightValue km3bscore:_km3bScoreItem.rightValue licencedate:_licenceDateItem.rightValue callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Student* obj=callback_data.data;
                [self gotoBackToViewController:[MyInfoVC class] paramaters:@{
                                                                             PAGE_PARAM_STUDENT:obj,
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
    }else if([PAGE_PARAM_SCHOOL isEqualToString:key]){
        _choicedSchool=value;
    }
}

//-(void)initDictData{
//    _statusDict=@[
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"signup",
//                                            @"desc":@"刚刚报名",
//                                            @"order":@"1",
//                                            }],
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"km1",
//                                            @"desc":@"理论学习(科目一)",
//                                            @"order":@"2",
//                                            }],
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"km2",
//                                            @"desc":@"场内驾驶(科目二)",
//                                            @"order":@"3",
//                                            }],
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"km3a",
//                                            @"desc":@"路考(科目三)",
//                                            @"order":@"4",
//                                            }],
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"km3b",
//                                            @"desc":@"安全文明驾驶常识(科目四)",
//                                            @"order":@"5",
//                                            }],
//                 [Dict initWithDictionary:@{
//                                            @"name":@"study_status",
//                                            @"value":@"done",
//                                            @"desc":@"已取得驾照",
//                                            @"order":@"6",
//                                            }],
//                 ];
//}

@end
