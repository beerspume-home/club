//
//  TATeacherTimeTableListVC.m
//  myim
//
//  Created by Sean Shi on 15/12/1.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherTimeTableListVC.h"

@interface TATeacherTimeTableListVC ()<UITableViewDataSource,UITableViewDelegate>{
    HeaderView* _headView;
    
    UITableView* _tableView;
}

@end

@implementation TATeacherTimeTableListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

- (void)reloadView {
    [super reloadView];
    _headView=[[HeaderView alloc]initWithTitle:@"课程表"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:[HeaderView genItemWithText:@"添加课表" target:self action:@selector(add:)]];
    [self.view addSubview:_headView];
    
    _tableView=[[UITableView alloc]init];
    [_tableView fillSuperview:self.view underOf:_headView];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 0;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


-(void)add:(UIGestureRecognizer*)sender{
    
}

@end
