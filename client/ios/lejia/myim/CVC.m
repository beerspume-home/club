//
//  CVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "CVC.h"
#import "HeaderView.h"
#import "PluginBoardView.h"

//实际显示会话的ViewController
@interface RCCVC : RCConversationViewController<RCPluginBoardViewDelegate,RCMessageCellDelegate,JEAppointmentMessageCellDelegate>{
    HeaderView* _header;
    BOOL _inited;
    
    BOOL _isStudent;
    Student* _student;
    BOOL _isTeacher;
    Teacher* _teacher;
    BOOL _isCustomerService;
    CustomerService* _customerService;
    BOOL _isOperation;
    Operation* _operation;
}

@property(nonatomic,retain)CVC* superViewController;

-(instancetype) initWithConversationType:(RCConversationType)conversationType targetId:(NSString*)targetId title:(NSString*)title;
@end

@interface CVC (){
    RCCVC* _rccVC;
}
@end

@implementation CVC

-(instancetype) initWithConversationType:(RCConversationType)conversationType targetId:(NSString*)targetId title:(NSString*)title{
    _conversationType=conversationType;
    _targetId=targetId;
    _ctitle=title;
    return [self init];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化对话列表
    _rccVC=[[RCCVC alloc]
            initWithConversationType:_conversationType
            targetId:_targetId
            title:_ctitle
            ];
    _rccVC.superViewController=self;
    [_rccVC.view setFrame:self.view.frame];
    [self addChildViewController:_rccVC];
    [self.view addSubview:_rccVC.view];
    
}
-(void)click_back{
    [self gotoBackToViewController:[MainVC class] paramaters:@{
                                                               PAGE_PARAM_INDEX:@0,
                                                               }];
}

-(void)clickRightButton{
    if(_conversationType==ConversationType_PRIVATE){
        [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                  PAGE_PARAM_PERSONID:_targetId,
                                                                  }];
    }else if(_conversationType==ConversationType_GROUP){
        [self gotoPageWithClass:[ChatGroupManageVC class] parameters:@{
                                                                       PAGE_PARAM_GROUPID:_targetId
                                                                       }];
    }
}


@end


@implementation RCCVC
-(instancetype) initWithConversationType:(RCConversationType)conversationType targetId:(NSString*)targetId title:(NSString*)title{
    RCCVC* ret=[self init];
    self.conversationType=conversationType;
    self.targetId=targetId;
//    self.userName=userName;
    self.title=title;
    return ret;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    _inited=false;
    //初始化标题栏
    UIView* rightButton=nil;
    if(self.conversationType==ConversationType_PRIVATE){
        rightButton=[HeaderView genItemWithType:HeaderItemType_Person target:_superViewController action:@selector(clickRightButton)];
    }else if(self.conversationType==ConversationType_GROUP){
        rightButton=[HeaderView genItemWithType:HeaderItemType_People target:_superViewController action:@selector(clickRightButton)];
    }
    _header=[[HeaderView alloc]
             initWithTitle:self.title
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:_superViewController action:@selector(click_back) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:rightButton
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    CGFloat inputBarHeight= self.chatSessionInputBarControl.height;
    //对话界面高=屏幕高-下部输入框高-标题栏高+刷新图标部分高(20)
    self.conversationMessageCollectionView.height=self.view.height-inputBarHeight-_header.height+20;
    //（-20）意味者头部包含刷新图标部分的高
    self.conversationMessageCollectionView.top=_header.bottom-20;
    
    [self registerClass:[JEAppointmentMessageCell class] forMessageClass:[JEAppointmentMessage class]];
    
    //滚动到最新消息
    [self scrollToBottomAnimated:false];
    
    [self initTalkerCharacter];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(!_inited){
        [self scrollToBottomAnimated:true];
        _inited=true;
    }
    
    //发送系统消息通知更新
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNOTIFICATIONCENTER_KEY_UNREADMESSAGE object:nil userInfo:nil];
    
}
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag{
    [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
    if(tag==2001){//约车
        [self.superViewController gotoPageWithClass:[TAStudentCalendarVC class]  parameters:@{
                                                                                                               PAGE_PARAM_STUDENT_ID:[Storage getStudent].id,
                                                                                                               PAGE_PARAM_TEACHER_ID:_teacher.id,
                                                                                                               PAGE_PARAM_TEACHER:_teacher,
                                                                                                               }];
        
    }
}

#pragma mark 触摸用户头像
-(void)didTapCellPortrait:(NSString *)userId{
    [self.superViewController gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                                  PAGE_PARAM_PERSONID:userId,
                                                                                  }];
    
}
#pragma mark 消息点击
-(void)didTapMessageCell:(RCMessageModel *)model{
    if([model.content isKindOfClass:[JEAppointmentMessage class]]){
        JEAppointmentMessage* message=(JEAppointmentMessage*)model.content;
        if(_teacher!=nil && [_teacher.id isEqualToString:message.teacherid]){
            debugLog(@"teacher:%@",message.teacherid);
        }else if(_student!=nil && [_student.id isEqualToString:message.studentid]){
            debugLog(@"student:%@",message.studentid);
        }
    }else{
        [super didTapMessageCell:model];
    }
}

