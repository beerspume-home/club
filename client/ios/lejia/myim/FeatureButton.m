//
//  FeatureButton.m
//  myim
//
//  Created by Sean Shi on 15/11/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "FeatureButton.h"

#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SPLIT_HEIGHT 0.5

@interface FeatureButton(){
    UIView* _rootView;
    UILabel* _titleLabel;
    UILabel* _rightLabel;
    UIView* _splitView;
    NSString* _rightText;
    
}
@end

@implementation FeatureButton
//
//-(void)reloadView{
//    //信息栏
//    if(_rootView==nil){
//        _rootView=[[UIView alloc]init];
//        [_superview addSubview:_rootView];
//    }
//    _rootView.backgroundColor=COLOR_FEATURE_BAR_BG;
//    [_rootView setFrame:CGRectMake(0, _top, _rootView.superview.width, _height)];
//    //信息栏文字
//    if(_titleLabel==nil){
//        _titleLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_titleLabel];
//    }
//    _titleLabel.backgroundColor=[UIColor clearColor];
//    _titleLabel.textColor=COLOR_TEXT_NORMAL;
//    _titleLabel.font=FONT_TEXT_NORMAL;
//    _titleLabel.text=_title;
//    _titleLabel.numberOfLines=0;
//    [Utility fitLabel:_titleLabel usePadding:true];
//    _titleLabel.textAlignment=NSTextAlignmentLeft;
//    UILabel* tmpLabel=[Utility genLabelWithText:@"一行" bgcolor:nil textcolor:nil font:_titleLabel.font];
//    [Utility fitLabel:tmpLabel usePadding:true];
//    _rootView.height=_titleLabel.height+(_height-tmpLabel.height);
//    _titleLabel.left=PADDING_LEFT;
//    _titleLabel.centerY=_titleLabel.superview.height/2;
//    
//    if(_rightLabel==nil){
//        _rightLabel=[[UILabel alloc]init];
//        [_rootView addSubview:_rightLabel];
//        _rightLabel.textColor=COLOR_TEXT_SECONDARY;
//        _rightLabel.font=FONT_TEXT_SECONDARY;
//    }
//    //右边内容
//    _rightLabel.text=_rightText;
//    [Utility fitLabel:_rightLabel usePadding:true];
//    _rightLabel.numberOfLines=0;
//    _rightLabel.textAlignment=NSTextAlignmentLeft;
//    if(_rightLabel.width>_rightLabel.superview.width*0.5){
//        _rightLabel.width=_rightLabel.superview.width*0.5;
//    }
//    _rootView.height=_rightLabel.height+20>_rootView.height?_rightLabel.height+20:_rootView.height;
//    _rightLabel.right=_rightLabel.superview.width-PADDING_RIGHT;
//    _rightLabel.centerY=_rightLabel.superview.height/2;
//    
//    //分割线
//    if(_showSplit){
//        if(_splitView==nil){
//            _splitView=[[UIView alloc]init];
//            [_rootView addSubview:_splitView];
//        }
//        _splitView.hidden=false;
//        _splitView.backgroundColor=COLOR_SPLIT;
//        _splitView.size=CGSizeMake(_splitView.superview.width-PADDING_LEFT-PADDING_RIGHT, SPLIT_HEIGHT);
//        _splitView.top=0;
//        _splitView.centerX=_splitView.superview.width/2;
//    }else{
//        if(_splitView!=nil){
//            _splitView.hidden=true;
//        }
//    }
//}
//
//-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
//    return [self initSelectInSuperView:superview
//                                   top:top
//                                 title:title
//                                 value:value
//                                height:height
//                                target:nil
//                                action:nil
//                             showSplit:showSplit
//                                  dict:dict
//                           mutliSelect:mutliSelect];
//}
//-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
//    return [self initInSuperView:superview
//                             top:top
//                           title:title
//                           value:value
//                          height:height
//                          target:target
//                          action:action
//                       showSplit:showSplit
//                       inputType:nil
//                            dict:dict
//                     mutliSelect:mutliSelect];
//}
//-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit inputType:(NSString*)inputType{
//    return [self initInputInSuperView:superview
//                                  top:top
//                                title:title
//                                value:value
//                               height:height
//                               target:nil
//                               action:nil
//                            showSplit:showSplit
//                            inputType:inputType];
//}
//-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType{
//    return [self initInSuperView:superview
//                             top:top
//                           title:title
//                           value:value
//                          height:height
//                          target:target
//                          action:action
//                       showSplit:showSplit
//                       inputType:inputType
//                            dict:nil
//                     mutliSelect:false];
//}
//
//
//-(instancetype)initInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect{
//    FeatureItem* ret=[super init];
//    _title=title;
//    _rightValue=value;
//    _superview=superview;
//    _top=top;
//    _height=height;
//    _target=target;
//    _action=action;
//    _showSplit=showSplit;
//    _inputType=inputType;
//    _rightDict=dict;
//    _mutliSelect=mutliSelect;
//    [ret reloadView];
//    [ret setGestureRecognizer];
//    [ret refreshRightText];
//    return ret;
//    
//}
//
//

@end
