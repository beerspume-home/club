//
//  HeaderView.m
//  myim
//
//  Created by Sean Shi on 15/10/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "HeaderView.h"
#define EDGE 12.5
#define SYSTEM_BAR_HEIGHT 20.0

@interface HeaderView(){
    UIView* _toolbar;
    BOOL _isChanged;
}

@end

@implementation HeaderView

-(void)initHeader{
    [self setFrame:CGRectMake(0, 0, 10, _headHeight)];
    _isChanged=true;
}
-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton {
    return [self initWithTitle:title leftButton:leftButton rightButton:rightButton backgroundColor:COLOR_HEADER_BG titleColor:COLOR_HEADER_TEXT height:64];
}

-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton backgroundColor:(nullable UIColor*)backgroundColor titleColor:(nullable UIColor*)titleColor {
    return [self initWithTitle:title leftButton:leftButton rightButton:rightButton backgroundColor:backgroundColor titleColor:titleColor height:64];
}
-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton backgroundColor:(nullable UIColor*)backgroundColor titleColor:(nullable UIColor*)titleColor height:(CGFloat)height{
    
    HeaderView* ret=[self init];
    ret.leftBarItem=leftButton;
    ret.rightBarItem=rightButton;
    ret.backgroundColor=backgroundColor;
    ret.titleColor=titleColor;
    ret.title=title;
    ret.headHeight=height;
    [ret initHeader];
    return ret;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    [self initHeader];
    return [super initWithCoder:aDecoder];
}
-(instancetype)initWithFrame:(CGRect)frame{
    [self initHeader];
    return [super initWithFrame:frame];
}

-(void)setFrame:(CGRect)frame{
    _isChanged=true;
    [super setFrame:frame];
}

- (void)layoutSubviews{
    if(_isChanged){
        
        for(UIView* v in self.subviews){
            [v removeFromSuperview];
        }
        
        CGFloat maxWidth=0;
        if(self.superview!=nil){
            maxWidth=self.superview.width;
        }
        [self setFrame:CGRectMake(0, 0, maxWidth,_headHeight)];
        if(_toolbar==nil){
            _toolbar=[[UIView alloc]initWithFrame:CGRectMake(0, SYSTEM_BAR_HEIGHT, maxWidth,_headHeight-SYSTEM_BAR_HEIGHT)];
            _toolbar.clipsToBounds=true;//去掉边界的线条
            _toolbar.backgroundColor=self.backgroundColor;
        }
        [self addSubview:_toolbar];
        for(UIView* v in _toolbar.subviews){
            [v removeFromSuperview];
        }
        [_toolbar setFrame:CGRectMake(0, SYSTEM_BAR_HEIGHT, maxWidth,_headHeight-SYSTEM_BAR_HEIGHT)];
        UIFont* titleFont=FONT_HEAD_TITLE;
        CGSize size=getStringSize(_title, titleFont);
//        if(size.width>self.width*0.5){
//            size.width=self.width*0.5;
//        }
        UILabel* titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        titleLabel.text=_title;
        titleLabel.font=titleFont;
        titleLabel.textColor=_titleColor;
        [_toolbar addSubview:titleLabel];
        titleLabel.center=titleLabel.superview.innerCenterPoint;
        
        if(_leftBarItem!=nil){
            [_toolbar addSubview:_leftBarItem];
            _leftBarItem.tintColor=_titleColor;
            _leftBarItem.left=0;
            _leftBarItem.centerY=_leftBarItem.superview.height/2;
            
        }
        if(_rightBarItem!=nil){
            [_toolbar addSubview:_rightBarItem];
            _rightBarItem.tintColor=_titleColor;
            _rightBarItem.right=_rightBarItem.superview.width;
            _rightBarItem.centerY=_rightBarItem.superview.height/2;
            
        }
        
        
        _isChanged=false;
    }
    
}

-(void)setRightBarItem:(UIView *)rightBarItem{
    _rightBarItem=rightBarItem;
    _isChanged=true;
    [self setNeedsLayout];
//    [self layoutIfNeeded];
}
-(void)setLeftBarItem:(UIView *)leftBarItem{
    _leftBarItem=leftBarItem;
    _isChanged=true;
    [self setNeedsLayout];
//    [self layoutIfNeeded];
}
-(void)setTitle:(NSString *)title{
    _title=title;
    _isChanged=true;
    [self setNeedsLayout];
}


