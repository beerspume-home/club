//
//  ChangeChatacterVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChangeCharacterVC.h"

#define COLUMNS 2
#define ROWS    2
#define CELL_WIDTH (self.view.width/COLUMNS)
#define CELL_HEIGHT (CELL_WIDTH*1.2)


@interface ChangeCharacterVC (){
    Person* _person;
    
    UIView* _studentView;
    UIView* _teacherView;
    UIView* _customerServiceView;
    UIView* _operationServiceView;
}


@end

@implementation ChangeCharacterVC
- (void)viewDidLoad {
    [super viewDidLoad];
    _person=[Storage getLoginInfo];
    [self reloadView];
}

-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);
    
    //初始化标题栏
    UIView* header=[[HeaderView alloc]
             initWithTitle:@"选择身份"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil //[HeaderView genItemWithType:HeaderItemType_Save target:self action:@selector(save) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:header];
    
    UIView* gridView=[[UIView alloc]init];
    [self.view addSubview:gridView];
    gridView.backgroundColor=[UIColor whiteColor];
    gridView.origin=CGPointMake(0, header.bottom+12);
    gridView.size=CGSizeMake(gridView.superview.width, CELL_HEIGHT*ROWS);
    for(int i=1;i<COLUMNS;i++){
        UIView* splitView=[[UIView alloc]init];
        [gridView addSubview:splitView];
        splitView.backgroundColor=COLOR_SPLIT;
        splitView.size=CGSizeMake(0.5, CELL_HEIGHT*ROWS);
        splitView.origin=CGPointMake(i*CELL_WIDTH, 0);
    }
    for(int i=1;i<=ROWS;i++){
        UIView* splitView=[[UIView alloc]init];
        [gridView addSubview:splitView];
        splitView.backgroundColor=COLOR_SPLIT;
        splitView.size=CGSizeMake(self.view.width, 0.5);
        splitView.origin=CGPointMake(0,i*CELL_HEIGHT);
    }
    
    UIView* studentButton=[self genCellViewWithText:@"我在学车"
                                             icon:[UIImage imageNamed:[_person isMale]?@"character_icon_学员_男":@"character_icon_学员_女"]
                                           target:self
                                           action:@selector(choiceStudent)
                         ];
    [self putView:studentButton into:gridView onRow:0 andColumn:0];
    
    UIView* teacherButton=[self genCellViewWithText:@"我是教练"
                                             icon:[UIImage imageNamed:[_person isMale]?@"character_icon_教练_男":@"character_icon_教练_女"]
                                           target:self
                                           action:@selector(choiceTeacher)
                         ];
    [self putView:teacherButton into:gridView onRow:0 andColumn:1];
    
    UIView* customerServiceButton=[self genCellViewWithText:@"我是客服"
                                             icon:[UIImage imageNamed:[_person isMale]?@"character_icon_客服_男":@"character_icon_客服_女"]
                                           target:self
                                           action:@selector(choiceCustomerService)
                         ];
    [self putView:customerServiceButton into:gridView onRow:1 andColumn:0];
    
    UIView* operationButton=[self genCellViewWithText:@"我是运营"
                                             icon:[UIImage imageNamed:[_person isMale]?@"character_icon_运营_男":@"character_icon_运营_女"]
                                           target:self
                                           action:@selector(choiceOperation)
                         ];
    [self putView:operationButton into:gridView onRow:1 andColumn:1];

}

-(void)putView:(nonnull UIView*)v into:(nonnull UIView*)superview onRow:(NSUInteger)row andColumn:(NSUInteger)column{
    CGPoint centerPoint=CGPointMake(CELL_WIDTH*column+CELL_WIDTH/2, CELL_HEIGHT*row+CELL_HEIGHT/2);
    if(v.superview==nil || v.superview!=self.view){
        [v removeFromSuperview];
        [superview addSubview:v];
    }
    v.center=centerPoint;
}

-(UIView*)genCellViewWithText:(NSString*)text icon:(UIImage*)icon target:(id)target action:(SEL)action{
    UIView* ret=[[UIView alloc]init];
    ret.size=CGSizeMake(CELL_WIDTH-2,CELL_HEIGHT-2);
    
    UIImageView* iconView=[[UIImageView alloc]init];
    [ret addSubview:iconView];
    iconView.image=icon;
    CGFloat iconWidth=ret.width/2;
    iconView.size=CGSizeMake(iconWidth, iconWidth);
    
    UILabel* textLable=[[UILabel alloc]init];
    [ret addSubview:textLable];
    textLable.text=text;
    textLable.textColor=COLOR_HEADER_BG;
    textLable.font=FONT_TEXT_NORMAL;
    [Utility fitLabel:textLable];
    
    iconView.centerY=iconView.superview.height/2-(textLable.height+3)/2;
    iconView.centerX=iconView.superview.width/2;
    textLable.centerX=iconView.centerX;
    textLable.top=iconView.bottom+3;
    
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    return ret;
}


-(void)choiceStudent{
//    [self gotoPageWithClass:[StudentInfoVC class] parameters:@{
//                                                               PAGE_PARAM_PERSON:_person,
//                                                               PAGE_PARAM_STUDENT:[NSNull null],
//                                                               }
//     ];
    [self gotoBackWithParamaters:@{
                                   @"CHOOSED_CHARACTER":@"学员",
                                              }];
    
    
}
-(void)choiceTeacher{
    
//    [self gotoPageWithClass:[TeacherInfoVC class] parameters:@{
//                                                               PAGE_PARAM_PERSON:_person,
//                                                               }
//     ];
    [self gotoBackWithParamaters:@{
                                   @"CHOOSED_CHARACTER":@"教练",
                                   }];
}
-(void)choiceCustomerService{
//    [self gotoPageWithClass:[CustomerServiceInfoVC class] parameters:@{
//                                                                       PAGE_PARAM_PERSON:_person,
//                                                                       }
//     ];
    [self gotoBackWithParamaters:@{
                                   @"CHOOSED_CHARACTER":@"客服",
                                   }];
}
-(void)choiceOperation{
//    [self gotoPageWithClass:[OperationInfoVC class] parameters:@{
//                                                                 PAGE_PARAM_PERSON:_person,
//                                                                 }
//     ];
    [self gotoBackWithParamaters:@{
                                   @"CHOOSED_CHARACTER":@"运营",
                                   }];
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_PERSON isEqualToString:key]){
        _person=value;
    }
}
@end