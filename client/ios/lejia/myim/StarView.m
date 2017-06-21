//
//  StarView.m
//  myim
//
//  Created by Sean Shi on 15/12/6.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "StarView.h"

@interface StarView(){
    NSMutableArray<UIImageView*>* _starViews;
    
    UIImage* _imageEmpty;
    UIImage* _imageFull;
    UIImage* _imageHalf;
}

@end
@implementation StarView
-(instancetype)init{
    StarView* ret=[super init];
    _imageEmpty=[UIImage imageNamed:@"icon_星星_空"];
    _imageFull=[UIImage imageNamed:@"icon_星星_满"];
    _imageHalf=[UIImage imageNamed:@"icon_星星_半"];
    _iconSize=10;
    _iconPadding=2;
    return ret;
}

-(void)setEditable:(BOOL)editable{
    _editable=editable;
    if(_editable){
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)]];
    }else{
        for(UIGestureRecognizer* g in self.gestureRecognizers){
            [self removeGestureRecognizer:g];
        }
    }
    
}
-(void)setIconPadding:(CGFloat)iconPadding{
    _iconPadding=iconPadding;
    [self setNeedsLayout];
}
-(void)setIconSize:(CGFloat)iconSize{
    _iconSize=iconSize;
    [self setNeedsLayout];
}
-(void)setMaxvalue:(NSUInteger)maxvalue{
    _maxvalue=maxvalue;
    [self setNeedsLayout];
}
-(void)setValue:(float)value{
    _value=value;
    [self setNeedsLayout];
}

-(void)reloadData{
    if(_starViews==nil){
        _starViews=[Utility initArray:nil];
    }
    for(int i=_starViews.count;i<_maxvalue;i++){
        [_starViews addObject:[[UIImageView alloc]init]];
        _starViews[i].tag=i;
    }
    if(_maxvalue==0){
        [_starViews removeAllObjects];
    }else{
        while(_starViews.count>_maxvalue){
            [_starViews removeLastObject];
        }
    }
}

-(void)reloadView{
    [Utility cleanView:self];
    if(_starViews==nil || _starViews.count!=_maxvalue){
        [self reloadData];
    }
    for(int i=0;i<_maxvalue;i++){
        if(i<_value-1){
            _starViews[i].image=_imageFull;
        }else{
            float lastValue=_value-i>0?(_value-i	):0;
            if(lastValue>=0 && (_value-i<0.4)){
                _starViews[i].image=_imageEmpty;
            }else if(lastValue<0.8){
                _starViews[i].image=_imageHalf;
            }else{
                _starViews[i].image=_imageFull;
            }
        }
        [self addSubview:_starViews[i]];
        _starViews[i].size=(CGSize){_iconSize,_iconSize};
        _starViews[i].origin=(CGPoint){i*(_iconSize+_iconPadding),0};
    }
    [self fitSizeOfSubviews];
}
-(void)layoutSubviews{
    [self reloadView];
}

-(void)tap:(UIGestureRecognizer*)sender{
    if(_editable){
        CGPoint p=[sender locationInView:self];
        int index=-1;
        for(UIImageView* v in _starViews){
            if(CGRectContainsPoint(v.frame, p)){
                index=v.tag;
                break;
            }
        }
        if(index>=0){
            self.value=index+1;
            if(_delegate!=nil){
                @try {
                    [_delegate starView:self didChangeValue:self.value];
                }
                @catch (NSException *exception) {
                }
                @finally {
                }
            }
        }
    }
}
@end
