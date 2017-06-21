//
//  ContactVC.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ContactVC.h"
#import <UIImageView+WebCache.h>

@interface ContactVC ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray* _contacts_all;
    NSArray* _letter_order;
    NSMutableDictionary* _letter_mapping;
    
    UITableView* _tableView;
    
    BOOL _firstLoad;
    BOOL _tableViewResized;
    
    Person* _me;
}
@end

@implementation ContactVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _letter_order=[Utility initArray:nil];
    _me=[Storage getLoginInfo];
    [self reloadView];
    _firstLoad=true;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadRemoteData];
}

-(void)viewDidAppear:(BOOL)animated{
    if(!_tableViewResized){
        _tableView.frame=self.view.frame;
        _tableView.height-=self.tabBarController.tabBar.height;
        _tableViewResized=true;
    }
}

-(void)reloadRemoteData{
    __block LoadingView* loadingView=nil;
    if(_firstLoad){
        loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        _firstLoad=false;
    }
    [Remote contactsWithCallbak:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [self orderContacts:(NSMutableArray*)callback_data.data];
            [_tableView reloadData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [loadingView removeFromSuperview];
    }];
}

-(void)orderContacts:(NSMutableArray*)contacts{
    _contacts_all=contacts;
    _letter_mapping=[Utility initDictionary:nil];
    NSMutableArray* __letter_order=[Utility initArray:nil];
    for(Person* person in _contacts_all){
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
}
-(Person*)personWithIndexPath:(NSIndexPath*)indexPath{
    NSString* letter=_letter_order[indexPath.section-1];
    return (((NSMutableArray*)_letter_mapping[letter])[indexPath.row]);
}

-(void)reloadView{
    if(_tableView==nil){
        _tableView=[[UITableView alloc]init];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.separatorInset=UIEdgeInsetsMake(
                                                   _tableView.separatorInset.top,
                                                   _tableView.separatorInset.left,
                                                   _tableView.separatorInset.bottom,
                                                   _tableView.separatorInset.left);
        _tableView.bounces=false;
        [self.view addSubview:_tableView];
    }
}

-(UIView*) genLineViewInSuperView:(nonnull UIView*)superview title:(nonnull NSString*)title URL:(NSURL*)url defaultIcon:(nonnull UIImage*)defaultIcon rightText:(NSString*)rightText{
    UIView* ret=[[UIView alloc]init];
    [superview addSubview:ret];
    ret.width=ret.superview.width;
    ret.height=46;
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
    titleLabel.centerY=iconView.centerY;
    titleLabel.left=iconView.right+10;
    if(titleLabel.width>superview.width-15-titleLabel.left){
        titleLabel.width=superview.width-15-titleLabel.left;
    }
    if(rightText!=nil){
        UILabel* teacherLabel=[Utility genLabelWithText:rightText
                                                bgcolor:[UIColor clearColor]
                                              textcolor:COLOR_TEXT_SECONDARY
                                                   font:FONT_TEXT_SECONDARY];
        [superview addSubview:teacherLabel];
        teacherLabel.textAlignment=NSTextAlignmentRight;
        teacherLabel.numberOfLines=0;
        teacherLabel.right=teacherLabel.superview.width-15;
        teacherLabel.centerY=teacherLabel.superview.height/2;
    }
    return ret;
}
-(UITableViewCell*) getTableCellWithIndexPath:(NSIndexPath*)indexPath{
    NSInteger section=indexPath.section;
    NSInteger index=indexPath.row;
    
    UITableViewCell* cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    cell.contentView.width=_tableView.width;
    if(section==0){
        switch(index){
            case 0:{
                [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                                    title:@"新的朋友"
                                                                      URL:nil
                                                              defaultIcon:[UIImage imageNamed:@"新的朋友_icon"]                                               rightText:nil
                                              ]
                 ];
                break;
            }
            case 1:{
                [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                                    title:@"群聊"
                                                                      URL:nil
                                                              defaultIcon:[UIImage imageNamed:@"群聊_icon"]                                               rightText:nil
                                              ]
                 ];
                break;
            }
            case 2:{
                [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                                    title:@"公众号"
                                                                      URL:nil
                                                              defaultIcon:[UIImage imageNamed:@"公众号_icon"]
                                                                rightText:nil
                                              ]
                 ];
                break;
            }
        }
    }else{
        Person* person=[self personWithIndexPath:indexPath];
        NSString* rightText=nil;
        if([person isTeacher]){
            rightText=[NSString stringWithFormat:@"%@ 教练",person.school_name];
        }else if([person isCustomerService]){
            rightText=[NSString stringWithFormat:@"%@ 客服",person.school_name];
        }else if([person isOperation]){
            rightText=[NSString stringWithFormat:@"%@ 运营",person.school_name];
        }else if([person isStudent] && [person.school_id isEqualToString:_me.school_id]){
            rightText=[NSString stringWithFormat:@"%@ 学员",person.name];
        }
        [cell.contentView addSubview:[self genLineViewInSuperView:cell.contentView
                                                            title:person.socialname
                                                              URL:[[NSURL alloc]initWithString:person.imageurl]
                                                      defaultIcon:[UIImage imageNamed:@"缺省头像"]
                                                        rightText:rightText
                                      ]
         ];
    }
    return cell;
}
#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section==0){
        return 3;
    }else{
        NSString* letter=_letter_order[section-1];
        return  ((NSArray*)_letter_mapping[letter]).count;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self getTableCellWithIndexPath:indexPath];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _letter_order.count+1;
}
- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(section==0){
        return nil;
    }else{
        UIView* view=[[UIView alloc]init];
        view.height=20;
        view.backgroundColor=COLOR_TABLE_SECTION_BG;
        UILabel* letterLabel=[[UILabel alloc]init];
        [view addSubview:letterLabel];
        letterLabel.font=FONT_TEXT_SECONDARY;
        letterLabel.textColor=COLOR_TABLE_SECTION_TEXT;
        letterLabel.text=_letter_order[section-1];
        [Utility fitLabel:letterLabel];
        letterLabel.left=15;
        letterLabel.centerY=letterLabel.superview.height/2;
        return view;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 46;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0){
        return 0;
    }else{
        return 20;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section=indexPath.section;
    NSInteger index=indexPath.row;
    if(section==0){
        switch(index){
            case 0:{
                [self findFriend];
                break;
            }
            case 1:{
                [self gotoPageWithClass:[ChoiceChatGroupVC class]];
                break;
            }
            case 2:{
                [self listCompany];
                break;
            }
        }
    }else{
        Person* selectedPerson=[self personWithIndexPath:indexPath];
        [self gotoPageWithClass:[PersonInfoVC class] parameters:@{
                                                                  PAGE_PARAM_PERSON:selectedPerson,
                                                                  }];
    }
}

#pragma mark 事件方法
//查找新好友
-(void)findFriend{
//    [self gotoPageWithClass:[FindFriendVC class]];
    [self gotoPageWithClass:[NewFriendVC class]];
}
//查看关注的驾校
-(void)listCompany{
    [self gotoPageWithClass:[MyInterestSchoolListVC class]];
}
@end
