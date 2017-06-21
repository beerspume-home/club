//
//  FeatureItem.m
//  myim
//
//  Created by Sean Shi on 15/11/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "FeatureItem.h"

#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SPLIT_HEIGHT 0.5

@interface FeatureItem()<ChangeValueDelegate,SelectDictDataDelegate,DatePickerDelegate>{
    UIView* _rootView;
    UILabel* _titleLabel;
    UILabel* _rightLabel;
    UISwitch* _rightSwitch;
    UIView* _splitView;
    
    BOOL _inited;
    
    NSString* _emptyText;
}
@end

@implementation FeatureItem
-(void)changeValue:(ChangeValueVC *)changeValueVC valueDidChanged:(NSString *)value{
    _rightValue=value;
    [self refreshRightText];
    if(_delegate!=nil){
        [_delegate featureItem:self didValueChange:_rightValue];
    }
}
-(void)selectDictData:(SelectDictDataVC *)selectDictDataVC valueDidChanged:(NSArray<Dict *> *)value inDataList:(NSArray<Dict *> *)dataList{
    if(dataList!=nil && dataList.count>0){
        _rightDict=dataList;
    }
    NSString* retValue=@"";
    if(value!=nil){
        for(int i=0;i<value.count;i++){
            retValue=[retValue stringByAppendingFormat:(i==0?@"%@":@",%@"),value[i].value];
        }
    }
    _rightValue=retValue;
    [self refreshRightText];
    if(_delegate!=nil){
        [_delegate featureItem:self didValueChange:_rightValue];
    }
    
}
-(void)datePicker:(DatePicker *)datePicker valueChanged:(NSDate *)date{
    if(date!=nil){
        _rightValue=date.formatedString;
        [self refreshRightText];
        if(_delegate!=nil){
            [_delegate featureItem:self didValueChange:_rightValue];
        }
    }
}

-(void)switchChange:(UISwitch*)sender{
    _rightValue=[sender isOn]?@"1":@"0";
    if(_delegate!=nil){
        [_delegate featureItem:self didValueChange:_rightValue];
    }
}

-(void)changeValue:(UIGestureRecognizer*)sender{
    if([_inputType isEqualToString:CHANGEVALUE_INPUTTYPE_Date]){
        [[DatePicker sharedDatePicker] show:self];
    }else{
        AController* vc=(AController*)[_rootView nextResponder];
        while(vc!=nil && ![vc isKindOfClass:[AController class]]){
            vc=(AController*)[vc nextResponder];
        }
        if(vc!=nil){
            if(_rightDict==nil){
                [vc gotoPageWithClass:[ChangeValueVC class] parameters:@{
                                                                   PAGE_PARAM_TITLE:_title,
                                                                   PAGE_PARAM_EXPLAIN:@"",
                                                                   PAGE_PARAM_PLACEHOLDER:@"",
                                                                   PAGE_PARAM_ORIGIN_VALUE:_rightValue==nil?@"":_rightValue,
                                                                   PAGE_PARAM_TYPE:@"changeValue",
                                                                   PAGE_PARAM_INPUTTYPE:_inputType,
                                                                   PAGE_PARAM_DELEGATE:self,
                                                                   }];
            }else{
                NSArray<NSString*>* originValue = _rightValue==nil?[NSArray array]:[_rightValue componentsSeparatedByString:@","];
                NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:
                                            @{
                                              PAGE_PARAM_TITLE:_title,
//                                         PAGE_PARAM_DICTNAME:@"",
                                             PAGE_PARAM_TYPE:@"",
                                     PAGE_PARAM_ORIGIN_VALUE:originValue,
//                                             PAGE_PARAM_DATA:_rightDict,
                                              PAGE_PARAM_DELEGATE:self,}];
                if(_mutliSelect){
                    [param setObject:@"1" forKey:PAGE_PARAM_MUTILSELECT];
                }
                if(_rightDict.count==1 && [Utility isEmptyString:_rightDict[0].value]){
                    [param setObject:_rightDict[0].name forKey:PAGE_PARAM_DICTNAME];
                }else{
                  [param setObject:_rightDict forKey:PAGE_PARAM_DATA];
                }
                
                
                [vc gotoPageWithClass:[SelectDictDataVC class] parameters:param];

            }
        }
    }
}
//根据字典更新内容
-(void)refreshRightText{
    if(_rightDict!=nil){
        _rightText=[Utility descInDict:_rightDict fromValue:_rightValue];
    }else{
        _rightText=_rightValue;
    }
    [self reloadView];
}
-(void)setGestureRecognizer{
    if([FEATURE_INPUTTYPE_Switch isEqualToString:_inputType]){
        [_rootView removeAllGestureRecognizer];
    }else{
        [_rootView setGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:_target action:_action]];
    }
}

