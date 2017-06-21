//
//  ContactVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "CreateChatGroupVC.h"

#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SEARCH_MIXWIDTH 50

@interface CreateChatGroupVC ()<UITableViewDelegate,UITableViewDataSource>{
    Person* _person;
    
    NSMutableArray* _contacts_all;
    NSMutableArray* _contacts_searchresult;
    NSArray* _letter_order;
    NSMutableDictionary* _letter_mapping;
    UITableView* _tableView;
    NSMutableArray* _selectedPerson;
    
    //已选择用户的头像
    UIScrollView* _selectedPersonView;
    //搜索输入框
    UITextField* _searchTextField;
    
    UIImage* _defaultHeadIcon;
    
    BOOL _isFirstLoad;
    
}
@end

@implementation CreateChatGroupVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _person=[Storage getLoginInfo];
    _letter_order=[Utility initArray:nil];
    _selectedPerson=[Utility initArray:nil];
    _defaultHeadIcon=[UIImage imageNamed:@"缺省头像"];
    _isFirstLoad=true;
    [self reloadView];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    __block LoadingView* loadingView=nil;
    if(_isFirstLoad){
        loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        _isFirstLoad=false;
    }
    [Remote contactsWithCallbak:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [self orderContacts:(NSMutableArray*)callback_data.data searchKey:_searchTextField.text];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)orderContacts:(NSMutableArray*)contacts searchKey:(NSString*)searchKey{
    _contacts_all=contacts;

    if(searchKey==nil || searchKey.length==0){
        _contacts_searchresult=[NSMutableArray arrayWithArray:_contacts_all];
    }else{
        _contacts_searchresult=[Utility initArray:nil];
        for(int i=0;i<_contacts_all.count;i++){
            Person* person=_contacts_all[i];
            if([person.socialname rangeOfString:searchKey].location!=NSNotFound){
                [_contacts_searchresult addObject:person];
            }
        }
    }
    
    _letter_mapping=[Utility initDictionary:nil];
    NSMutableArray* __letter_order=[Utility initArray:nil];
    for(Person* person in _contacts_searchresult){
        NSString* firstletter=person.socialname_firstletter;
        if(![__letter_order containsObject:firstletter]){
            [__letter_order addObject:firstletter];
        }
        NSMutableArray* letterArray=(NSMutableArray*)_letter_mapping[firstletter];
        if(letterArray==nil){
            letterArray=[Utility initArray:nil];
            _letter_mapping[firstletter]=letterArray;
        }
        [letterArray addObject:person];
    }
    _letter_order=[__letter_order sortedArrayUsingSelector:@selector(compare:)];
    [_tableView reloadData];
}
-(Person*)personWithIndexPath:(NSIndexPath*)indexPath{
    NSString* letter=_letter_order[indexPath.section];
    return (((NSMutableArray*)_letter_mapping[letter])[indexPath.row]);
}

-(void)reloadView{
    //标题栏
    UIView* headView=[[HeaderView alloc]initWithTitle:@"发起群聊"
                                           leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                          rightButton:[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok)]
                                      backgroundColor:COLOR_MENU_BG
                                           titleColor:COLOR_MENU_TEXT
                      ];
    [self.view addSubview:headView];
    
    //搜索
    UIView* searchView=[[UIView alloc]init];
    [self.view addSubview:searchView];
    searchView.size=CGSizeMake(searchView.superview.width, 46);
    searchView.origin=CGPointMake(0,headView.bottom);
    searchView.backgroundColor=UIColorFromRGB(0xf7f8f6);
    //选中的用户头像
    _selectedPersonView=[[UIScrollView alloc]init];
    [searchView addSubview:_selectedPersonView];
    _selectedPersonView.size=CGSizeMake(0, _selectedPersonView.superview.height);
    _selectedPersonView.origin=CGPointMake(PADDING_LEFT,0);
    _selectedPersonView.backgroundColor=UIColorFromRGB(0xf7f8f6);
    _selectedPersonView.bounces=false;
    //搜索输入框
    _searchTextField=[[UITextField alloc]init];
    [searchView addSubview:_searchTextField];
    _searchTextField.placeholder=@"搜索";
    _searchTextField.font=FONT_TEXT_NORMAL;
    _searchTextField.size=CGSizeMake(_searchTextField.superview.width-PADDING_LEFT-PADDING_RIGHT, _searchTextField.superview.height*0.8);
    _searchTextField.origin=CGPointMake(PADDING_LEFT, _searchTextField.superview.height-_searchTextField.height);
    [_searchTextField addTarget:self action:@selector(searchFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    //选择一个群按钮
    UIView* choiceGroupView=[[UIView alloc]init];
    [self.view addSubview:choiceGroupView];
    choiceGroupView.size=CGSizeMake(choiceGroupView.superview.width, 46);
    choiceGroupView.origin=CGPointMake(0,searchView.bottom);
    choiceGroupView.backgroundColor=UIColorFromRGB(0xf7f8f6);
    choiceGroupView.userInteractionEnabled=true;
    [choiceGroupView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(choiceGroup)]];
    //分割线
    UIView* split=[[UIView alloc]init];
    [choiceGroupView addSubview:split];
    split.backgroundColor=COLOR_SPLIT;
    split.size=CGSizeMake(split.superview.width-30, 0.5);
    split.left=15;
    split.top=0;
    //按钮文字
    UILabel* choiceGroupLable=[[UILabel alloc]init];
    [choiceGroupView addSubview:choiceGroupLable];
    choiceGroupLable.text=@"选择一个群";
    choiceGroupLable.font=FONT_TEXT_NORMAL;
    choiceGroupLable.textColor=COLOR_TEXT_NORMAL;
    [Utility fitLabel:choiceGroupLable];
    choiceGroupLable.left=15;
    choiceGroupLable.centerY=choiceGroupLable.superview.height/2;
    
    //通讯录表
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
    _tableView.top=choiceGroupView.bottom;
    _tableView.size=CGSizeMake(_tableView.superview.width, _tableView.superview.height-_tableView.top);
    _tableView.left=0;
}

