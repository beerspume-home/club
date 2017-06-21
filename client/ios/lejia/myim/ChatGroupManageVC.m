//
//  ChatGroupManageVC.m
//  myim
//
//  Created by Sean Shi on 15/10/27.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChatGroupManageVC.h"

#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SPLIT_HEIGHT 0.5
#define FEATUREBAR_HEIGHT 43


@interface ChatGroupManageVC (){
    NSString* _groupid;
    ChatGroup* _group;
    
    Person* _groupOwner;
    BOOL _isOwner;
    
    UIView* _groupnameView;
}

@end

@implementation ChatGroupManageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
    [self reloadRemoteData];
    
}

-(void)reloadRemoteData{
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote getChatGroupWithId:_groupid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _group=callback_data.data;
            _groupOwner=[self getOwner:_group];
            _isOwner=_groupOwner!=nil && [_groupOwner.id isEqualToString:[Storage getLoginInfo].id];
            [self reloadView];
        }else if(callback_data.code==1){
            [Utility showError:@"群已经解散" type:ErrorType_Business];
            [self gotoBackToViewController:[MainVC class] paramaters:@{
                                                                           PAGE_PARAM_INDEX:@0,
                                                                           }];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)reloadView{
    [super reloadView];
    UIColor* color_feature_bar_bg=[UIColor whiteColor];

    //标题栏
    HeaderView* headView=[[HeaderView alloc]
                             initWithTitle:@"群信息"
                             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                             rightButton:nil
                             backgroundColor:COLOR_HEADER_BG
                             titleColor:COLOR_HEADER_TEXT
                             height:HEIGHT_HEAD_DEFAULT
                             ];
    [self.view addSubview:headView];
    //滚动部分
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.backgroundColor=[UIColor clearColor];
    scrollView.bounces=false;
    scrollView.top=headView.bottom;
    scrollView.left=0;
    scrollView.width=scrollView.superview.width;
    scrollView.height=scrollView.superview.height-scrollView.top;

    //群成员头像
    CGFloat headImageWidth=50;
    CGFloat spaceY=35;
    UIView* personHeadView=[[UIView alloc]init];
    [scrollView addSubview:personHeadView];
    personHeadView.backgroundColor=color_feature_bar_bg;
    personHeadView.width=personHeadView.superview.width;
    personHeadView.top=12;
    //成员头像排列参数
    NSInteger numberPreLine=(int)(personHeadView.width*0.7/headImageWidth);
    CGFloat totalSpace=personHeadView.width-(numberPreLine*headImageWidth);
    CGFloat space=totalSpace/(numberPreLine+1);
    CGFloat x=0;
    CGFloat y=10;
    //成员头像
    for(ChatGroupMember* m in _group.members){
        Person* person=m.person;
        
        //头像
        UIImageView* headImageView=[[UIImageView alloc]init];
        [personHeadView addSubview:headImageView];
        [headImageView sd_setImageWithURL:[NSURL URLWithString:person.imageurl] placeholderImage:[UIImage imageNamed:@"缺省头像"]];
        headImageView.tagObject=person;
        headImageView.userInteractionEnabled=true;
        [headImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickPerson:)]];
        headImageView.size=CGSizeMake(headImageWidth, headImageWidth);
        x+=space;
        if(x>headImageView.superview.width-space){
            x=space;
            y+=headImageWidth+spaceY;
        }
        headImageView.origin=CGPointMake(x, y);
        //成员名称
        UILabel* nicknameLabel=[[UILabel alloc]init];
        [personHeadView addSubview:nicknameLabel];
        nicknameLabel.font=FONT_TEXT_SECONDARY;
        nicknameLabel.textColor=COLOR_TEXT_SECONDARY;
        nicknameLabel.text=person.socialname;
        [Utility fitLabel:nicknameLabel];
        nicknameLabel.top=headImageView.bottom+3;
        nicknameLabel.centerX=headImageView.centerX;
        
        if(_isOwner && ![person.id isEqualToString: [Storage getLoginInfo].id]){
            UIImageView* delIconView=[[UIImageView alloc]init];
            [personHeadView addSubview:delIconView];
            delIconView.image=[UIImage imageNamed:@"删除_红_icon"];
            delIconView.size=CGSizeMake(15, 15);
            CGPoint a=CGPointMake(headImageView.right,headImageView.top);
            delIconView.center=a;
            delIconView.tagObject=person;
            delIconView.userInteractionEnabled=true;
            [delIconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeFromGroup:)]];
        }
        
        x=headImageView.right;
    }
    //添加成员按钮
    UIImageView* addIconView=[[UIImageView alloc]init];
    [personHeadView addSubview:addIconView];
    addIconView.image=[UIImage imageNamed:@"添加成员_icon"];
    addIconView.userInteractionEnabled=true;
    [addIconView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickAdd:)]];
    addIconView.size=CGSizeMake(headImageWidth, headImageWidth);
    x+=space;
    if(x>addIconView.superview.width-space){
        x=space;
        y+=headImageWidth+spaceY;
    }
    addIconView.origin=CGPointMake(x, y);
    personHeadView.height=y+headImageWidth+spaceY;
    
    _groupnameView=[UIUtility genFeatureItemInSuperView:scrollView
                                     top:personHeadView.bottom+12
                                   title:@"群聊名称"
                                  height:FEATUREBAR_HEIGHT
                                rightObj:[UIUtility genFeatureItemRightLabel]
                                  target:_isOwner?self:nil
                                  action:_isOwner?@selector(changeGroupName):nil
                               showSplit:false
     ];
    [UIUtility setFeatureItem:_groupnameView text:_group.name];

    //退出按钮
    UILabel* quitGroupLabel=[[UILabel alloc]init];
    quitGroupLabel.backgroundColor=COLOR_BUTTON_BG;
    quitGroupLabel.textColor=COLOR_BUTTON_TEXT;
    quitGroupLabel.textAlignment=NSTextAlignmentCenter;
    quitGroupLabel.layer.masksToBounds=YES;
    quitGroupLabel.layer.cornerRadius=CORNERRADIUS_BUTTON;
    quitGroupLabel.text=@"退出群组";
    quitGroupLabel.font=FONT_BUTTON;
    quitGroupLabel.userInteractionEnabled=true;
    [quitGroupLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(quitGroup:)]];
    [scrollView addSubview:quitGroupLabel];
    quitGroupLabel.size=CGSizeMake(quitGroupLabel.superview.width-30, HEIGHT_BUTTON);
    UIView* lastView=_groupnameView;
    quitGroupLabel.top=lastView.bottom>quitGroupLabel.superview.height?(lastView.bottom+15):(quitGroupLabel.superview.height+15);
    quitGroupLabel.centerX=quitGroupLabel.superview.width/2	;

    scrollView.contentSize=CGSizeMake(scrollView.width, quitGroupLabel.bottom+15);
    
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_GROUPID isEqualToString:key]){
        _groupid=value;
    }else if([PAGE_PARAM_PEOPLE isEqualToString:key]){
        NSMutableArray* persons=[Utility initArray:nil];
        for(Person* p in value){
            [persons addObject:p.id];
        }
        
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote addMembers:persons toChatGroup:_groupid callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [self reloadRemoteData];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
    }else if([PAGE_PARAM_GROUP isEqualToString:key]){
        _group=value;
        _groupid=_group.id;
        _groupOwner=[self getOwner:_group];
        _isOwner=_groupOwner!=nil && [_groupOwner.id isEqualToString:[Storage getLoginInfo].id];
        [self reloadView];
        [RCIMDelegate refreshGroupInCache:_group];
    }
}

