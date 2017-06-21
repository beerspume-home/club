//
//  ViewController.m
//  myim
//
//  Created by Sean Shi on 15/10/12.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ViewController.h"
#import <RongIMKit/RongIMKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden=true;
    self.view.backgroundColor=COLOR_UI_BG;
}


-(void)viewWillAppear:(BOOL)animated{
    if([Storage getLoginInfo]!=nil){
        [Utility connectRongCloud];
        [self.navigationController pushViewController:[MainVC new] animated:false];
    }else{
        [self.navigationController pushViewController:[LoginVC new] animated:false];
    }
}




@end
