//
//  WalletReceivableVC.m
//  myim
//
//  Created by Sean Shi on 15/10/31.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "WalletReceivableVC.h"
#import "MenuView.h"

@interface WalletReceivableVC ()

@end

@implementation WalletReceivableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    self.view.backgroundColor=UIColorFromRGB(0xFFFFFF);
    
    //Logo
    UIImageView* logo=[[UIImageView alloc]init];
    [self.view addSubview:logo];
    logo.image=[UIImage imageNamed:@"应收款Logo"];
    logo.width=logo.superview.width/4;
    logo.height=logo.width;
    logo.top=40;
    logo.centerX=logo.superview.width/2;
    UILabel* titleLabel=[[UILabel alloc]init];
    [self.view addSubview:titleLabel];
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.text=@"我的应收款";
    [Utility fitLabel:titleLabel];
    titleLabel.top=logo.bottom+5;
    titleLabel.centerX=logo.centerX;
    
    //余额
    UILabel* balanceLabel=[[UILabel alloc]init];
    [self.view addSubview:balanceLabel];
    balanceLabel.font=[UIFont systemFontOfSize:30.0];
    balanceLabel.textColor=COLOR_TEXT_NORMAL;
    balanceLabel.attributedText=[Utility convertToStringFromMoney:0 font:balanceLabel.font];
    [Utility fitLabel:balanceLabel];
    balanceLabel.top=titleLabel.bottom+10;
    balanceLabel.centerX=logo.centerX;
}

@end
