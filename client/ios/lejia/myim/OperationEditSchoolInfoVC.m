//
//  OperationEditSchoolInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/11/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditSchoolInfoVC.h"

@interface OperationEditSchoolInfoVC (){
    NSString* _schoolid;
    
    HeaderView* _headView;


}

@end

@implementation OperationEditSchoolInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    self.view.backgroundColor=[UIColor whiteColor];
    _headView=[[HeaderView alloc]initWithTitle:@"公众号维护"
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                              rightButton:nil
                          ];
    [self.view addSubview:_headView];
    
    
    UIFont* font1=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:FONT_TEXT_NORMAL.pointSize*2];
//    UIFont* font2=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:FONT_TEXT_NORMAL.pointSize];
    CGFloat iconSize=0;
    
    UIView* introduceView=[[UIView alloc]init];
    [self.view addSubview:introduceView];
    introduceView.backgroundColor=UIColorFromRGB(0x00b0ff);
    introduceView.origin=CGPointMake(0, _headView.bottom);
    introduceView.size=CGSizeMake(introduceView.superview.width, 100);
    introduceView.userInteractionEnabled=true;
    [introduceView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoIntroduce:)]];

    UILabel* introductLabel=[Utility genLabelWithText:@"驾校介绍" bgcolor:nil textcolor:[UIColor whiteColor] font:font1];
    [introduceView addSubview:introductLabel];
    [Utility fitLabel:introductLabel];
    introductLabel.left=20;
    introductLabel.centerY=introductLabel.superview.height/2;
    UIImageView* introduceImageView=[[UIImageView alloc]init];
    [introduceView addSubview:introduceImageView];
    introduceImageView.image=[[UIImage imageNamed:@"驾校介绍_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    iconSize=introduceImageView.superview.height*0.6;
    introduceImageView.size=CGSizeMake(iconSize*introduceImageView.image.size.width/introduceImageView.image.size.height, iconSize);
    introduceImageView.centerX=introduceImageView.superview.width-((introduceImageView.superview.width/2-20)/2);
    introduceImageView.centerY=introduceImageView.superview.height/2;
    introduceImageView.tintColor=[UIColor whiteColor];

    UIView* pictureView=[[UIView alloc]init];
    [self.view addSubview:pictureView];
    pictureView.backgroundColor=UIColorFromRGB(0xffae21);
    pictureView.origin=CGPointMake(0, introduceView.bottom);
    pictureView.size=CGSizeMake(pictureView.superview.width, 100);
    pictureView.userInteractionEnabled=true;
    [pictureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoPicture:)]];

    UILabel* pictureLabel=[Utility genLabelWithText:@"驾校一景" bgcolor:nil textcolor:[UIColor whiteColor] font:font1];
    [pictureView addSubview:pictureLabel];
    [Utility fitLabel:pictureLabel];
    pictureLabel.right=pictureLabel.superview.width-20;
    pictureLabel.centerY=introductLabel.superview.height/2;
    UIImageView* pictureImageView=[[UIImageView alloc]init];
    [pictureView addSubview:pictureImageView];
    pictureImageView.image=[[UIImage imageNamed:@"驾校一景_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    iconSize=pictureImageView.superview.height*0.6;
    pictureImageView.size=CGSizeMake(iconSize*pictureImageView.image.size.width/pictureImageView.image.size.height, iconSize);
    pictureImageView.centerX=((pictureImageView.superview.width/2-20)/2);
    pictureImageView.centerY=pictureImageView.superview.height/2;
    pictureImageView.tintColor=[UIColor whiteColor];
}


-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }
}


-(void)gotoIntroduce:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[OperationEditSchoolInfoIntroduceVC class] parameters:@{
                                                                                    PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                                    }];
}
-(void)gotoPicture:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[OperationEditSchoolInfoPictureVC class] parameters:@{
                                                                                    PAGE_PARAM_SCHOOL_ID:_schoolid,
                                                                                    }];
}
@end
