//
//  ChoiceChatGroupVC.m
//  myim
//
//  Created by Sean Shi on 15/10/23.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChoiceChatGroupVC.h"

@interface ChoiceChatGroupVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray* _chatGroups;
    
    UITableView* _tableView;
    UIImage* _defaultHeadIcon;
}

@end

@implementation ChoiceChatGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _chatGroups=[Utility initArray:nil];
    _defaultHeadIcon=[UIImage imageNamed:@"缺省群头像"];
    [self reloadView];

    __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote searchChatGroup:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _chatGroups=callback_data.data;
//            [_tableView reloadData];
            [self reloadView];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
    
}

-(void)reloadView{
    //标题栏
    UIView* headView=[[HeaderView alloc] initWithTitle:@"选择一个群"
                                            leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                           rightButton:nil
                                       backgroundColor:COLOR_MENU_BG
                                            titleColor:COLOR_MENU_TEXT
                      ];
    [self.view addSubview:headView];
 
    if(_chatGroups!=nil && _chatGroups.count>0){
        //聊天群列表
        if(_tableView==nil){
            _tableView=[[UITableView alloc]init];
            _tableView.delegate=self;
            _tableView.dataSource=self;
            _tableView.separatorInset=UIEdgeInsetsMake(
                                                       _tableView.separatorInset.top,
                                                       _tableView.separatorInset.left,
                                                       _tableView.separatorInset.bottom,
                                                       _tableView.separatorInset.left);
            [self.view addSubview:_tableView];
        }
        _tableView.top=headView.bottom;
        _tableView.size=CGSizeMake(_tableView.superview.width, _tableView.superview.height-_tableView.top);
        _tableView.left=0;
    }

    
}


-(UIView*) genLineViewInSuperView:(nonnull UIView*)superview title:(nonnull NSString*)title URL:(NSURL*)url defaultIcon:(nonnull UIImage*)defaultIcon{
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.width=ret.superview.width;
    ret.height=46;
    //头像
    UIImageView* iconView=[[UIImageView alloc]init];
    if(url==nil){
        iconView.image=defaultIcon;
    }else{
        [iconView sd_setImageWithURL:url placeholderImage:defaultIcon];
    }
    [ret addSubview:iconView];
    CGFloat iconWidth=ret.height*0.8;
    iconView.size=CGSizeMake(iconWidth, iconWidth);
    iconView.centerY=iconView.superview.height/2;
    iconView.left=15;
    //昵称
    UILabel* titleLabel=[[UILabel alloc]init];
    [ret addSubview:titleLabel];
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.text=title;
    [Utility fitLabel:titleLabel];
    titleLabel.centerY=iconView.centerY;
    titleLabel.left=iconView.right+10;
    return ret;
}
-(UITableViewCell*) getTableCellWithIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell* cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    ChatGroup* group=_chatGroups[indexPath.row];
    [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                        title:group.name
                                                          URL:[[NSURL alloc]initWithString:group.imageurl]
                                                  defaultIcon:_defaultHeadIcon                                  ]
     ];
    return cell;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _chatGroups.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableCellWithIndexPath:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ChatGroup* group=_chatGroups[indexPath.row];
    [Utility openChatGroupTarget:group.id
                           title:group.name
                byViewController:self
     ];
}

@end
