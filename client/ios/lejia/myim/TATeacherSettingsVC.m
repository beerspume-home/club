//
//  TATeacherSettingsVC.m
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherSettingsVC.h"

@interface TATeacherSettingsVC ()<FeatureItemDelegate>{
    HeaderView* _headView;
    UIScrollView* _scrollView;
    
    FeatureItem* _itemAllowStudentAppointment;
    UILabel* _explainLabelAllowStudentAppointment;

    FeatureItem* _itemDefaultStudentNum;
    UILabel* _explainLabelDefaultStudentNum;
}

@end

@implementation TATeacherSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _itemAllowStudentAppointment.view.top=12;
    _explainLabelAllowStudentAppointment.top=_itemAllowStudentAppointment.view.bottom+2;
    _explainLabelAllowStudentAppointment.left=15;
    
    _itemDefaultStudentNum.view.top=_explainLabelAllowStudentAppointment.bottom+12;
    _explainLabelDefaultStudentNum.top=_itemDefaultStudentNum.view.bottom+2;
    _explainLabelDefaultStudentNum.left=_explainLabelAllowStudentAppointment.left;
}

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc] initWithTitle:@"约车设置"
                                     leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                    rightButton:nil];
    [self.view addSubview:_headView];
    
    _scrollView=[[UIScrollView alloc]init];
    [_scrollView fillSuperview:self.view underOf:_headView];
    
    _itemAllowStudentAppointment=
    [[FeatureItem alloc]initSwitchInSuperView:_scrollView
                                          top:0
                                        title:@"是否允许学员约车"
                                        value:true
                                       height:FEATURE_NORMAL_HEIGHT
                                    showSplit:false];
    _itemAllowStudentAppointment.delegate=self;
    
    _explainLabelAllowStudentAppointment=[Utility genLabelWithText:@"如果不允许学员约车则学员将不能看到教练课表。\n教练可以主动向学员发起约车。"
                                                                            bgcolor:nil
                                                                          textcolor:UIColorFromRGB(0x454545)
                                                              font:FONT_TEXT_SECONDARY];
    [_scrollView addSubview:_explainLabelAllowStudentAppointment];
    [_explainLabelAllowStudentAppointment fitWithWidth:_explainLabelAllowStudentAppointment.superview.width-30];

    
    
    _itemDefaultStudentNum=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                                top:0
                                                              title:@"同一时间最多几人学车"
                                                              value:@"1"
                                                             height:FEATURE_NORMAL_HEIGHT
                                                          showSplit:false
                                                          inputType:CHANGEVALUE_INPUTTYPE_DecimalPad];
    _itemDefaultStudentNum.delegate=self;

    _explainLabelDefaultStudentNum=[Utility genLabelWithText:@"用于在课表中创建课时时，需要指定同一时间最多几人学车。这里的设置用于给定一个默认值。"
                                                           bgcolor:nil
                                                         textcolor:UIColorFromRGB(0x454545)
                                                              font:FONT_TEXT_SECONDARY];
    
    [_scrollView addSubview:_explainLabelDefaultStudentNum];
    [_explainLabelDefaultStudentNum fitWithWidth:_explainLabelDefaultStudentNum.superview.width-30];
    
    [_scrollView fitContentHeightWithPadding:12];

}


-(void)featureItem:(FeatureItem *)featureItem didValueChange:(NSString *)value{
    if(featureItem==_itemAllowStudentAppointment){
        debugLog(@"%@",[@"1" isEqualToString:value]?@"允许学员约车":@"禁止学员约车");
    }
}
@end
