//
//  OperationSignupListVC.m
//  myim
//
//  Created by Sean Shi on 15/11/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationSignupListVC.h"

@interface OperationSignupListVC ()<UITableViewDataSource,UITableViewDelegate>{
    HeaderView* _headView;
    UITableView* _tableView;
    
    NSMutableArray<SchoolSignup*>* _signups;
    
    NSString* _schoolid;
    NSInteger _offset;
    BOOL _loading;
    BOOL _isend;
    BOOL _showtreated;
    
    MenuView* _menu;
    NSInteger _selectedIndex;
}

@end

@implementation OperationSignupListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _offset=30;
    _signups=[Utility initArray:nil];
    [self reloadView];
    [self loadNextResult];
}
-(void)reloadView{
    [super reloadView];
    
    _headView=[[HeaderView alloc]initWithTitle:@"学员报名"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:[HeaderView genItemWithText:@"筛选" target:self action:@selector(showMenu:)]];
    [self.view addSubview:_headView];
    
    _tableView=[[UITableView alloc]init];
    [self.view addSubview:_tableView];
    _tableView.origin=(CGPoint){0,_headView.bottom};
    _tableView.size=(CGSize){_tableView.superview.width,_tableView.superview.height-_tableView.top};
    _tableView.bounces=false;
    _tableView.dataSource=self;
    _tableView.delegate=self;
    
}


#pragma mark 表格
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger ret=_signups.count+(_isend?0:1);
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cell_name=@"cell";
    NSInteger index=indexPath.row;
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cell_name];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_name];
    }
    
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    
    cell.contentView.width=tableView.width;
    if(index<_signups.count){
        SchoolSignup* signup=_signups[index];
        SchoolClass* schoolclass=signup.schoolclass;
        NSString* title=[NSString stringWithFormat:@"姓名:%@\n报名时间:%@",signup.name,signup.createdate];
        UILabel* titleLabel=[Utility genLabelWithText:title bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_SECONDARY];
        [cell.contentView addSubview:titleLabel];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        titleLabel.left=15;
        titleLabel.centerY=titleLabel.superview.height/2;
        
        NSString* classText=[NSString stringWithFormat:@"(%@)%@\n%@元\n[%@]",schoolclass.licensetype,schoolclass.name,schoolclass.fee,[signup isSignup]?@"已完成报名":[signup isAbandon]?@"放弃":@"未处理"];
        UILabel* classLabel=[Utility genLabelWithText:classText bgcolor:nil textcolor:COLOR_TEXT_NORMAL font:FONT_TEXT_SECONDARY];
        [cell.contentView addSubview:classLabel];
        classLabel.textAlignment=NSTextAlignmentRight;
        classLabel.right=classLabel.superview.width-15;
        classLabel.centerY=classLabel.superview.height/2;
        
    }else{
        UILabel* refreshLabel=[[UILabel alloc]init];
        [cell.contentView addSubview:refreshLabel];
        refreshLabel.font=FONT_TEXT_NORMAL;
        refreshLabel.textColor=COLOR_TEXT_NORMAL;
        refreshLabel.text=[NSString stringWithFormat:@"正在获取报名申请",_offset];
        [Utility fitLabel:refreshLabel];
        refreshLabel.center=refreshLabel.superview.innerCenterPoint;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 55;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedIndex=indexPath.row;
    if(_selectedIndex<_signups.count-1 || _isend){
        SchoolSignup* signup=_signups[_selectedIndex];
        [self gotoPageWithClass:[OperationSignupInfoVC class] parameters:@{
                                                                           PAGE_PARAM_SCHOOL_SIGNUP:signup,
                                                                           }];
    }
}


#pragma mark 上拉刷新
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(!_isend){
        CGSize size=scrollView.contentSize;
        CGPoint p=scrollView.contentOffset;
        CGFloat h=scrollView.height;
        CGFloat scrollBottom=p.y+h;
        if(scrollBottom>size.height-20){
            [self loadNextResult];
        }
    }
}
-(void)loadNextResult{
    if(!_loading){
        _loading=true;
        [Remote schoolSignupList:_schoolid showtreated:_showtreated start:_signups.count offset:_offset callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSArray<SchoolSignup*>* result=callback_data.data;
                [_signups addObjectsFromArray:result];
                _isend=result.count<_offset?true:false;
                [_tableView reloadData];
            }else if(callback_data.code==2){
                _isend=true;
                [_tableView reloadData];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            _loading=false;
        }];
    }
}

-(void)menu_filter_showtreated{
    NSString* text=_showtreated?@"显示已处理报名申请":@"隐藏已处理报名申请";
    [_menu replaceItemText:text atIndex:0];
    _showtreated=!_showtreated;
    [self hiddenAll:nil];
    _signups=[Utility initArray:_signups];
    [self loadNextResult];
}

-(void)showMenu:(UIGestureRecognizer*)sender{
    if(_menu==nil){
        CGFloat w=100;
        _menu=[[MenuView alloc] initWithFrame:CGRectMake(getScreenSize().width-w-10, _headView.bottom, w, 0)];
        sender.view.tagObject=_menu;
        _menu.layer.shadowColor = [UIColor blackColor].CGColor;
        _menu.layer.shadowOffset = CGSizeMake(0,0);
        _menu.layer.shadowOpacity = 0.3;
        _menu.layer.shadowRadius = 3.0;
        [_menu addItem:@"显示已处理报名申请" target:self action:@selector(menu_filter_showtreated)];
        [self.view addSubview:_menu];
        [_menu reloadView];
        _menu.hidden=true;
    }
    [self.view bringSubviewToFront:_menu];
    if(_menu.hidden){
        _menu.right=self.view.width-10;
        _menu.top=_headView.bottom+2;
        _menu.hidden=false;
        _menu.alpha=0.0;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        _menu.alpha=1.0;
        [UIView commitAnimations];
    }
    
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
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }else if([PAGE_PARAM_SCHOOL_SIGNUP isEqualToString:key]){
        [_signups replaceObjectAtIndex:_selectedIndex withObject:value];
        [_tableView reloadData];
    }
}
@end
