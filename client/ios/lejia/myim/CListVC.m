//
//  AListVC.m
//  myim
//
//  Created by Sean Shi on 15/10/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "CListVC.h"
#import "HeaderView.h"
#import "MenuView.h"
#import "CVC.h"

//实际显示会话列表的ViewController
@interface RCCListVC : RCConversationListViewController
@end

@interface CListVC (){
    RCCListVC* _rccListVC;
}
@end

@implementation CListVC
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化对话列表
    _rccListVC=[[RCCListVC alloc]init];
    _rccListVC.view.height=self.view.height-self.tabBarController.tabBar.height-64;//取消TabBar的高度
    [self addChildViewController:_rccListVC];
    [self.view addSubview:_rccListVC.view];

    
}

@end

@implementation RCCListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDisplayConversationTypeArray:@[@(ConversationType_PRIVATE),@(ConversationType_DISCUSSION), @(ConversationType_APPSERVICE), @(ConversationType_PUBLICSERVICE),@(ConversationType_GROUP),@(ConversationType_SYSTEM)]];
    
}


- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath{
    
    [Utility openConversationType:model.conversationType
                           target:model.targetId
                            title:model.conversationTitle
                 byViewController:self
     ];

}

- (void)notifyUpdateUnreadMessageCount{
    [super notifyUpdateUnreadMessageCount];
    [Utility notifyUpdateMessage];
}

@end
