//
//  NewFriendVC.m
//  myim
//
//  Created by Sean Shi on 15/11/9.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "NewFriendVC.h"

#define HEIGHT_CELL 46
#define HEIGHT_HEADER 40

@interface NewFriendVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView* _tableView;
    UIScrollView* _scrollView;
    NSArray<Person*>* _addreddBookPerson;
    NSDictionary<NSString*,NSString*>* _addressBook;
}

@end

@implementation NewFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _addressBook=[Utility initDictionary:nil];
    _addreddBookPerson=[Utility initArray:nil];
    [self reloadView];
    [self findNewFriend];
}

-(void)findNewFriend{
    runInBackground(^{
        systemAddressBookMobileOnly(^(NSDictionary<NSString *,NSString *> *addressBook) {
            _addressBook=addressBook;
            NSMutableArray* phones=[NSMutableArray arrayWithArray:_addressBook.keyEnumerator.allObjects];
            [phones removeObject:[Storage getLoginInfo].phone];
            if(_addressBook!=nil){
                runInMain(^{
                    [Remote searchPhones:phones callback:^(StorageCallbackData *callback_data) {
                        if(callback_data.code==0){
                            _addreddBookPerson=callback_data.data;
                            [self reloadList];
                        }else{
                            [Utility showError:callback_data.message type:ErrorType_Network];
                        }
                    }];
                });
            }
        },true);
    });
}

-(void)reloadList{
    _tableView.height=_addreddBookPerson.count*HEIGHT_CELL+HEIGHT_HEADER;
    _scrollView.contentSize=CGSizeMake(_scrollView.width, _tableView.bottom+15);
    [_tableView reloadData];
}
-(void)reloadView{
    //初始化标题栏
    HeaderView* headView=[[HeaderView alloc]
             initWithTitle:@"新的朋友"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:nil
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:headView];
    
    //滚动部分
    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.bounces=false;
    _scrollView.origin=CGPointMake(0, headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    
    //搜索框
    UIView* searchView=[[UIView alloc]init];
    [_scrollView addSubview:searchView];
    searchView.size=CGSizeMake(searchView.superview.width, 45);
    searchView.origin=CGPointMake(0, 0);
    [searchView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoFindFriend)]];
    //搜索图标
    UIImageView* searchIcon=[[UIImageView alloc]init];
    [searchView addSubview:searchIcon];
    searchIcon.tintColor=COLOR_SPLIT;
    searchIcon.image=[[UIImage imageNamed:@"搜索_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    searchIcon.size=CGSizeMake(20, 20);
    searchIcon.left=26;
    searchIcon.centerY=searchIcon.superview.height/2;
    //搜索Label
    UILabel* searchLabel=[Utility genLabelWithText:@"手机号码/用户名/邮箱" bgcolor:nil textcolor:COLOR_SPLIT font:FONT_TEXT_NORMAL];
    [searchView addSubview:searchLabel];
    searchLabel.left=searchIcon.right+15;
    searchLabel.centerY=searchIcon.centerY;
    //下划线
    UIView* splitView=[[UIView alloc]init];
    [searchView addSubview:splitView];
    splitView.backgroundColor=COLOR_SPLIT;
    splitView.size=CGSizeMake(searchView.superview.width-30, 1);
    splitView.origin=CGPointMake(15, searchIcon.bottom+5);
    
    //列表
    _tableView=[[UITableView alloc]init];
    [_scrollView addSubview:_tableView];
    UIEdgeInsets edge=_tableView.separatorInset;
    edge.right=edge.left;
    _tableView.separatorInset=edge;
    _tableView.origin=CGPointMake(0, searchView.bottom);
    _tableView.width=_tableView.superview.width;
    _tableView.dataSource=self;
    _tableView.delegate=self;
    _tableView.bounces=false;
    
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _addreddBookPerson.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableCellWithIndexPath:indexPath];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
        UIView* view=[[UIView alloc]init];
        view.height=HEIGHT_HEADER;
        view.backgroundColor=COLOR_TABLE_SECTION_BG;
        UILabel* letterLabel=[[UILabel alloc]init];
        [view addSubview:letterLabel];
        letterLabel.font=FONT_TEXT_SECONDARY;
        letterLabel.textColor=COLOR_TABLE_SECTION_TEXT;
        letterLabel.text=@"新的朋友";
        [Utility fitLabel:letterLabel];
        letterLabel.left=15;
        letterLabel.bottom=letterLabel.superview.height-5;
        return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return HEIGHT_CELL;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEIGHT_HEADER;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person* selectedPerson=_addreddBookPerson[indexPath.row];
    [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                              PAGE_PARAM_PERSON:selectedPerson,
                                                              }];
}

