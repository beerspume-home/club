//
//  SchoolSignupInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/11/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SchoolSignupInfoVC.h"

@interface SchoolSignupInfoVC (){
}

@end

@implementation SchoolSignupInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}


-(void)reloadView{
    [super reloadView];
    HeaderView* headView=[[HeaderView alloc]initWithTitle:@"报名须知"
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                              rightButton:nil
                          ];
    [self.view addSubview:headView];

    UIScrollView* _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.backgroundColor=[UIColor whiteColor];
    _scrollView.origin=CGPointMake(0, headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    
    UILabel* textLabel=[[UILabel alloc]init];
    [_scrollView addSubview:textLabel];
    textLabel.width=textLabel.superview.width-30;
    textLabel.text=[Storage getAppTextWithKey:@"signup_text"];
    textLabel.textColor=COLOR_TEXT_NORMAL;
    textLabel.font=FONT_TEXT_SECONDARY;
    textLabel.numberOfLines=0;
    CGSize size=getStringSizeLimitWithWidth(textLabel.text, textLabel.font,textLabel.width);
    textLabel.size=size;
    textLabel.origin=CGPointMake(15, 15);
    
    _scrollView.contentSize=CGSizeMake(_scrollView.width, textLabel.height+30);
    
}
@end
