//
//  OperationStudentListVC.m
//  myim
//
//  Created by Sean Shi on 15/11/21.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationStudentListVC.h"
@interface OperationStudentListVC (){
    HeaderView* _headView;
}
@end

@implementation OperationStudentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    _headView=[[HeaderView alloc] initWithTitle:@"驾校学员"
                                     leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                    rightButton:nil];
    [self.view addSubview:_headView];
}
@end
