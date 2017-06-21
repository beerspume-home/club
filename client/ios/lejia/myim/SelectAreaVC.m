//
//  ChangeAreaVC.m
//  myim
//
//  Created by Sean Shi on 15/10/28.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SelectAreaVC.h"
#import "AreaManager.h"

@interface SelectAreaVC ()<UITableViewDataSource,UITableViewDelegate>{
    UITableView* _level1TableView;
    UITableView* _tableView;
    UIView* _selectedAreaView;
    UILabel* _selectedAreaLabel;
    
    NSArray<Area*>* _allArea;
    Area* _currentArea;
}

@end

@implementation SelectAreaVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _allArea=[Storage getAllArea];
    [self reloadView];
    [self.view addGestureRecognizer:[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)]];
}

-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);
    //初始化标题栏
    HeaderView* headView=[[HeaderView alloc]
             initWithTitle:@"选择地区"
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:headView];
    
    //已选地区
    _selectedAreaView=[[UIView alloc]init];
    [self.view addSubview:_selectedAreaView];
    _selectedAreaView.size=CGSizeMake(_selectedAreaView.superview.width, 40);
    _selectedAreaView.origin=CGPointMake(0, headView.bottom);
    //已选地区-指示文字
    _selectedAreaLabel=[[UILabel alloc]init];
    [_selectedAreaView addSubview:_selectedAreaLabel];
    _selectedAreaLabel.size=CGSizeMake(_selectedAreaLabel.superview.width-30, _selectedAreaLabel.superview.height);
    _selectedAreaLabel.origin=CGPointMake(15, 0);
    _selectedAreaLabel.font=FONT_TEXT_NORMAL;
    _selectedAreaLabel.textColor=COLOR_TEXT_NORMAL;
    
    //已选地区-分割线
    UIView* splitView=[[UIView alloc]init];
    [self.view addSubview:splitView];
    splitView.size=CGSizeMake(splitView.superview.width, 1);
    splitView.origin=CGPointMake(0, _selectedAreaView.bottom);
    splitView.backgroundColor=COLOR_SPLIT;
    
    
    
    //省市
    if(_level1TableView==nil){
        _level1TableView=[[UITableView alloc]init];
        [self.view addSubview:_level1TableView];
    }
    _level1TableView.origin=CGPointMake(0, splitView.bottom);
    _level1TableView.size=CGSizeMake(_level1TableView.superview.width, _level1TableView.superview.height-_level1TableView.top);
    _level1TableView.tagObject=[NSMutableDictionary dictionaryWithDictionary:@{@"areas":_allArea}];
    _level1TableView.delegate=self;
    _level1TableView.dataSource=self;
    _level1TableView.bounces=false;
    
    _selectedAreaLabel.text=_currentArea==nil?@"":_currentArea.namepath;
    
}

-(void)swipe:(UISwipeGestureRecognizer*)sender{
    if(sender.direction==UISwipeGestureRecognizerDirectionRight){
        if(_tableView!=nil && _tableView!=_level1TableView){
            [_tableView removeFromSuperview];
        }
        UITableView* parentTableView=[self tableViewParent:_tableView];
        if(parentTableView!=nil && parentTableView!=_level1TableView){
            [UIView animateWithDuration:0.5 animations:^{
                parentTableView.left=parentTableView.width/2;
            } completion:^(BOOL finished) {
                _tableView=parentTableView;
            }];
        }
        _selectedAreaLabel.text=[self getSelectAreaText];
        
    }
}

-(Area*)getSelectArea{
    Area* ret=nil;
    UITableView* t=_level1TableView;
    for(int i=0;i<100;i++){
        if(t!=nil && t.superview!=nil){
            Area* area=[self tableViewArea:t];
            if(area==nil){
                break;
            }
            ret=area;
            t=[self tableViewSub:t];
        }else{
            break;
        }
    }
    return ret;
}

-(NSString*)getSelectAreaText{
    Area* area=[self getSelectArea];
    return area.namepath;
}

