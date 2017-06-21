//
//  TabBarVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "TabBarVC.h"
#import "CListVC.h"
#import "ContactVC.h"
#import "FeaturesVC.h"
#import "MeVC.h"

@interface TabBarVC (){
    CListVC* _vc1;
}
@end

@implementation TabBarVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置图标选中颜色
    self.tabBar.tintColor=COLOR_TABBAR_TINTCOLOR;
    self.tabBarController.tabBar.tintColor=COLOR_TABBAR_TINTCOLOR;
    
    NSInteger unreadCount=[[RCIMClient sharedRCIMClient]getTotalUnreadCount];
    _vc1=[[CListVC alloc] init];
    _vc1.tabBarItem.title=@"消息";
    _vc1.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_未选中_消息"];
    _vc1.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_选中_消息"];
    _vc1.tabBarItem.badgeValue=unreadCount>0?[NSString stringWithFormat:@"%ld",(long)unreadCount]:nil;

    UIViewController* vc2=[ContactVC new];
    vc2.tabBarItem.title=@"通讯录";
    vc2.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_未选中_通讯录"];
    vc2.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_选中_通讯录"];
    vc2.tabBarItem.badgeValue=nil;

    UIViewController* vc3=[FeaturesVC new];
    vc3.tabBarItem.title=@"应用";
    vc3.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_未选中_应用"];
    vc3.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_选中_应用"];
    vc3.tabBarItem.badgeValue=nil;

    UIViewController* vc4=[MeVC new];
    vc4.tabBarItem.title=@"我";
    vc4.tabBarItem.image=[UIImage imageNamed:@"TabBar_icon_未选中_我"];
    vc4.tabBarItem.selectedImage=[UIImage imageNamed:@"TabBar_icon_选中_我"];
    vc4.tabBarItem.badgeValue=nil;

    self.viewControllers=@[_vc1,vc2,vc3,vc4];

    //注册新消息通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyUpdateUnreadMessage:) name:@"NSNOTIFICATIONCENTER_KEY_UNREADMESSAGE" object:nil];
    

}

//注册新消息通知
-(void)notifyUpdateUnreadMessage:(NSNotification*) aNotification{
    runDelayInMain(^{
        NSInteger unreadCount=[[RCIMClient sharedRCIMClient]getTotalUnreadCount];
        _vc1.tabBarItem.badgeValue=unreadCount>0?[NSString stringWithFormat:@"%ld",(long)unreadCount]:nil;
        [UIApplication sharedApplication].applicationIconBadgeNumber  =  unreadCount;
    }, 0.5);
    
}

-(void)dealloc{
    //注销新消息通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSNOTIFICATIONCENTER_KEY_UNREADMESSAGE object:nil];
}
@end
