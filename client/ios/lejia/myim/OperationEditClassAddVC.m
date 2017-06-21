//
//  OperationEditClassAddVC.m
//  myim
//
//  Created by Sean Shi on 15/11/16.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditClassAddVC.h"

@interface OperationEditClassAddVC (){
    UIScrollView* _scrollView;
    
    
    NSArray<Dict*>* _licensetypeDict;
    
    HeaderView* _headView;
    FeatureItem* _licenceItem;
    FeatureItem* _nameItem;
    FeatureItem* _cartypeItem;
    FeatureItem* _trainingtimeItem;
    FeatureItem* _feeItem;
    FeatureItem* _realfeeItem;
    FeatureItem* _expiredateItem;
    FeatureItem* _remarkItem;
}

@end

@implementation OperationEditClassAddVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initDictData];
    [self reloadView];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    _licenceItem.view.top=12;
    _nameItem.view.top=_licenceItem.view.bottom;
    _cartypeItem.view.top=_nameItem.view.bottom;
    _trainingtimeItem.view.top=_cartypeItem.view.bottom;
    _feeItem.view.top=_trainingtimeItem.view.bottom;
    _realfeeItem.view.top=_feeItem.view.bottom;
    _expiredateItem.view.top=_realfeeItem.view.bottom;
    _remarkItem.view.top=_expiredateItem.view.bottom;
    

}
-(void)reloadView{
    [super reloadView];

    _headView=[[HeaderView alloc]
               initWithTitle:@"驾校班级"
               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
               rightButton:[HeaderView genItemWithText:@"保存" target:self action:@selector(save:)]
               backgroundColor:COLOR_HEADER_BG
               titleColor:COLOR_HEADER_TEXT
               height:HEIGHT_HEAD_DEFAULT
               ];
    [self.view addSubview:_headView];
    
    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=(CGPoint) {0,_headView.bottom};
    _scrollView.size=(CGSize){_scrollView.superview.width,_scrollView.superview.height-_scrollView.top};
    
    
    _licenceItem=[[FeatureItem alloc]initSelectInSuperView:_scrollView
                                                                    top:0
                                                                  title:@"驾照类型"
                                                                  value:@""
                                                                 height:FEATURE_NORMAL_HEIGHT
                                                              showSplit:false
                                                                   dict:_licensetypeDict
                                                            mutliSelect:true];

    _nameItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                                top:0
                                                              title:@"课程名称"
                                                              value:@""
                                                             height:FEATURE_NORMAL_HEIGHT
                                                          showSplit:true
                                                          inputType:CHANGEVALUE_INPUTTYPE_Default];

    _cartypeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                      top:0
                                                    title:@"车型"
                                                    value:@""
                                                   height:FEATURE_NORMAL_HEIGHT
                                                showSplit:true
                                                inputType:CHANGEVALUE_INPUTTYPE_Default];

    _trainingtimeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                      top:0
                                                    title:@"训练时间"
                                                    value:@""
                                                   height:FEATURE_NORMAL_HEIGHT
                                                showSplit:true
                                                inputType:CHANGEVALUE_INPUTTYPE_Default];

    _feeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                           top:0
                                                         title:@"价格"
                                                         value:@""
                                                        height:FEATURE_NORMAL_HEIGHT
                                                     showSplit:true
                                                     inputType:CHANGEVALUE_INPUTTYPE_NumberPad];

    _realfeeItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                  top:0
                                                title:@"优惠后价格"
                                                value:@""
                                               height:FEATURE_NORMAL_HEIGHT
                                            showSplit:true
                                            inputType:CHANGEVALUE_INPUTTYPE_NumberPad];

    _expiredateItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                      top:0
                                                    title:@"到期日期"
                                                    value:@""
                                                   height:FEATURE_NORMAL_HEIGHT
                                                showSplit:true
                                                inputType:CHANGEVALUE_INPUTTYPE_Date];

    _remarkItem=[[FeatureItem alloc]initInputInSuperView:_scrollView
                                                         top:0
                                                       title:@"备注"
                                                       value:@""
                                                      height:FEATURE_NORMAL_HEIGHT
                                                   showSplit:true
                                                   inputType:CHANGEVALUE_INPUTTYPE_Default];
}

-(void)save:(UIGestureRecognizer*)sender{
    BOOL completed=true;
    if([Utility isEmptyString:_licenceItem.rightValue]){
        [Utility showError:@"请填写驾照类型" type:ErrorType_Network];
        completed=false;
    }
    if([Utility isEmptyString:_nameItem.rightValue]){
        [Utility showError:@"请填课程名称" type:ErrorType_Network];
        completed=false;
    }
    if([Utility isEmptyString:_cartypeItem.rightValue]){
        [Utility showError:@"请填写训练车型" type:ErrorType_Network];
        completed=false;
    }
    if([Utility isEmptyString:_trainingtimeItem.rightValue]){
        [Utility showError:@"请填写训练时间" type:ErrorType_Network];
        completed=false;
    }
    if([Utility isEmptyString:_feeItem.rightValue]){
        [Utility showError:@"请填写课程价格" type:ErrorType_Network];
        completed=false;
    }
    if([Utility isEmptyString:_expiredateItem.rightValue]){
        [Utility showError:@"请填写到期时间" type:ErrorType_Network];
        completed=false;
    }
    
    if(completed){
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote addSchoolClass:[Storage getOperation].id name:_nameItem.rightValue cartype:_cartypeItem.rightValue licensetype:_licenceItem.rightValue trainingtime:_trainingtimeItem.rightValue fee:_feeItem.rightValue realfee:_realfeeItem.rightValue expiredate:_expiredateItem.rightValue remark:_remarkItem.rightValue callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [Utility showMessage:@"新建班级已保存"];
                [self gotoBack];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [lv removeFromSuperview];
        }];
    }

}

-(void)initDictData{
    _licensetypeDict=@[
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"A1",
                                                  @"desc":@"A1-大型客车",
                                                  @"order":@"1",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"A2",
                                                  @"desc":@"A2-牵引车",
                                                  @"order":@"2",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"A3",
                                                  @"desc":@"A3-城市公交车",
                                                  @"order":@"3",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"B1",
                                                  @"desc":@"B1-中型客车",
                                                  @"order":@"4",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"B2",
                                                  @"desc":@"B2-大型货车",
                                                  @"order":@"5",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"C1",
                                                  @"desc":@"C1-小型汽车",
                                                  @"order":@"6",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"C2",
                                                  @"desc":@"C2-小型自动挡汽车",
                                                  @"order":@"7",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"C3",
                                                  @"desc":@"C3-低速载货汽车",
                                                  @"order":@"8",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"C4",
                                                  @"desc":@"C4-三轮汽车",
                                                  @"order":@"9",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"D",
                                                  @"desc":@"D-普通三轮摩托车",
                                                  @"order":@"10",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"E",
                                                  @"desc":@"E-普通二轮摩托车",
                                                  @"order":@"11",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"F",
                                                  @"desc":@"F-轻便摩托车",
                                                  @"order":@"12",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"M",
                                                  @"desc":@"M-轮式自行机械车",
                                                  @"order":@"13",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"N",
                                                  @"desc":@"N-无轨电车",
                                                  @"order":@"14",
                                                  }],
                       [Dict initWithDictionary:@{
                                                  @"name":@"licensetype",
                                                  @"value":@"P",
                                                  @"desc":@"P-有轨电车",
                                                  @"order":@"15",
                                                  }],
                       ];
    
}
@end
