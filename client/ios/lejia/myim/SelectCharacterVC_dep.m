//
//  SelectCharacterVC_dep.m
//  myim
//
//  Created by Sean Shi on 15/10/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SelectCharacterVC_dep.h"

@interface SelectCharacterVC_dep (){
    Person* _person;
    NSArray* _characters;
    
    NSString* _selectedCharacterid;
}


@end

@implementation SelectCharacterVC_dep

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    
    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"所有身份信息"
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:[HeaderView genItemWithType:HeaderItemType_New target:self action:@selector(createNew) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];
    
    
    
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.origin=CGPointMake(0, headView.bottom+12);
    scrollView.size=CGSizeMake(scrollView.superview.width, scrollView.superview.height-scrollView.top);
    scrollView.bounces=false;
    
    CGFloat y=0;
    for(int i=0;i<_characters.count;i++){
        id character=_characters[i];
        BOOL selected=false;
        if([character isKindOfClass:[Student class]]){
            selected=[_selectedCharacterid isEqualToString:((Student*)character).id];
        }else if([character isKindOfClass:[Teacher class]]){
            selected=[_selectedCharacterid isEqualToString:((Teacher*)character).id];
        }else if([character isKindOfClass:[CustomerService class]]){
            selected=[_selectedCharacterid isEqualToString:((CustomerService*)character).id];
        }else if([character isKindOfClass:[Operation class]]){
            selected=[_selectedCharacterid isEqualToString:((Operation*)character).id];
        }

        UIView* characterView=nil;
        if([character isKindOfClass:[Student class]]){
            characterView=[self genStudent:(Student *)character InSuperview:scrollView top:y selected:selected];
        }else if([character isKindOfClass:[Teacher class]]){
            characterView=[self genTeacher:(Teacher *)character InSuperview:scrollView top:y selected:selected];
        }else if([character isKindOfClass:[CustomerService class]]){
            characterView=[self genCustomerService:(CustomerService *)character InSuperview:scrollView top:y selected:selected];
        }else if([character isKindOfClass:[Operation class]]){
            characterView=[self genOperation:(Operation *)character InSuperview:scrollView top:y selected:selected];
        }
        
        
        if(characterView!=nil){
            y=characterView.bottom+12;
        }
    }
    scrollView.contentSize=CGSizeMake(scrollView.width, y);
}