-(void)initTalkerCharacter{
    if(self.conversationType==ConversationType_PRIVATE){
        _isStudent=false;
        _isTeacher=false;
        _isCustomerService=false;
        _isOperation=false;
        [Remote availableCharacter:self.targetId callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSString* character_type=callback_data.data[@"character_type"];
                if([@"student" isEqualToString:character_type]){
                    _isStudent=true;
                    _student=callback_data.data[@"obj"];
                }else if([@"teacher" isEqualToString:character_type]){
                    _isTeacher=true;
                    _teacher=callback_data.data[@"obj"];
                }else if([@"customerservice" isEqualToString:character_type]){
                    _isCustomerService=true;
                    _customerService=callback_data.data[@"obj"];
                }else if([@"operation" isEqualToString:character_type]){
                    _isOperation=true;
                    _operation=callback_data.data[@"obj"];
                }
                if([Storage getStudent]!=nil && _isTeacher){
                    [self.chatSessionInputBarControl.pluginBoardView insertItemWithImage:[UIImage imageNamed:@"CVC_plugin_icon_约车日历"] title:@"约车" tag:2001];
                }
            }else{
                [Utility showError:callback_data.message];
            }
        }];
    }
}

#pragma mark 自定义消息视图
-(RCMessageBaseCell*)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RCMessageModel* model=self.conversationDataRepository[indexPath.row];
    NSString * cellIndentifier=nil;
    if([model.content isKindOfClass:[JEAppointmentMessage class]]){
        cellIndentifier=@"JEAppointmentMessageCell";
    }
    
    RCMessageBaseCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIndentifier           forIndexPath:indexPath];
    [cell setDataModel:model];
    if([cell isKindOfClass:[JEAppointmentMessageCell class]]){
        ((JEAppointmentMessageCell*)cell).indexPath=indexPath;
        ((JEAppointmentMessageCell*)cell).appointmentDelegate=self;
        ((JEAppointmentMessageCell*)cell).delegate=self;
        if(_teacher!=nil){
            ((JEAppointmentMessageCell*)cell).currentTeacherid=_teacher.id;
        }
        if(_student!=nil){
            ((JEAppointmentMessageCell*)cell).currentStudentid=_student.id;
        }
    }
    
    return cell;
}
//自定义消息视图尺寸
-(CGSize)rcConversationCollectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize ret=[super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];

    RCMessageModel* model=self.conversationDataRepository[indexPath.row];
    if([model.content isKindOfClass:[JEAppointmentMessage class]]){
        ret.height=150;
    }
    
    return ret;
}


@end