+(nonnull UIView*) genItemWithType:(HeaderItemType)type target:(nullable id)target action:(nullable SEL)action{
    return [HeaderView genItemWithType:type target:target action:action height:44.0];
}
+(UIView*) genItemWithType:(HeaderItemType)type target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height;{
    UIView* customView=nil;
    CGFloat iconSize=height/2;
    iconSize=iconSize<22?(22>height?height:22):iconSize;
    switch(type){
        case HeaderItemType_Back:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
            UIImageView *backImg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"返回_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
            backImg.frame = CGRectMake(EDGE, (height-iconSize)/2, iconSize, iconSize);
            [customView addSubview:backImg];
            break;
        }
        case HeaderItemType_Add:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
            UIImageView *backImg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"添加_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
            [customView addSubview:backImg];
            backImg.frame = CGRectMake(0, (height-iconSize)/2, iconSize, iconSize);
            backImg.right=backImg.superview.width-EDGE;
            break;
        }
        case HeaderItemType_Save:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, height*1.0+EDGE, height*0.6)];
            customView.backgroundColor=[UIColor clearColor];
            
            UILabel* textLabel=[[UILabel alloc]init];
            [customView addSubview:textLabel];
            textLabel.text=@"保存";
            textLabel.font=FONT_HEAD_TITLE;
            [Utility fitLabel:textLabel];
            textLabel.textColor=[UIColor whiteColor];
            textLabel.center=customView.innerCenterPoint;
            textLabel.right-=EDGE;
            break;
        }
        case HeaderItemType_Ok:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, height*1.0+EDGE, height*0.6)];
            customView.backgroundColor=[UIColor clearColor];
            
            UILabel* textLabel=[[UILabel alloc]init];
            [customView addSubview:textLabel];
            textLabel.text=@"确定";
            textLabel.font=FONT_HEAD_TITLE;
            [Utility fitLabel:textLabel];
            textLabel.textColor=[UIColor whiteColor];
            textLabel.center=customView.innerCenterPoint;
            textLabel.right-=EDGE;
            break;
        }
        case HeaderItemType_New:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, height*1.0+EDGE, height*0.6)];
            customView.backgroundColor=[UIColor clearColor];
            
            UILabel* textLabel=[[UILabel alloc]init];
            [customView addSubview:textLabel];
            textLabel.text=@"新建";
            textLabel.font=FONT_HEAD_TITLE;
            [Utility fitLabel:textLabel];
            textLabel.textColor=[UIColor whiteColor];
            textLabel.center=customView.innerCenterPoint;
            textLabel.right-=EDGE;
            break;
        }
        case HeaderItemType_Person:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
            UIImageView *backImg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"单人_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
            [customView addSubview:backImg];
            backImg.frame = CGRectMake(0, (height-iconSize)/2, iconSize, iconSize);
            backImg.right=backImg.superview.width-EDGE;
            break;
        }
        case HeaderItemType_People:{
            customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, height)];
            UIImageView *backImg = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"多人_icon"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
            [customView addSubview:backImg];
            backImg.frame = CGRectMake(0, (height-iconSize)/2, iconSize, iconSize);
            backImg.right=backImg.superview.width-EDGE;
            break;
        }
    }
    
    [customView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:target action:action]];
    return customView;
    
}

+(nonnull UIView*) genItemWithText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action{
    return [HeaderView genItemWithText:text target:target action:action height:44.0];
}

+(nonnull UIView*) genItemWithText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height{
    UIView* customView=nil;
    CGFloat iconSize=height/2;
    iconSize=iconSize<22?(22>height?height:22):iconSize;

    customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, height*1.0+EDGE, height*0.6)];
    customView.backgroundColor=[UIColor clearColor];
    
    UILabel* textLabel=[[UILabel alloc]init];
    [customView addSubview:textLabel];
    textLabel.text=text;
    textLabel.font=FONT_HEAD_TITLE;
    textLabel.textColor=COLOR_HEADER_TEXT;
    [Utility fitLabel:textLabel];
    CGFloat needWith=textLabel.width+EDGE*2;
    customView.width=needWith>customView.width?needWith:customView.width;

    textLabel.center=customView.innerCenterPoint;
    
    
    [customView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:target action:action]];
    return customView;
    
}

+(nonnull UIView*) genItemWithIcon:(UIImage*)image andText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height{
    UIView* customView=nil;
    
    customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, height*1.0+EDGE, height*0.6)];
    customView.backgroundColor=[UIColor clearColor];

    CGFloat iconSize=height/2;
    iconSize=iconSize<22?(22>height?height:22):iconSize;
    UIImageView *icomImage = [[UIImageView alloc] initWithImage:[image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate ]];
    icomImage.frame = CGRectMake(EDGE, (height-iconSize)/2, iconSize, iconSize);
    icomImage.tintColor=COLOR_HEADER_TEXT;
    [customView addSubview:icomImage];
    icomImage.left=12;
    icomImage.centerY=icomImage.superview.height/2;

    
    UILabel* textLabel=[[UILabel alloc]init];
    [customView addSubview:textLabel];
    textLabel.text=text;
    textLabel.font=FONT_HEAD_TITLE;
    textLabel.textColor=COLOR_HEADER_TEXT;
    [Utility fitLabel:textLabel];
    CGFloat needWith=textLabel.width+EDGE*2;
    customView.width=needWith>customView.width?needWith:customView.width;
    
    textLabel.left=icomImage.right+5;
    textLabel.centerY=icomImage.centerY;
    
    [customView fitWidthOfSubviews];
    
    [customView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:target action:action]];
    return customView;
    
}


@end
