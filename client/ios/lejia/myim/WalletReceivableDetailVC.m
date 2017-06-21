//
//  WalletReceivableDetailVC.m
//  myim
//
//  Created by Sean Shi on 15/11/1.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "WalletReceivableDetailVC.h"

@interface WalletReceivableDetailVC ()

@end

@implementation WalletReceivableDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    
    HeaderView* headView=[[HeaderView alloc]initWithTitle:@"应收款账户明细"
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                              rightButton:nil
                          ];
    [self.view addSubview:headView];
    
}
@end
