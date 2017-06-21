//
//  SelectCharacterVC.m
//  myim
//
//  Created by LN on 15/12/24.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SelectCharacterVC.h"

#define MYINFO_HEADER_HEIGHT 70
#define MYINFO_NORMAL_HEIGHT 43

@interface SelectCharacterVC ()
{
    UILabel *_nowIdentifer;//小字
    UIView *_nowHeaderView;//当前身份
    NSArray *_dataList;//数据
    UIView *_listLabelView;//历史记录label
    UILabel *_schoolLabel;
    NSString *_signOrUnsignBtnText;//提交按钮
    UIView *_submitedMaskView;//遮罩
    UIScrollView *_scrollView;
    NSString *_character;//选择的角色
    School *_school;//选择的学校
    NSString *_currentIdenStr;//当前身份
    
    Student* _cs;
    Teacher* _ct;
    Operation* _co;
    CustomerService* _cc;
    BaseObject *setSucceed;//创建身份成功后的类
    __block LoadingView* _lv;
}
@end

@implementation SelectCharacterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    Person *person = [Storage getLoginInfo];
    NSLog(@"%@",person);
    _signOrUnsignBtnText = @"提交申请";
    _character = @"";
    [self reloadView];
    [self getData];
}
/**重新获取数据*/
-(void)getData{
    _lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote allCharacter:[Storage getLoginInfo].id callback:^(StorageCallbackData *callback_data) {
        if (callback_data.code == 0) {
            _dataList = callback_data.data;
            [Remote availableCharacter:[Storage getLoginInfo].id callback:^(StorageCallbackData *callback_data) {
                if (callback_data.code == 0) {
                    NSDictionary *d = callback_data.data;
                    if([@"student" isEqualToString:d[@"character_type"]]){
                        _cs = (Student *)[d objectForKey:@"obj"];
                        _currentIdenStr = @"学员";
                        _signOrUnsignBtnText = [_cs.person.certified integerValue] == 0?@"取消申请":@"解除签约";
                        _nowIdentifer.text =[_cs.person.certified integerValue] == 0?@"未签约身份":@"已签约身份";
                    }else if([@"teacher" isEqualToString:d[@"character_type"]]){
                        _ct = (Teacher *)[d objectForKey:@"obj"];
                        _currentIdenStr = @"教练";
                        _nowIdentifer.text =[_cs.person.certified integerValue] == 0?@"未签约身份":@"已签约身份";
                        _signOrUnsignBtnText = [_ct.person.certified integerValue] == 0?@"取消申请":@"解除签约";
                    }else if([@"customerservice" isEqualToString:d[@"character_type"]]){
                        _cc = (CustomerService *)[d objectForKey:@"obj"];
                        _currentIdenStr = @"客服";
                        _nowIdentifer.text =[_cs.person.certified integerValue] == 0?@"未签约身份":@"已签约身份";
                        _signOrUnsignBtnText = [_cc.person.certified integerValue] == 0?@"取消申请":@"解除签约";
                    }else if([@"operation" isEqualToString:d[@"character_type"]]){
                        _co = (Operation *)[d objectForKey:@"obj"];
                        _currentIdenStr = @"运营";
                        _nowIdentifer.text =[_cs.person.certified integerValue] == 0?@"未签约身份":@"已签约身份";
                        _signOrUnsignBtnText = [_co.person.certified integerValue] == 0?@"取消申请":@"解除签约";
                    }
                    [self reloadView];
                }else{
                    [Utility showError:callback_data.message];
                }
                [_lv removeFromSuperview];
            }];

        }else{
            [Utility showError:callback_data.message];
            [_lv removeFromSuperview];
        }
    }];
}
/**重新刷新页面*/
-(void)reloadView{
    [super reloadView];
    UIView *rightItem =[HeaderView genItemWithText:_signOrUnsignBtnText target:self action:@selector(submitClick:) height:HEIGHT_HEAD_ITEM_DEFAULT];
    
    HeaderView* headView=[[HeaderView alloc]
                          initWithTitle:@"所有身份信息"
                          leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                          rightButton:rightItem
                          backgroundColor:COLOR_HEADER_BG
                          titleColor:COLOR_HEADER_TEXT
                          height:HEIGHT_HEAD_DEFAULT
                          ];
    [self.view addSubview:headView];
    
    
    //滚动部分
    _scrollView=[[UIScrollView alloc]init];
    [_scrollView fillSuperview:self.view underOf:headView];
    _scrollView.backgroundColor = UIColorFromRGB(0xebebeb);;
    _scrollView.bounces=false;
    
    //当前签约label
    CGRect firstSmallView = CGRectMake(0, 0, _scrollView.width, 20);
    _nowIdentifer = [self loadRowLabel:@"请选择身份" frame:firstSmallView];
    _nowIdentifer.top = 3;
    _nowIdentifer.height = _nowIdentifer.height+3;
    [_scrollView addSubview:_nowIdentifer];
    
    CGRect listLabelViewFrame;
    if (_cc || _co || _ct || _cs) {//如果有数据
//        _nowIdentifer.text = @"尚未签约身份";
        if (_cs) {
            _nowHeaderView = [self returnDic:_cs isLine:NO history:NO];
        }else if (_ct){
            _nowHeaderView = [self returnDic:_ct isLine:NO history:NO];
        }else if (_co){
            _nowHeaderView = [self returnDic:_co isLine:NO history:NO];
        }else{//_cc
            _nowHeaderView = [self returnDic:_cc isLine:NO history:NO];
        }
        _nowHeaderView.top = _nowIdentifer.bottom+3;
        
    }else{
        //如果没有当前身份
        NSDictionary *dic =  [[NSUserDefaults standardUserDefaults] objectForKey:PAGE_PARAM_UNCERTIFY];
        if (_school == nil) {
            _school = [School new];
            _school.id = [dic objectForKey:@"schoolid"];
            
        }
        if (![_character isEqualToString:[dic objectForKey:@"name"]] || dic == nil) {
            NSString *schoolname = _school.name;
            if (schoolname == nil ) {
                schoolname = @"";
            }
            dic =@{
                   @"name":_character,
                   @"schoolname":schoolname,
                   };
        }
        [self loadSelect:dic];
    }
    
    listLabelViewFrame = CGRectMake(0, _nowHeaderView.bottom+5, self.view.width, 20);
    [_scrollView addSubview:_nowHeaderView];
    //历史身份label
    _listLabelView = [self loadRowLabel:@"历史身份" frame:listLabelViewFrame];
    _listLabelView.top = _nowHeaderView.bottom;
    _listLabelView.left = 15;
    _listLabelView.height = _listLabelView.height+6;
    if (_dataList.count != 0) {//如果返回有身份
        if (_dataList.count == 1) {//如果只有一个身份
            if (!_cs || !_ct || !_co || !_cc) {//如果有当前身份
                [_scrollView addSubview:_listLabelView];
            }
        }
    }
    [_nowIdentifer fit];
    _nowIdentifer.left = 15;
    
    
    //创建遮罩
    _submitedMaskView=[[UIView alloc]init];
//    [_scrollView addSubview:_submitedMaskView];
    _submitedMaskView.backgroundColor=[UIColor whiteColor];
    _submitedMaskView.alpha=0.5;
    _submitedMaskView.origin=CGPointMake(_nowHeaderView.left, _nowHeaderView.top);
    _submitedMaskView.size=_nowHeaderView.size;
    _submitedMaskView.hidden=YES;
    if ([_signOrUnsignBtnText isEqualToString:@"取消申请"]) {
        _submitedMaskView.hidden=NO;
    }

    
    //for循环创建历史记录
    int judge = 0;
    for (int i = 0; i < _dataList.count ; ++i) {
        BaseObject *b = _dataList[i];
        NSLog(@"%@",b.id);
        //判断是否是正在使用的,如果不是则显示
        if ([b.id isEqualToString: _cs.id]||[b.id isEqualToString: _ct.id]||[b.id isEqualToString: _cc.id]||[b.id isEqualToString: _co.id]) {
            judge = 1;
        }else{
            BOOL isline = YES;
            if (i == _dataList.count || i == _dataList.count-1) {//这个地方的逻辑不清晰，判断是否有下方的线
                isline = NO;
            }
            UIView *view = [self returnDic:b isLine:isline history:YES];
            view.top = _listLabelView.bottom + (i-judge)* MYINFO_HEADER_HEIGHT;
            [_scrollView addSubview:view];
        }
    }
}
/** 传入model，返回信息view*/
-(UIView *)returnDic:(BaseObject*)model isLine:(BOOL)isLine history:(BOOL)history{
    NSDictionary *data;
    NSString *name;
    NSString *school;
    NSString *time;
    NSString *place;
    NSString *isSigned;
    NSString *img;
    if ([model isKindOfClass:[Student class]]) {//学员
        Student *s = (Student *)model;
        name =@"学员";
        school = s.school.name;
        time = s.createdate;
        place = s.school.area.namepath;
        isSigned = s.certified;
        img = s.person.imageurl;
    }else if ([model isKindOfClass:[Teacher class]]){//教练
        Teacher *s = (Teacher *)model;
        name =@"教练";
        school = s.school.name;
        time = s.createdate;
        place = s.school.area.namepath;
        isSigned = s.certified;
        img = s.person.imageurl;
    }else if ([model isKindOfClass:[CustomerService class]]){//客服
        CustomerService *s = (CustomerService *)model;
        name =@"客服";
        school = s.school.name;
        time = s.createdate;
        place = s.school.area.namepath;
        isSigned = s.certified;
        img = s.person.imageurl;
    }else{//运营
        Operation *s = (Operation *)model;
        name =@"运营";
        school = s.school.name;
        time = s.createdate;
        place = s.school.area.namepath;
        isSigned = s.certified;
        img = s.person.imageurl;
    }
    BOOL is = [isSigned isEqualToString:@"1"]?YES:NO;
    
    data = @{
            @"name":name,
            @"school":school,
            @"time":time,
            @"place":place,
            @"img":img,
            };
    return [self loadCellName:[data objectForKey:@"name"] school:[data objectForKey:@"school"] time:[data objectForKey:@"time"] place:[data objectForKey:@"place"] isSigned:is img:[data objectForKey:@"img"] isLine:isLine history:history];

}
/** 加载每一个历史信息的view */
-(UIView *)loadCellName:(NSString *)name school:(NSString *)school time:(NSString *)time place:(NSString *)place isSigned:(BOOL )isSigned img:(NSString *)img isLine:(BOOL)isLine history:(BOOL)history{
    UIView *ret = [[UIView alloc] init];
    ret.width = self.view.width;
    ret.height = MYINFO_HEADER_HEIGHT;
    ret.backgroundColor = [UIColor whiteColor];
    //头像
    CGFloat imgW = 57;
    UIImageView *i = [[UIImageView alloc] initWithFrame:CGRectMake(15, (ret.height-imgW)/2, imgW, imgW)];
    i.layer.cornerRadius = 5;
    //判断身份头像
    UIImage *im = [self getIdentiferHeadImage:name];
    i.image = im;
    [ret addSubview:i];
    
    //身份名称
    UILabel *l = [[UILabel alloc] init];
    l.text = name;
    [l fit];
    l.left = i.left*2+i.width;
    l.top = i.top;
    l.font = FONT_TEXT_NORMAL;
    [ret addSubview:l];
    //是否签约
    UIColor* stampColor=UIColorFromRGB(0x3aa5de);
    UILabel* creatifiedLabel;
    if (isSigned ) {
        creatifiedLabel =[UIUtility genStampLabelWithText:@"已签约" color:stampColor font:[UIFont fontWithName:FONT_TEXT_SECONDARY.familyName size:FONT_TEXT_SECONDARY.pointSize*0.8]];
    }else{
        creatifiedLabel =[UIUtility genStampLabelWithText:@"未签约" color:[UIColor redColor] font:[UIFont fontWithName:FONT_TEXT_SECONDARY.familyName size:FONT_TEXT_SECONDARY.pointSize*0.8]];
    }
    if (history != YES) {
        [ret addSubview:creatifiedLabel];
    }
    creatifiedLabel.centerY=l.centerY;
    creatifiedLabel.left=l.right+10;
    
    //驾校
    UILabel *s = [[UILabel alloc] init];
    s.text = school;
    [s fit];
    s.left = l.left;
    s.top = l.bottom + 5;
    s.textColor = [UIColor grayColor];
    s.font = [UIFont systemFontOfSize:15.0f];
    [ret addSubview:s];
    
    
    //时间
    UILabel *t = [[UILabel alloc] init];
    t.text = time;
    t.textAlignment = NSTextAlignmentRight;
    [t fit];
    t.top = i.top;
    t.left = ret.width - t.width -15;
    t.font = [UIFont systemFontOfSize:13.0f];
    t.textColor = [UIColor grayColor];
    [ret addSubview:t];
    
    
    //地区
    UILabel *p = [[UILabel alloc] init];
    p.text = place;
    p.textAlignment = NSTextAlignmentRight;
    [p fit];
    p.top = s.top;
    p.left = ret.width - p.width -15;
    p.font = [UIFont systemFontOfSize:13.0f];
    p.textColor = [UIColor grayColor];
    [ret addSubview:p];
    
    
    //横线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(i.left, ret.height-0.5, ret.width-30, 0.5)];
    line.backgroundColor = COLOR_SPLIT;
    if (isLine) {
        [ret addSubview:line];
        line.top=line.superview.height-line.height;
    }
    
    
    ret.height = line.bottom;
    return ret;
}
/** 加载选择身份和驾校的view */
-(void)loadSelect:(NSDictionary *)dic{
    NSString *name = [dic objectForKey:@"name"];
    if (name == nil || [name isEqualToString:@""]) {
        name = @"当前身份";
    }
    _currentIdenStr = name;
    NSString *schoolname = [dic objectForKey:@"schoolname"];
    if (schoolname == nil || [schoolname isEqualToString:@""]) {
        schoolname = @"无";
    }
    UIView *ret = [[UIView alloc] init];
    ret.backgroundColor = [UIColor whiteColor];
    ret.width=self.view.width;

    //初始化头像栏
    UIImageView* headImageView=[[UIImageView alloc] init];
    headImageView.contentMode=UIViewContentModeScaleAspectFit;
    headImageView.image = [self getIdentiferHeadImage:name];
    headImageView.size=CGSizeMake(57, 57);
   
    UIView * _headerView=[UIUtility genFeatureItemInSuperView:ret
                                                 top:0
                                               title:name
                                              height:MYINFO_HEADER_HEIGHT
                                            rightObj:headImageView
                                              target:self
                                              action:@selector(selectRole)
                                           showSplit:false
                 ];
    
    UILabel* schoolV_RightObj=[UIUtility genFeatureItemRightLabel];
    schoolV_RightObj.text = schoolname;
    [schoolV_RightObj fit];
    UIView* schoolV=[UIUtility genFeatureItemInSuperView:ret
                                                     top:_headerView.bottom
                                                   title:@"驾校"
                                                  height:FEATURE_NORMAL_HEIGHT
                                                rightObj:schoolV_RightObj
                                                  target:self
                                                  action:@selector(chooseSchool)
                                               showSplit:true];
    
    //线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(15, schoolV.bottom-1, ret.width-30, 0.5)];
    line.backgroundColor = COLOR_SPLIT;
    [ret addSubview:line];
    
    
    //注：****
    UILabel *z = [[UILabel alloc] init];
    z.text = @"注：签约用户将可以完整使用乐驾的所有功能！";
    [z fit];
    z.left = 15;
    z.top = schoolV.bottom+3;
    z.font = [UIFont systemFontOfSize:13.0f];
    z.textColor = [UIColor grayColor];
    [ret addSubview:z];
    
    
    ret.size = CGSizeMake(_headerView.width, _headerView.height+schoolV.height + z.height +15);
    
    _nowHeaderView = ret;
    CGSize si = _nowHeaderView.size;
    _nowHeaderView.frame = CGRectMake(0, _nowIdentifer.bottom, si.width, si.height);
    
//    if (_school == nil) {
//        _school = [School new];
//    }
//    NSDictionary *uncertify = @{
//                                @"name":name,
//                                @"schoolname":schoolname,
//                                @"schoolmodel":_school,
//                                };
//    NSLog(@"%@",uncertify);
//    [[NSUserDefaults standardUserDefaults] setObject:uncertify forKey:PAGE_PARAM_UNCERTIFY];
}
/** 加载灰色小字的view */
-(UILabel *)loadRowLabel:(NSString *)text frame:(CGRect)frame{
//    UIView *ret = [[UIView alloc] initWithFrame:frame];
//    ret.backgroundColor = UIColorFromRGB(0xebebeb);
    UILabel *ret =[Utility genLabelWithText:text
                                    bgcolor:nil
                                  textcolor:UIColorFromRGB(0x454545)
                                       font:FONT_TEXT_SECONDARY
                   ];
//    [ret addSubview:l];
//    l.top=3;
//    l.left=15;

    return ret;
}
/**返回头像*/
-(UIImage *)getIdentiferHeadImage:(NSString *)name{
    UIImage *im;
    if ([[Storage getLoginInfo].gender isEqualToString:@"1"]) {
        if ([name isEqualToString:@"学员"]) {
            im = [UIImage imageNamed:@"character_icon_学员_男"];
        }else if ([name isEqualToString:@"教练"]){
            im = [UIImage imageNamed:@"character_icon_教练_男"];
        }else if ([name isEqualToString:@"运营"]){
            im = [UIImage imageNamed:@"character_icon_运营_男"];
        }else if ([name isEqualToString:@"客服"]){
            im = [UIImage imageNamed:@"character_icon_客服_男"];
        }else{
            im = [UIImage imageNamed:@"缺省头像"];
        }
    }else{
        if ([name isEqualToString:@"学员"]) {
            im = [UIImage imageNamed:@"character_icon_学员_女"];
        }else if ([name isEqualToString:@"教练"]){
            im = [UIImage imageNamed:@"character_icon_教练_女"];
        }else if ([name isEqualToString:@"运营"]){
            im = [UIImage imageNamed:@"character_icon_运营_女"];
        }else  if ([name isEqualToString:@"客服"]){
            im = [UIImage imageNamed:@"character_icon_客服_女"];
        }else{
            im = [UIImage imageNamed:@"缺省头像"];
        }
    }
    return im;
}
/** 提交按钮点击 */
-(void)submitClick:(UIButton *)sender{
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    if ([_signOrUnsignBtnText isEqualToString:@"取消申请"]) {
        _signOrUnsignBtnText = @"提交申请";
        _submitedMaskView.hidden = NO;
        //发送网络请求---取消申请
        NSDictionary *lastIden ;
        if ([_currentIdenStr isEqualToString:@"学员"]) {
            lastIden = @{@"name":_currentIdenStr,@"schoolname":_cs.school.name,@"schoolid":_cs.school.id};
            [Remote deleteStudent:_cs.id callback:^(StorageCallbackData *callback_data) {
                [self getData];
            }];
        }else if ([_currentIdenStr isEqualToString:@"教练"]) {
            lastIden = @{@"name":_currentIdenStr,@"schoolname":_ct.school.name,@"schoolid":_ct.school.id};
            [Remote deleteTeacher:_ct.id callback:^(StorageCallbackData *callback_data) {
                [self getData];
            }];
        }else if ([_currentIdenStr isEqualToString:@"运营"]) {
            lastIden = @{@"name":_currentIdenStr,@"schoolname":_co.school.name,@"schoolid":_co.school.id};
            [Remote deleteOperation:_co.id callback:^(StorageCallbackData *callback_data) {
                [self getData];
            }];
        }else if ([_currentIdenStr isEqualToString:@"客服"]) {//客服
            lastIden = @{@"name":_currentIdenStr,@"schoolname":_cc.school.name,@"schoolid":_cc.school.id};
            [Remote deleteCustomerService:_cc.id callback:^(StorageCallbackData *callback_data) {
                [self getData];
            }];
        }
        [[NSUserDefaults standardUserDefaults] setObject:lastIden forKey:PAGE_PARAM_UNCERTIFY];
            _cc = nil;
            _co = nil;
            _cs = nil;
            _ct = nil;
    }else if([_signOrUnsignBtnText isEqualToString:@"提交申请"]){
        _submitedMaskView.hidden = YES;
        //发送网络请求---提交申请
        NSLog(@"%@",_currentIdenStr);
        if (![_currentIdenStr isEqualToString:@""] && _school.id != nil) {
            _signOrUnsignBtnText = @"取消申请";
            if ([_currentIdenStr isEqualToString:@"学员"]) {
                [Remote createStudent:[Storage getLoginInfo].id schoolid:_school.id status:@"" signupdate:@"" km1score:@"" km2score:@"" km3ascore:@"" km3bscore:@"" licencedate:@"" callback:^(StorageCallbackData *callback_data) {
                    if (callback_data.code == 0) {
                        _cs = callback_data.data;
                        [self setAvailableCharacter:_cs];
                    }
                }];
            }else if ([_currentIdenStr isEqualToString:@"教练"]) {
                [Remote createTeacher:[Storage getLoginInfo].id schoolid:_school.id skills:@"" callback:^(StorageCallbackData *callback_data) {
                    if (callback_data.code == 0) {
                        _ct = callback_data.data;
                        [self setAvailableCharacter:_ct];
                    }
                }];
            }else if ([_currentIdenStr isEqualToString:@"运营"]) {
                [Remote createOperation:[Storage getLoginInfo].id schoolid:_school.id callback:^(StorageCallbackData *callback_data) {
                    if (callback_data.code == 0) {
                        _co = callback_data.data;
                        [self setAvailableCharacter:_co];
                    }
                }];
            }else if ([_currentIdenStr isEqualToString:@"客服"]) {//客服
                [Remote createCustomerService:[Storage getLoginInfo].id schoolid:_school.id callback:^(StorageCallbackData *callback_data) {
                    if (callback_data.code == 0) {
                        _cc = callback_data.data;
                        [self setAvailableCharacter:_cc];
                    }
                }];
            }
        }else{
            [Utility showError:@"请完善身份和驾校信息"];
        }
        
        
    }else if ([_signOrUnsignBtnText isEqualToString:@"解除签约"]){
        if (_cs) {
            [Remote deleteStudent:_cs.id callback:^(StorageCallbackData *callback_data) {
                _cs = nil;
                [self getData];
                [self reloadView];
            }];
        }else if (_ct) {
            [Remote deleteTeacher:_ct.id callback:^(StorageCallbackData *callback_data) {
                _ct = nil;
                [self getData];
                [self reloadView];
            }];
        }else if (_co) {
            [Remote deleteOperation:_co.id callback:^(StorageCallbackData *callback_data) {
                _co = nil;
                [self getData];
                [self reloadView];
            }];
        }else if (_cc) {//客服
            [Remote deleteCustomerService:_cc.id callback:^(StorageCallbackData *callback_data) {
                _cc =nil;
                [self getData];
                [self reloadView];
            }];
        }

        
        [self getData];
        [self reloadView];
    }
    [lv removeFromSuperview];
}
/** 传入身份，设置available*/
-(void)setAvailableCharacter:(BaseObject*)character{
//    NSString* personid=nil;
//    if([character isKindOfClass:[Student class]]){
//        personid=((Student*)character).person.id;
//    }else if([character isKindOfClass:[Teacher class]]){
//        personid=((Teacher*)character).person.id;
//    }else if([character isKindOfClass:[CustomerService class]]){
//        personid=((CustomerService*)character).person.id;
//    }else if([character isKindOfClass:[Operation class]]){
//        personid=((Operation*)character).person.id;
//    }
//    
//    if(personid!=nil){
//        [Remote setAvailableCharacter:personid character:character callback:^(StorageCallbackData *callback_data) {
//            if(callback_data.code!=0){
//                [Utility showError:callback_data.message];
//            }
//        }];
//    }
    [self getData];
    [self reloadView];
}
#pragma mark 选择身份点击
-(void)selectRole{
    NSLog(@"%s",__func__);
    [self gotoPageWithClass:[ChangeCharacterVC class] parameters:@{
                                                                   PAGE_PARAM_PERSON:[Storage getLoginInfo],
                                                                   }];
}
-(void)chooseSchool{
    NSLog(@"%s",__func__);
    [self gotoPageWithClass:[SearchSchoolVC class] parameters:@{
                                                                PAGE_PARAM_BACK_CLASS:[self class],
                                                                }];
}
-(void)putValue:(id)value byKey:(NSString *)key{
    
    if ([PAGE_PARAM_SCHOOL isEqualToString:key]) {
        _school = value;
    }
    else if ([@"CHOOSED_CHARACTER" isEqualToString:key]){//角色
        _character = value;
    }
    [self reloadView];
}
@end