-(void)clickPerson:(UIGestureRecognizer*)sender{
    if(sender.view.tagObject!=nil && [sender.view.tagObject isKindOfClass:[Person class]]){
        Person* p=(Person*)sender.view.tagObject;
        [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                  PAGE_PARAM_PERSON:p,
                                                                  }
         ];
    }
}
-(void)clickAdd:(UIGestureRecognizer*)sender{
    [self gotoPageWithClass:[SelectContactsVC class]];
}
-(void)quitGroup:(UIGestureRecognizer*)sender{
    NSString* personid=[Storage getLoginInfo].id;
    NSString* groupid=_groupid;
    [self removeMember:personid fromChatGroup:groupid callback:^(bool success) {
        if(success){
            [self gotoBackToViewController:[MainVC class] paramaters:@{
                                                                       PAGE_PARAM_INDEX:@0,
                                                                       }];
        }
    }];
}
-(void)removeFromGroup:(UIGestureRecognizer*)sender{
    if(sender.view.tagObject!=nil && [sender.view.tagObject isKindOfClass:[Person class]]){
        Person* p=(Person*)sender.view.tagObject;
        [self removeMember:p.id fromChatGroup:_groupid callback:^(bool success) {
            if(success){
                [self reloadRemoteData];
            }
        }];
    }
}

-(void)removeMember:(NSString*)personid fromChatGroup:(NSString*)groupid callback:(void (^)(bool success))callback{
    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote removeMember:personid fromChatGroup:groupid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [[RCIM sharedRCIM]clearGroupInfoCache];
            if(callback!=nil){
                callback(true);
            }
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
            if(callback!=nil){
                callback(false);
            }
        }
        [loadingView removeFromSuperview];
    }];
}

-(Person*) getOwner:(ChatGroup*)group{
    for(ChatGroupMember* m in group.members){
        if(m.isowner){
            return m.person;
        }
    }
    return nil;
}

-(void)changeGroupName{
    [self gotoPageWithClass:[ChangeGroupnameVC class] parameters:@{
                                                                   PAGE_PARAM_GROUP:_group,
                                                                   }];
}
@end
