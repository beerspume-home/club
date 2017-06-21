//
//  MyInterestSchoolListVC.m
//  myim
//
//  Created by Sean Shi on 15/10/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "MyInterestSchoolListVC.h"

#define COLOR_HIGH_LIGHT UIColorFromRGB(0x45c01a)

@interface MyInterestSchoolListVC ()<UITableViewDataSource,UITableViewDelegate>{
    NSMutableArray<School*>* _schools;
    NSInteger _start;
    NSInteger _offset;
    
    UITableView* _tableView;
    
    BOOL _loading;
    BOOL _isend;
}

@end

@implementation MyInterestSchoolListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isend=false;
    _offset=30;
    if(_schools==nil){
        _schools=[Utility initArray:nil];
    }
    [self reloadView];
    _loading=false;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadNextResult];
}

-(void)reloadView{
    [super reloadView];
    
    //标题栏
    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"驾校"
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:nil
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];
    
    if(_tableView==nil){
        _tableView=[[UITableView alloc]init];
        _tableView.bounces=false;
        UIEdgeInsets edge=_tableView.separatorInset;
        edge.right=edge.left;
        [_tableView setSeparatorInset:edge];
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    _tableView.origin=CGPointMake(0, headView.bottom);
    _tableView.size=CGSizeMake(_tableView.superview.width, _tableView.superview.height-_tableView.top);
    
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
}

#pragma mark 表格
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _schools.count+(_isend?0:1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString* cell_name=@"school_cell";
    NSInteger index=indexPath.row;
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cell_name];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_name];
    }
    
    for(UIView* v in cell.contentView.subviews){
        [v removeFromSuperview];
    }
    
    cell.contentView.width=tableView.width;
    if(index<_schools.count){
        School* school=_schools[index];
        
        UIImageView* schoolImageView=[[UIImageView alloc]init];
        [cell.contentView addSubview:schoolImageView];
        [schoolImageView sd_setImageWithURL:[NSURL URLWithString:school.imageurl] placeholderImage:[UIImage imageNamed:@"驾校缺省Logo"]];
        schoolImageView.size=CGSizeMake(40, 40);
        schoolImageView.origin=CGPointMake(tableView.separatorInset.left, 10);
        schoolImageView.layer.masksToBounds=YES;
        schoolImageView.layer.borderColor=[COLOR_TEXT_SECONDARY CGColor];
        schoolImageView.layer.borderWidth=1.0;
        schoolImageView.layer.cornerRadius=schoolImageView.width/2;

        //认证标记
        UILabel* certifiedLabel=[UIUtility genCertifiedLabel:[school isCertified]];
        [cell.contentView addSubview:certifiedLabel];
        certifiedLabel.top=schoolImageView.bottom+3;
        certifiedLabel.centerX=schoolImageView.centerX;
        
        //驾校名称
        UILabel* schoolNameLabel=[[UILabel alloc]init];
        [cell.contentView addSubview:schoolNameLabel];
        schoolNameLabel.font=FONT_TEXT_NORMAL;
        schoolNameLabel.textColor=COLOR_TEXT_NORMAL;
        schoolNameLabel.text=school.name;
        [Utility fitLabel:schoolNameLabel];
        schoolNameLabel.left=schoolImageView.right+10;
        schoolNameLabel.top=schoolImageView.top;
        //驾校所属地区
        if(school.area!=nil){
            UILabel* areaLabel=[[UILabel alloc]init];
            [cell.contentView addSubview:areaLabel];
            areaLabel.font=FONT_TEXT_SECONDARY;
            areaLabel.textColor=COLOR_TEXT_SECONDARY;
            areaLabel.text=school.area.namepath;
            [Utility fitLabel:areaLabel];
            areaLabel.left=schoolNameLabel.right+5;
            areaLabel.centerY=schoolNameLabel.centerY;
        }
        //驾校介绍
        UILabel* introductionLabel=[[UILabel alloc]init];
        [cell.contentView addSubview:introductionLabel];
        introductionLabel.font=FONT_TEXT_SECONDARY;
        introductionLabel.textColor=COLOR_TEXT_SECONDARY;
        introductionLabel.text=school.introduction;
        introductionLabel.origin=CGPointMake(schoolNameLabel.left, schoolNameLabel.bottom+5);
        CGFloat maxWidth=introductionLabel.superview.width-introductionLabel.left-_tableView.separatorInset.right;
        introductionLabel.size=CGSizeMake(maxWidth, 50);
        introductionLabel.lineBreakMode=NSLineBreakByTruncatingTail;
        introductionLabel.numberOfLines=0;
        
        //分割线
        UIView* splitView=[[UIView alloc]init];
        [cell.contentView addSubview:splitView];
        splitView.size=CGSizeMake(splitView.superview.width-_tableView.separatorInset.left-_tableView.separatorInset.right, 0.5);
        splitView.origin=CGPointMake(_tableView.separatorInset.left, 90);
        splitView.backgroundColor=COLOR_SPLIT;
        
        
    }else{
        UILabel* refreshLabel=[[UILabel alloc]init];
        [cell.contentView addSubview:refreshLabel];
        refreshLabel.font=FONT_TEXT_NORMAL;
        refreshLabel.textColor=COLOR_TEXT_NORMAL;
        refreshLabel.text=[NSString stringWithFormat:@"载入%d条查询到的驾校",_offset];
        [Utility fitLabel:refreshLabel];
        refreshLabel.center=refreshLabel.superview.innerCenterPoint;
    }
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    if(index<_schools.count || _isend){
        School* school=_schools[index];
        [self gotoPageWithClass:[SchoolMPPageVC class] parameters:@{
                                                                    PAGE_PARAM_SCHOOL:school,
                                                                    }
         ];
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
        [Remote myInterestedSchool:_schools.count offset:_offset callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSArray<School*>* result=callback_data.data;
                if(result.count<_offset){
                    _isend=true;
                }
                [_schools addObjectsFromArray:result];
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
@end
