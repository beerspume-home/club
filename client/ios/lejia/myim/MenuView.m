//
//  MenuView.m
//  myim
//
//  Created by Sean Shi on 15/10/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "MenuView.h"

@interface MenuView(){
    NSMutableArray<UILabel*>* _items;
    BOOL _changed;
}
@end


@implementation MenuView

- (void)layoutSubviews{
    if(_changed){
        [self reloadView];
        _changed=false;
    }
}

-(void)reloadView{
    static CGFloat top=13.0;
    static CGFloat left=22.0;
    static CGFloat right=22.0;
    static CGFloat bottom=13.0;
    static CGFloat rowspace=10.0;
    CGFloat contentWidth=0;
    CGFloat contentHeight=0;
    UIFont* font=[UIFont fontWithName:FONT_TEXT_NORMAL.familyName size:FONT_TEXT_NORMAL.pointSize*1.3]  ;
    
    for(UILabel* item in _items){
        CGSize size=getStringSize(item.text, font);
        contentWidth=size.width>contentWidth?size.width:contentWidth;
        contentHeight=size.height>contentHeight?size.height:contentHeight;
    }
    
    CGFloat maxWidth=contentWidth+left+right;
    
    
    self.backgroundColor=[UIColor clearColor];
    CGFloat y=top;
    
    for(UIView* v in self.subviews){
        [v removeFromSuperview];
    }
    UIImageView* arrowIcon=[[UIImageView alloc]init];
    [self addSubview:arrowIcon];
    arrowIcon.tagObject=self;
    arrowIcon.image=[UIImage imageNamed:@"菜单箭头_icon"];
    arrowIcon.size=CGSizeMake(20, 10);
    arrowIcon.right=maxWidth-10;
    
    UIView* menuView=[[UIView alloc]init];
    [self addSubview:menuView];
    menuView.tagObject=self;
    menuView.width=maxWidth;
    menuView.top=arrowIcon.bottom;
    menuView.left=0;
    menuView.backgroundColor=COLOR_MENU_BG;
    menuView.layer.masksToBounds=YES;
    menuView.layer.borderColor=[COLOR_MENU_BG CGColor];
    menuView.layer.borderWidth=0.0;
    menuView.layer.cornerRadius=5.0;
    
    
    if(_items!=nil){
        for(int i=0;i<_items.count;i++){
            UILabel* item=(UILabel*)_items[i];
            item.tagObject=self;
            [item setFrame:CGRectMake(left, y, contentWidth, contentHeight)];
            item.font=font;
            item.textColor=COLOR_MENU_TEXT;
            [menuView addSubview:item];
            y=item.bottom+rowspace;
            if(i<_items.count-1){
                UIView* split=[[UIView alloc]initWithFrame:CGRectMake(left/2, y, contentWidth+left/2+right/2, 1)];
                split.tagObject=self;
                split.backgroundColor=COLOR_MENU_SPLIT;
                [menuView addSubview:split];
                y=split.bottom+rowspace;
            }else{
                y-=rowspace;
            }
        }
    }
    y+=bottom;
    
    menuView.height=y;
    self.height=menuView.bottom;
    self.width=menuView.width;
}

-(void)addItem:(NSString*)text target:(id)target action:(nullable SEL)action{
    if(_items==nil){
        _items=[Utility initArray:nil];
    }
    UILabel* item=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 0, 0)] ;
    [item setText:text];
    item.backgroundColor=[UIColor clearColor];
    item.textColor=[UIColor whiteColor];
    item.userInteractionEnabled=true;
    [item addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:target action:action]];
    [_items addObject:item];
    [self notifyUpdate];
}
-(void)notifyUpdate{
    [self setNeedsLayout];
    _changed=true;
}

-(void)replaceItemText:(nonnull NSString*)text atIndex:(NSInteger)index{
    if(index>=0 && index<_items.count){
        _items[index].text=text;
        [self notifyUpdate];
    }
}
@end
