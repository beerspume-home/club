//
//  SearchSchoolResultVC.m
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SearchSchoolResultVC.h"
#define COLOR_HIGH_LIGHT UIColorFromRGB(0x45c01a)

@interface SearchSchoolResultVC ()<UITableViewDataSource,UITableViewDelegate>{
    NSString* _searchkey;
    NSMutableArray<School*>* _schools;
    NSInteger _start;
    NSInteger _offset;
    
    UITableView* _tableView;
    
    BOOL _loading;
    BOOL _isend;
    
    Class _backClass;
    Class _forwardClass;
}

@end

@implementation SearchSchoolResultVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(_schools==nil){
            _schools=[Utility initArray:nil];
    }
    [self reloadView];
    _loading=false;
    _isend=_schools.count<_offset?true:false;
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
        [self.view addSubview:_tableView];
    }
    _tableView.origin=CGPointMake(0, headView.bottom);
    _tableView.size=CGSizeMake(_tableView.superview.width, _tableView.superview.height-_tableView.top);
    _tableView.delegate=self;
    _tableView.dataSource=self;

}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_SET isEqualToString:key]){
        if([value isKindOfClass:[NSArray class]]){
            if([value isKindOfClass:[NSMutableArray class]]){
                _schools=value;
            }else{
                _schools=[NSMutableArray arrayWithArray:value];
            }
        }else{
            _schools=[Utility initArray:nil];
        }
    }else if([PAGE_PARAM_START isEqualToString:key]){
        if([value isKindOfClass:[NSNumber class]]){
            _start=((NSNumber*)value).integerValue;
        }else{
            _start=0;
        }
    }else if([PAGE_PARAM_OFFSET isEqualToString:key]){
        if([value isKindOfClass:[NSNumber class]]){
            _offset=((NSNumber*)value).integerValue;
        }else{
            _offset=30;
        }
    }else if([PAGE_PARAM_SEARCHKEY isEqualToString:key]){
        _searchkey=value;
    }else if([PAGE_PARAM_BACK_CLASS isEqualToString:key]){
        _backClass=value;
    }else if([PAGE_PARAM_FORWARD_CLASS isEqualToString:key]){
        _forwardClass=value;
    }
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
        schoolNameLabel.attributedText=[Utility highLightString:school.name
                                                    withKeyword:_searchkey
                                                 highLightColor:COLOR_HIGH_LIGHT
                                        ];
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
        if([Utility isEmptyString:school.introduction]){
            introductionLabel.text=@"暂无介绍";
        }else{
            introductionLabel.attributedText=[Utility highLightString:school.introduction
                                                          withKeyword:_searchkey
                                                       highLightColor:COLOR_HIGH_LIGHT
                                              ];
        }
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
    if(index<_schools.count-1 || _isend){
        School* school=_schools[index];
        if(_backClass){
            [self gotoBackToViewController:_backClass
                            paramaters:@{
                                         PAGE_PARAM_SCHOOL:school,
                                         }];
        }else if(_forwardClass){
            [self gotoPageWithClass:_forwardClass
                         parameters:@{
                                      PAGE_PARAM_SCHOOL:school,
                                      }];
        }else{
            [self gotoBackWithParamaters:@{
                                           PAGE_PARAM_SCHOOL:school,
                                           }];
        }
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
        [Remote searchSchool:_searchkey fuzzy:false start:_schools.count offset:_offset callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSArray<School*>* result=callback_data.data;
                [_schools addObjectsFromArray:result];
                [_tableView reloadData];
            }else if(callback_data.code==2){
                _isend=true;
                [_tableView reloadData];
//                [Utility showError:callback_data.message type:ErrorType_Business];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            _loading=false;
        }];
    }
}
@end