-(UITableViewCell*) getTableCellWithIndexPath:(NSIndexPath*)indexPath{
    UITableViewCell* cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    cell.contentView.width=_tableView.width;
    Person* person=_addreddBookPerson[indexPath.row];
    
    [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                       person:person
                                  ]
     ];
    return cell;
}

-(UIView*) genLineViewInSuperView:(nonnull UIView*)superview person:(Person*)person{
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.width=ret.superview.width;
    ret.height=HEIGHT_CELL;
    BOOL isFriend=false;
    if([Cache getPersonFromContacts:person.id]!=nil){
        isFriend=true;
    }
    
    NSURL* url=[[NSURL alloc]initWithString:person.imageurl];
    NSString* title=person.socialname;
    UIImage* defaultIcon=[UIImage imageNamed:@"缺省头像"];
    NSString* descText=[@"手机通讯录:" stringByAppendingFormat:@"%@",_addressBook[person.phone]];
    
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
    UILabel* titleLabel=[[UILabel alloc]init];
    [ret addSubview:titleLabel];
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.text=title;
    [Utility fitLabel:titleLabel];
    titleLabel.centerY=iconView.centerY-(titleLabel.height/2)-1.5;
    titleLabel.left=iconView.right+10;
    if(titleLabel.width>superview.width-15-titleLabel.left){
        titleLabel.width=superview.width-15-titleLabel.left;
    }
    if(descText!=nil){
        UILabel* descLabel=[Utility genLabelWithText:descText
                                                bgcolor:[UIColor clearColor]
                                              textcolor:COLOR_TEXT_SECONDARY
                                                   font:FONT_TEXT_SECONDARY];
        [superview addSubview:descLabel];
        descLabel.textAlignment=NSTextAlignmentLeft;
        descLabel.left=titleLabel.left;
        descLabel.top=titleLabel.bottom+3;
    }
    
    if(isFriend){
        //好友标签
        UILabel* friendLabel=[Utility genLabelWithText:@"已添加" bgcolor:nil textcolor:COLOR_SPLIT font:FONT_TEXT_SECONDARY];
        [ret addSubview:friendLabel];
        friendLabel.right=friendLabel.superview.width-15;
        friendLabel.centerY=friendLabel.superview.height/2;
    }else{
        //添加好友按钮
        UILabel* friendButton=[UIUtility genButtonToSuperview:ret 
                                                          top:0
                                                        title:@"添加"
                                                       target:self
                                                       action:@selector(addContact:)];
        friendButton.tagObject=person;
        friendButton.font=FONT_TEXT_SECONDARY;
        friendButton.size=CGSizeMake(getStringSize(@"四个字宽", friendButton.font).width, friendButton.superview.height*0.6);
        friendButton.right=friendButton.superview.width-15;
        friendButton.centerY=friendButton.superview.height/2;
    }
    
    return ret;
}


#pragma mark 事件方法
-(void)gotoFindFriend{
    [self gotoPageWithClass:[FindFriendVC class]];
}

-(void)addContact:(UIGestureRecognizer*)sender{
    Person* person=sender.view.tagObject;
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote addContacts:person.id callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Cache addContacts:@[person]];
            [_tableView reloadData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

@end
