//
//  MainVC.m
//  myim
//
//  Created by Sean Shi on 15/10/15.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "MainVC.h"
#import "MenuView.h"
#import "CVC.h"
#import "TabBarVC.h"

@interface MainVC (){
    HeaderView* _header;
    MenuView* _menu;
    TabBarVC* _tabBarVC;
}

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:@""
             leftButton:nil
             rightButton:[HeaderView genItemWithType:HeaderItemType_Add target:self action:@selector(showMenu:) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];

    //初始化选型卡
    _tabBarVC=[[TabBarVC alloc] init];
    [self addChildViewController:_tabBarVC];
    [_tabBarVC.view setFrame:self.view.frame];
    _tabBarVC.view.height-=_header.bottom;
    _tabBarVC.view.top=_header.bottom;
    [self.view addSubview:_tabBarVC.view];

}

-(void)showMenu:(UIGestureRecognizer*)sender{
    if(_menu==nil){
        CGFloat w=100;
        _menu=[[MenuView alloc] initWithFrame:CGRectMake(getScreenSize().width-w-10, _header.bottom, w, 0)];
        sender.view.tagObject=_menu;
        _menu.layer.shadowColor = [UIColor blackColor].CGColor;
        _menu.layer.shadowOffset = CGSizeMake(0,0);
        _menu.layer.shadowOpacity = 0.3;
        _menu.layer.shadowRadius = 3.0;
        [_menu addItem:@"新的朋友" target:self action:@selector(menu_newFriend)];
        [_menu addItem:@"发起群聊" target:self action:@selector(menu_createGroup)];
        [self.view addSubview:_menu];
        [_menu reloadView];
        _menu.hidden=true;
    }
    [self.view bringSubviewToFront:_menu];
    if(_menu.hidden){
        _menu.right=self.view.width-10;
        _menu.hidden=false;
        _menu.alpha=0.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        _menu.alpha=1.0;
        [UIView commitAnimations];
    }
    
}

-(void)menu_createGroup{
    _menu.hidden=true;
    [self gotoPageWithClass:[CreateChatGroupVC class]];
}

-(void)menu_newFriend{
    _menu.hidden=true;
    [self gotoPageWithClass:[NewFriendVC class]];
}

-(void)hiddenAll:(UIView *)v{
    BOOL isMenu=false;
    if((v.tagObject!=nil && [v.tagObject isKindOfClass:[MenuView class]]) || [v isKindOfClass:[MenuView class]]){
        isMenu=true;
    }
    if(!isMenu){
        _menu.hidden=true;
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_INDEX isEqualToString:key]){
        NSInteger index=((NSNumber*)value).integerValue;
        if(_tabBarVC!=nil){
            _tabBarVC.selectedIndex=index;
        }
    }
}
@end
