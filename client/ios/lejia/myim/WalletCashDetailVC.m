//
//  WalletCashDetailVC.m
//  myim
//
//  Created by Sean Shi on 15/11/1.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "WalletCashDetailVC.h"

@interface WalletCashDetailVC ()

@end

@implementation WalletCashDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];

    HeaderView* headView=[[HeaderView alloc]initWithTitle:@"现金账户明细"
                                  leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                 rightButton:nil
             ];
    [self.view addSubview:headView];

}
@end