-(UIView*)view{
    return _rootView;
}

-(void)setTitle:(NSString*)value{
    _title=value;
    [self reloadView];
}
-(void)setRightValue:(NSString*)value{
    _rightValue=value;
    [self refreshRightText];
}
-(NSString*)getRightValue{
    if(_rightValue==nil){
        _rightValue=@"";
    }
    return _rightValue;
}
-(void)setRightDict:(NSArray<Dict*>*)value{
    _rightDict=value;
    [self refreshRightText];
}
-(void)setHeight:(CGFloat)value{
    _height=value;
    [self reloadView];
}
-(void)setTop:(CGFloat)value{
    _top=value;
    [self reloadView];
}
-(void)setSuperview:(UIView*)value{
    _superview=value;
    [self reloadView];
}
-(void)setTarget:(id)value{
    _target=value;
    [self setGestureRecognizer];
}
-(void)setAction:(SEL)value{
    _action=value;
    [self setGestureRecognizer];
}
-(void)setShowSplit:(BOOL)value{
    _showSplit=value;
    [self reloadView];
}


-(void)reloadView{
    if(_rightDict==nil){
        _emptyText=@"请点击输入";
    }else{
        _emptyText=@"请点击选择";
    }
    
    CGFloat realTop=_rootView.top;
    if(!_inited){
        realTop=_top;
        _inited=true;
    }
    
    //信息栏
    if(_rootView==nil){
        _rootView=[[UIView alloc]init];
        [_superview addSubview:_rootView];
    }
    _rootView.backgroundColor=COLOR_FEATURE_BAR_BG;
    [_rootView setFrame:CGRectMake(0, realTop, _rootView.superview.width, _height)];
    //信息栏文字
    if(_titleLabel==nil){
        _titleLabel=[[UILabel alloc]init];
        [_rootView addSubview:_titleLabel];
    }
    _titleLabel.backgroundColor=[UIColor clearColor];
    _titleLabel.textColor=COLOR_TEXT_NORMAL;
    _titleLabel.font=FONT_TEXT_NORMAL;
    _titleLabel.text=_title;
    _titleLabel.numberOfLines=0;
    [Utility fitLabel:_titleLabel usePadding:true];
    _titleLabel.textAlignment=NSTextAlignmentLeft;
    UILabel* tmpLabel=[Utility genLabelWithText:@"一行" bgcolor:nil textcolor:nil font:_titleLabel.font];
    [Utility fitLabel:tmpLabel usePadding:true];
    _rootView.height=_titleLabel.height+(_height-tmpLabel.height);
    _titleLabel.left=PADDING_LEFT;
    _titleLabel.centerY=_titleLabel.superview.height/2;
    
    if([FEATURE_INPUTTYPE_Switch isEqualToString:_inputType]){
        if(_rightSwitch==nil){
            _rightSwitch=[[UISwitch alloc]init];
            [_rightSwitch addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            [_rootView addSubview:_rightSwitch];
        }
        [_rightSwitch setOn:[@"1" isEqualToString:_rightValue]];
        _rightSwitch.right=_rightSwitch.superview.width-PADDING_RIGHT;
        _rightSwitch.centerY=_rightSwitch.superview.height/2;
    }else{
        if(_rightLabel==nil){
            _rightLabel=[[UILabel alloc]init];
            [_rootView addSubview:_rightLabel];
            _rightLabel.textColor=COLOR_TEXT_SECONDARY;
            _rightLabel.font=FONT_TEXT_SECONDARY;
        }
        //右边内容
        _rightLabel.text=[Utility isEmptyString:_rightText]?_emptyText:_rightText;
        [Utility fitLabel:_rightLabel usePadding:false];
        _rightLabel.numberOfLines=0;
        _rightLabel.textAlignment=NSTextAlignmentLeft;
        if(_rightLabel.width>_rightLabel.superview.width*0.5){
            _rightLabel.width=_rightLabel.superview.width*0.5;
        }
        if(_fitRightContent){//是否自适应右侧文字内容
            CGSize rightSize=getStringSizeLimitWithWidth(_rightLabel.text, _rightLabel.font, _rightLabel.width);
            tmpLabel=[Utility genLabelWithText:@"一行" bgcolor:nil textcolor:nil font:_rightLabel.font];
            [Utility fitLabel:tmpLabel usePadding:false];
            CGFloat rightHeight=rightSize.height+(_height-tmpLabel.height);
            _rootView.height=_rootView.height>=rightHeight?_rootView.height:rightHeight;
            _rightLabel.size=rightSize;
            _rightLabel.centerY=_rootView.height/2;
        }

        
        _rootView.height=_rightLabel.height+20>_rootView.height?_rightLabel.height+20:_rootView.height;
        _rightLabel.right=_rightLabel.superview.width-PADDING_RIGHT;
        _rightLabel.centerY=_rightLabel.superview.height/2;
    }
    //分割线
    if(_showSplit){
        if(_splitView==nil){
            _splitView=[[UIView alloc]init];
            [_rootView addSubview:_splitView];
        }
        _splitView.hidden=false;
        _splitView.backgroundColor=COLOR_SPLIT;
        _splitView.size=CGSizeMake(_splitView.superview.width-PADDING_LEFT-PADDING_RIGHT, SPLIT_HEIGHT);
        _splitView.top=0;
        _splitView.centerX=_splitView.superview.width/2;
    }else{
        if(_splitView!=nil){
            _splitView.hidden=true;
        }
    }
}

-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
    return [self initSelectInSuperView:superview
                             top:top
                           title:title
                           value:value
                          height:height
                          target:self
                        action:@selector(changeValue:)
                       showSplit:showSplit
                            dict:dict
                     mutliSelect:mutliSelect];
}
-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
    return [self initInSuperView:superview
                             top:top
                           title:title
                           value:value
                          height:height
                          target:target
                          action:action
                       showSplit:showSplit
                       inputType:nil
                            dict:dict
                     mutliSelect:mutliSelect];
}
-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit inputType:(NSString*)inputType{
    return [self initInputInSuperView:superview
                             top:top
                           title:title
                           value:value
                          height:height
                          target:self
                          action:@selector(changeValue:)
                       showSplit:showSplit
                       inputType:inputType];
}
-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType{
    return [self initInSuperView:superview
                             top:top
                           title:title
                           value:value
                          height:height
                          target:target
                          action:action
                       showSplit:showSplit
                       inputType:inputType
                            dict:nil
                     mutliSelect:false];
}

-(instancetype)initSwitchInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(BOOL)value height:(CGFloat)height showSplit:(BOOL)showSplit{
    return [self initInputInSuperView:superview
                           top:top
                         title:title
                         value:value?@"1":@"0"
                        height:height
                     showSplit:showSplit
                     inputType:FEATURE_INPUTTYPE_Switch];
}

-(instancetype)initInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
    FeatureItem* ret=[super init];
    _title=title;
    _rightValue=value;
    _superview=superview;
    _top=top;
    _height=height;
    _target=target;
    _action=action;
    _showSplit=showSplit;
    _inputType=inputType;
    _rightDict=dict;
    _mutliSelect=mutliSelect;
    _fitRightContent=true;
    [ret reloadView];
    [ret setGestureRecognizer];
    [ret refreshRightText];
    return ret;

}



@end