-(UIView*) genLineViewInSuperView:(nonnull UIView*)superview title:(nonnull NSString*)title URL:(NSURL*)url defaultIcon:(nonnull UIImage*)defaultIcon selected:(BOOL)selected{
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.width=ret.superview.width;
    ret.height=46;
    //是否选中
    UIImageView* selectedIcon=[[UIImageView alloc]init];
    [ret addSubview:selectedIcon];
    selectedIcon.size=CGSizeMake(20, 20);
    selectedIcon.centerY=selectedIcon.superview.height/2;
    selectedIcon.left=15;
    if(selected){
        selectedIcon.image=[UIImage imageNamed:@"selectdict_选中圆点"];
    }else{
        selectedIcon.image=[UIImage imageNamed:@"selectdict_未选中圆点"];
    }
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
    iconView.left=selectedIcon.right+10;
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
    Person* person=[self personWithIndexPath:indexPath];
    [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                        title:person.socialname
                                                          URL:[[NSURL alloc]initWithString:person.imageurl]
                                                  defaultIcon:_defaultHeadIcon                                  selected:[_selectedPerson containsObject:person]
                                  ]
     ];
    return cell;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString* letter=_letter_order[section];
    return  ((NSArray*)_letter_mapping[letter]).count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableCellWithIndexPath:indexPath];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _letter_order.count;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView* view=[[UIView alloc]init];
    view.height=20;
    view.backgroundColor=COLOR_TABLE_SECTION_BG;
    UILabel* letterLabel=[[UILabel alloc]init];
    [view addSubview:letterLabel];
    letterLabel.font=FONT_TEXT_SECONDARY;
    letterLabel.textColor=COLOR_TABLE_SECTION_TEXT;
    letterLabel.text=_letter_order[section];
    [Utility fitLabel:letterLabel];
    letterLabel.left=15;
    letterLabel.centerY=letterLabel.superview.height/2;
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Person* selectedPerson=[self personWithIndexPath:indexPath];
    [self checkPerson:selectedPerson];
}

#pragma mark 事件方法
//确定发起群聊
-(void)ok{
    if(_selectedPerson.count==0){
        [Utility showError:@"请选择群聊成员" type:ErrorType_Business];
        return;
    }
    if(_selectedPerson.count==1){
        Person* chatPerson=(Person*)_selectedPerson[0];
        [Utility openChatPersonTarget:chatPerson.id title:chatPerson.socialname byViewController:self];

    }else{
        NSMutableArray<NSString*>* persons=[Utility initArray:nil];
        for(int i=0;i<_selectedPerson.count;i++){
            [persons addObject:((Person*)_selectedPerson[i]).id];
        }
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote createChatGroup:_person.id persons:persons callback:^(StorageCallbackData *callback_data){
            if(callback_data.code==0){
                ChatGroup* chatGroup=callback_data.data;
                [Utility openChatGroupTarget:chatGroup.id title:chatGroup.name byViewController:self];

            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
    }
}
-(void)checkPerson:(Person*)person{
    
    if([_selectedPerson containsObject:person]){
        [_selectedPerson removeObject:person];
    }else{
        [_selectedPerson addObject:person];
    }
    
    [self updateSelectPersonView];
}

-(void) updateSelectPersonView{
    [_tableView reloadData];
    for(UIView* v in _selectedPersonView.subviews){
        [v removeFromSuperview];
    }
    
    CGFloat iconSize=_selectedPersonView.height*0.8;
    CGFloat x=0;
    for(int i=0;i<_selectedPerson.count;i++){
        Person* person=(Person*)_selectedPerson[i];
        NSURL* url=[NSURL URLWithString:person.imageurl];
        //头像
        UIImageView* iconView=[[UIImageView alloc]init];
        if(url==nil){
            iconView.image=_defaultHeadIcon;
        }else{
            [iconView sd_setImageWithURL:url placeholderImage:_defaultHeadIcon];
        }
        iconView.tagObject=person;
        iconView.userInteractionEnabled=true;
        [iconView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector( deselectPerson:)]];
        [_selectedPersonView addSubview:iconView];
        iconView.size=CGSizeMake(iconSize, iconSize);
        iconView.centerY=iconView.superview.height/2;
        iconView.left=x;
        x=iconView.right+5;
    }
    CGFloat selectMaxWidth=_selectedPersonView.superview.width-PADDING_LEFT-PADDING_RIGHT-SEARCH_MIXWIDTH;
    _selectedPersonView.width=(x+_selectedPersonView.left<selectMaxWidth)?x:selectMaxWidth;
    _selectedPersonView.contentSize=CGSizeMake(x, _selectedPersonView.height);
    _searchTextField.left=_selectedPersonView.right+5;
    _searchTextField.width=_selectedPersonView.superview.width-_searchTextField.left-PADDING_RIGHT-5;
    
}

-(void)deselectPerson:(UIGestureRecognizer*)sender{
    if(sender!=nil && [sender.view isKindOfClass:[UIImageView class]]){
        if([sender.view.tagObject isKindOfClass:[Person class]]){
            Person* person=sender.view.tagObject;
            [_selectedPerson removeObject:person];
            [self updateSelectPersonView];
        }
    }
}
-(void)choiceGroup{
    [self gotoPageWithClass:[ChoiceChatGroupVC class]];
}

-(void)searchFieldDidChange:(UITextField *) textField{
    [self orderContacts:_contacts_all searchKey:_searchTextField.text];
}


@end
