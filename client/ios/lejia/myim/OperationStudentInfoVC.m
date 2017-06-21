//
//  OperationStudentInfoVC.m
//  myim
//
//  Created by Sean Shi on 15/11/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationStudentInfoVC.h"

@interface OperationStudentInfoVC (){
    HeaderView* _headView;
}

@end

@implementation OperationStudentInfoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@"学员管理"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:nil];
    
}

@end