-(UIView*)genStudent:(Student*)obj InSuperview:(UIView*)superview top:(CGFloat)top selected:(BOOL)selected{
    
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.origin=(CGPoint){0,top};
    ret.width=ret.superview.width;
    
    //身份
    UILabel* certifyLabel=[UIUtility genCertifiedLabel:[obj isCertified]];
    UIView* characterView=[UIUtility genFeatureItemInSuperView:ret
                                                           top:0
                                                         title:@""
                                                        height:FEATURE_NORMAL_HEIGHT
                                                      rightObj:certifyLabel
                                                        target:self
                                                        action:@selector(didSelectedCharacter:)
                                                     showSplit:false];
    ((UIView*)(characterView.tagObject[@"rightObj"])).tagObject=obj;
    //身份图标
    UIImageView* characterIconView=[[UIImageView alloc]init];
    [characterView addSubview:characterIconView];
    CGFloat iconWidth=characterIconView.superview.height*0.6;
    characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    characterIconView.left=15;
    characterIconView.centerY=characterIconView.superview.height/2;
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_学员_男":@"character_icon_学员_女"];
    //身份名称
    UILabel* characterNameLabel=[Utility genLabelWithText:@"学员" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [characterView addSubview:characterNameLabel];
    characterNameLabel.left=characterIconView.right+5;
    characterNameLabel.centerY=characterIconView.centerY;
    
    
    UIView* schoolView=[UIUtility genFeatureItemInSuperView:ret
                                                        top:characterView.bottom
                                                      title:obj.school.name
                                                     height:FEATURE_NORMAL_HEIGHT
                                                   rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                     target:self
                                                     action:@selector(didSelectedCharacter:)
                                                  showSplit:true];
    [UIUtility setFeatureItem:schoolView text:obj.school.area.namepath];
    ((UIView*)(schoolView.tagObject[@"rightObj"])).tagObject=obj;
    
    FeatureItem* statusItem=[[FeatureItem alloc]initSelectInSuperView:ret
                                                                  top:schoolView.bottom
                                                                title:@"学习状态"
                                                                value:obj.status
                                                               height:FEATURE_NORMAL_HEIGHT
                                                               target:self
                                                               action:@selector(didSelectedCharacter:)
                                                            showSplit:true
                                                                 dict:DICT_STUDENT_STUDY_STATUS
                                                          mutliSelect:false];
    statusItem.view.tagObject=@{
                                @"rightObj":[[UILabel alloc]init],
                                };
    ((UIView*)(statusItem.view.tagObject[@"rightObj"])).tagObject=obj;
    
    [ret fitHeightOfSubviews];
    if(selected){
        [self selectThisItem:ret];
    }
    return ret;
}



-(UIView*)genTeacher:(Teacher*)obj InSuperview:(UIView*)superview top:(CGFloat)top selected:(BOOL)selected{
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.origin=(CGPoint){0,top};
    ret.width=ret.superview.width;
    
    //身份
    UILabel* certifyLabel=[UIUtility genCertifiedLabel:[obj isCertified]];
    UIView* characterView=[UIUtility genFeatureItemInSuperView:ret
                                                         top:0
                                                       title:@""
                                                      height:FEATURE_NORMAL_HEIGHT
                                                    rightObj:certifyLabel
                                                      target:self
                                                      action:@selector(didSelectedCharacter:)
                                                   showSplit:false];
    ((UIView*)(characterView.tagObject[@"rightObj"])).tagObject=obj;
    //身份图标
    UIImageView* characterIconView=[[UIImageView alloc]init];
    [characterView addSubview:characterIconView];
    CGFloat iconWidth=characterIconView.superview.height*0.6;
    characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    characterIconView.left=15;
    characterIconView.centerY=characterIconView.superview.height/2;
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_教练_男":@"character_icon_教练_女"];
    //身份名称
    UILabel* characterNameLabel=[Utility genLabelWithText:@"教练" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [characterView addSubview:characterNameLabel];
    characterNameLabel.left=characterIconView.right+5;
    characterNameLabel.centerY=characterIconView.centerY;
    
    UIView* schoolView=[UIUtility genFeatureItemInSuperView:ret
                                                        top:characterView.bottom
                                                      title:obj.school.name
                                                     height:FEATURE_NORMAL_HEIGHT
                                                   rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                     target:self
                                                     action:@selector(didSelectedCharacter:)
                                                  showSplit:true];
    [UIUtility setFeatureItem:schoolView text:obj.school.area.namepath];
    ((UIView*)(schoolView.tagObject[@"rightObj"])).tagObject=obj;
    
    UIView* skillView=[UIUtility genFeatureItemInSuperView:ret
                                                       top:schoolView.bottom
                                                     title:@"教学科目"
                                                    height:FEATURE_NORMAL_HEIGHT
                                                  rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                    target:self
                                                    action:@selector(didSelectedCharacter:)
                                                 showSplit:true];
    
    NSArray<Dict*>* skill=obj.skill;
    if(skill!=nil && skill.count>0){
        NSString* skillText=@"";
        for(int i=0;i<skill.count;i++){
            skillText=[skillText stringByAppendingFormat:(i==0?@"%@":@",%@"),skill[i].desc];
        }
        [UIUtility setFeatureItem:skillView text:skillText];
    }
    ((UIView*)(skillView.tagObject[@"rightObj"])).tagObject=obj;
    
    
    [ret fitHeightOfSubviews];
    if(selected){
        [self selectThisItem:ret];
    }
    return ret;
}


-(UIView*)genCustomerService:(CustomerService*)obj InSuperview:(UIView*)superview top:(CGFloat)top selected:(BOOL)selected{

    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.origin=(CGPoint){0,top};
    ret.width=ret.superview.width;
    
    //身份
    UILabel* certifyLabel=[UIUtility genCertifiedLabel:[obj isCertified]];
    UIView* characterView=[UIUtility genFeatureItemInSuperView:ret
                                                           top:0
                                                         title:@""
                                                        height:FEATURE_NORMAL_HEIGHT
                                                      rightObj:certifyLabel
                                                        target:self
                                                        action:@selector(didSelectedCharacter:)
                                                     showSplit:false];
    ((UIView*)(characterView.tagObject[@"rightObj"])).tagObject=obj;
    //身份图标
    UIImageView* characterIconView=[[UIImageView alloc]init];
    [characterView addSubview:characterIconView];
    CGFloat iconWidth=characterIconView.superview.height*0.6;
    characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    characterIconView.left=15;
    characterIconView.centerY=characterIconView.superview.height/2;
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_客服_男":@"character_icon_客服_女"];
    //身份名称
    UILabel* characterNameLabel=[Utility genLabelWithText:@"客服" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [characterView addSubview:characterNameLabel];
    characterNameLabel.left=characterIconView.right+5;
    characterNameLabel.centerY=characterIconView.centerY;
    
    UIView* schoolView=[UIUtility genFeatureItemInSuperView:ret
                                                        top:characterView.bottom
                                                      title:obj.school.name
                                                     height:FEATURE_NORMAL_HEIGHT
                                                   rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                     target:self
                                                     action:@selector(didSelectedCharacter:)
                                                  showSplit:true];
    [UIUtility setFeatureItem:schoolView text:obj.school.area.namepath];
    ((UIView*)(schoolView.tagObject[@"rightObj"])).tagObject=obj;


    [ret fitHeightOfSubviews];
    if(selected){
        [self selectThisItem:ret];
    }
    return ret;
}

-(UIView*)genOperation:(Operation*)obj InSuperview:(UIView*)superview top:(CGFloat)top selected:(BOOL)selected{
    
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.origin=(CGPoint){0,top};
    ret.width=ret.superview.width;
    
    //身份
    UILabel* certifyLabel=[UIUtility genCertifiedLabel:[obj isCertified]];
    UIView* characterView=[UIUtility genFeatureItemInSuperView:ret
                                                           top:0
                                                         title:@""
                                                        height:FEATURE_NORMAL_HEIGHT
                                                      rightObj:certifyLabel
                                                        target:self
                                                        action:@selector(didSelectedCharacter:)
                                                     showSplit:false];
    ((UIView*)(characterView.tagObject[@"rightObj"])).tagObject=obj;
    //身份图标
    UIImageView* characterIconView=[[UIImageView alloc]init];
    [characterView addSubview:characterIconView];
    CGFloat iconWidth=characterIconView.superview.height*0.6;
    characterIconView.size=CGSizeMake(iconWidth,iconWidth);
    characterIconView.left=15;
    characterIconView.centerY=characterIconView.superview.height/2;
    characterIconView.image=[UIImage imageNamed:[_person isMale]?@"character_icon_运营_男":@"character_icon_运营_女"];
    //身份名称
    UILabel* characterNameLabel=[Utility genLabelWithText:@"运营" bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_NORMAL];
    [characterView addSubview:characterNameLabel];
    characterNameLabel.left=characterIconView.right+5;
    characterNameLabel.centerY=characterIconView.centerY;
    
    
    UIView* schoolView=[UIUtility genFeatureItemInSuperView:ret
                                                        top:characterView.bottom
                                                      title:obj.school.name
                                                     height:FEATURE_NORMAL_HEIGHT
                                                   rightObj:[UIUtility genFeatureItemRightLabel:NSTextAlignmentRight]
                                                     target:self
                                                     action:@selector(didSelectedCharacter:)
                                                  showSplit:true];
    [UIUtility setFeatureItem:schoolView text:obj.school.area.namepath];
    ((UIView*)(schoolView.tagObject[@"rightObj"])).tagObject=obj;
    
    
    [ret fitHeightOfSubviews];
    if(selected){
        [self selectThisItem:ret];
    }
    return ret;
}


-(void)didSelectedCharacter:(UIGestureRecognizer*)sender{
    id character=((UIView*)(sender.view.tagObject[@"rightObj"])).tagObject;
    NSMutableDictionary* param=[Utility initDictionary:nil];
    if([character isKindOfClass:[Student class]]){
        [param setObject:character forKey:PAGE_PARAM_STUDENT];
    }else if([character isKindOfClass:[Teacher class]]){
        [param setObject:character forKey:PAGE_PARAM_TEACHER];
    }else if([character isKindOfClass:[CustomerService class]]){
        [param setObject:character forKey:PAGE_PARAM_CUSTOMERSERVICE];
    }else if([character isKindOfClass:[Operation class]]){
        [param setObject:character forKey:PAGE_PARAM_OPERATION];
    }
    
    [self gotoBackToViewController:[MyInfoVC class] paramaters:param];
}
-(void)createNew{
    [self gotoPageWithClass:[ChangeCharacterVC class] parameters:@{
                                                                   PAGE_PARAM_PERSON:_person,
                                                                   }];
    
}

-(void)selectThisItem:(UIView*)v{
    for(UIView* vv in v.subviews){
        vv.backgroundColor=COLOR_TEXT_HIGHLIGHT_LIGHT;
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_PERSON isEqualToString:key]){
        _person=value;
    }else if([PAGE_PARAM_CHARACTER_SET isEqualToString:key]){
        _characters=value;
    }else if([PAGE_PARAM_CHARACTER_ID isEqualToString:key]){
        _selectedCharacterid=value;
    }
}
@end
