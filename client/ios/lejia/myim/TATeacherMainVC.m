//
//  TATeacherMainVC.m
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TATeacherMainVC.h"

@interface TATeacherMainVC (){
    UITabBarController* _tabBarVC;
    
    AController* _vcSettings;
    AController* _vcCalendar;
    AController* _vcDateCalendar;
    AController* _vcRecordList;
    
    NSString* _teacherid;
}

@end

@implementation TATeacherMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)reloadView{
    [super reloadView];
    for(UIViewController* vc in self.childViewControllers){
        [vc removeFromParentViewController];
    }
    _tabBarVC=[[UITabBarController alloc]init];
    [self addChildViewController:_tabBarVC];
    [self.view addSubview:_tabBarVC.view];
    _tabBarVC.view.frame=self.view.frame;
    
    //设置图标选中颜色
    _tabBarVC.tabBar.tintColor=COLOR_TABBAR_TINTCOLOR;
    _tabBarVC.tabBarController.tabBar.tintColor=COLOR_TABBAR_TINTCOLOR;
    
    
    _vcSettings=[[TATeacherSettingsVC alloc] init];
    [_vcSettings putValue:_teacherid byKey:PAGE_PARAM_TEACHER_ID];
    _vcSettings.tabBarItem.title=@"设置";
    _vcSettings.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_设置"];
    _vcSettings.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_设置"];
    
    _vcCalendar=[[TATeacherTimeTableVC alloc] init];
    [_vcCalendar putValue:_teacherid byKey:PAGE_PARAM_TEACHER_ID];
    _vcCalendar.tabBarItem.title=@"课程表";
    _vcCalendar.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_未选中_消息"];
    _vcCalendar.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_选中_消息"];

    _vcDateCalendar=[[TATeacherDateCalendarVC alloc] init];
    [_vcDateCalendar putValue:_teacherid byKey:PAGE_PARAM_TEACHER_ID];
    _vcDateCalendar.tabBarItem.title=@"约车日历";
    _vcDateCalendar.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_日历"];
    _vcDateCalendar.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_日历"];

    
    _vcRecordList=[[TATeacherRecordListVC alloc] init];
    [_vcRecordList putValue:_teacherid byKey:PAGE_PARAM_TEACHER_ID];
    _vcRecordList.tabBarItem.title=@"预约学员";
    _vcRecordList.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_学员"];
    _vcRecordList.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_学员"];

    _tabBarVC.viewControllers=@[_vcSettings,_vcDateCalendar,_vcRecordList];
    
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_TEACHER_ID isEqualToString:key]){
        _teacherid=value;
    }
}
@end