#pragma mark 处理表格
-(void)showSubArea:(NSArray<Area*>*)subarea toParentTableView:(UITableView*)parentTableView{
    UITableView* subTableView=[self tableViewSub:parentTableView];
    subTableView.tagObject[@"value"]=nil;
    if(parentTableView.left!=0){
        [UIView animateWithDuration:0.5 animations:^{
            parentTableView.left=0;
            
        } completion:^(BOOL finished) {
            if(finished){
                if(subTableView.superview==nil){
                    [self.view addSubview:subTableView];
                }
                subTableView.size=CGSizeMake(parentTableView.width, parentTableView.height);
                subTableView.origin=CGPointMake(parentTableView.width*0.5, parentTableView.top);
                subTableView.tagObject[@"areas"] =subarea;
                [subTableView reloadData];
                _tableView=subTableView;
            }
        }];
    }else{
        if(subTableView.superview==nil){
            [self.view addSubview:subTableView];
        }
        subTableView.size=CGSizeMake(parentTableView.width, parentTableView.height);
        subTableView.origin=CGPointMake(parentTableView.width*0.5, parentTableView.top);
        subTableView.tagObject[@"areas"]=subarea;
        [subTableView reloadData];
        _tableView=subTableView;
    }
    

}

-(Area*) tableViewArea:(UITableView*)tableView{
    Area* ret=nil;
    if(tableView.tagObject!=nil && [tableView.tagObject isKindOfClass:[NSDictionary class]]){
        ret=tableView.tagObject[@"value"];
    }
    return ret;
}

-(NSArray<Area*>*) tableViewData:(UITableView*)tableView{
    NSArray<Area*>* data=@[];
    if(tableView.tagObject!=nil && [tableView.tagObject isKindOfClass:[NSDictionary class]]){
        data=tableView.tagObject[@"areas"];
    }
    return data;
}
-(UITableView*) tableViewParent:(UITableView*)tableView{
    UITableView* ret=nil;
    if(tableView.tagObject!=nil && [tableView.tagObject isKindOfClass:[NSDictionary class]]){
        ret=tableView.tagObject[@"parent"];
    }
    return ret;
}

-(UITableView*) tableViewSub:(UITableView*)tableView{
    UITableView* ret=nil;
    if(tableView.tagObject!=nil && [tableView.tagObject isKindOfClass:[NSDictionary class]]){
        ret=tableView.tagObject[@"sub"];
    }
    if(ret==nil){
        ret=[[UITableView alloc]init];
        ret.delegate=self;
        ret.dataSource=self;
        ret.bounces=false;
        ret.layer.masksToBounds = false;
        ret.layer.shadowColor = [UIColor blackColor].CGColor;
        ret.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
        ret.layer.shadowOpacity = 0.3f;
        if(ret.tagObject==nil){
            ret.tagObject=[NSMutableDictionary dictionaryWithDictionary:@{}];
        }
        ret.tagObject[@"parent"]=tableView;
        tableView.tagObject[@"sub"]=ret;
    }
    
    return ret;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray<Area*>* data=[self tableViewData:tableView];
    return data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<Area*>* data=[self tableViewData:tableView];

    NSString* cell_name=@"level1_cell";
    UITableViewCell* cell=[tableView dequeueReusableCellWithIdentifier:cell_name];
    if(cell==nil){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell_name];
    }
    cell.textLabel.font=FONT_TEXT_NORMAL;
    cell.textLabel.textColor=COLOR_TEXT_NORMAL;
    cell.textLabel.text=data[indexPath.row].name;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray<Area*>* data=[self tableViewData:tableView];
    Area* area=data[indexPath.row];
    tableView.tagObject[@"value"]=area;
    if(area.subarea!=nil && area.subarea.count>0){
        [self showSubArea:area.subarea toParentTableView:tableView];
    }
    _selectedAreaLabel.text=[self getSelectAreaText];
}
-(void)ok{
    Area* area=[self getSelectArea];
    if(area==nil){
        [Utility showError:@"请选择地区" type:ErrorType_Business];
    }else{
        [self gotoBackWithParamaters:@{
                                   PAGE_PARAM_AREA:area,
                                   }];
    }
}


-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_AREA isEqualToString:key]){
        if(![[NSNull null] isEqual:value]){
            _currentArea=value;
        }
    }
}
@end
