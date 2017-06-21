//
//  BaseView.m
//  xcbstudent
//
//  Created by Sean Shi on 15/9/8.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "BaseView.h"
#import "AController.h"
#import "Utility.h"
#import "Debug.h"

@implementation BaseView

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView* v=[super hitTest:point withEvent:event];
    AController* target=nil;
    while(true){
        id nextResponder=self.nextResponder;
        if(nextResponder==nil || [nextResponder isKindOfClass:[AController class]]){
            target=(AController*)nextResponder;
            break;
        }
    }
    if([target respondsToSelector:@selector(hiddenAll:)]){
        CGSize screenSize=getScreenSize();
        if(point.y<screenSize.height-KeyboardHeight){//如果点击位置在键盘之外才触发hidden
            [target hiddenAll:v];
        }
    }
    return v;
}

-(void) keyboardWasShown:(NSNotification *) notif{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    KeyboardHeight=keyboardSize.height;
    debugLog(@"keyBoard:%f", KeyboardHeight);
}
- (void) keyboardWasHidden:(NSNotification *) notif
{
    KeyboardHeight=0;
    debugLog(@"keyboardWasHidden keyBoard:%f", KeyboardHeight);
    
}

static BaseView* BaseViewMonitor;
static CGFloat KeyboardHeight=0;
+(void)KeyboardMobitor{
    if(BaseViewMonitor==nil){
        BaseViewMonitor=[[BaseView alloc]init];
    }
    [[NSNotificationCenter defaultCenter] addObserver:BaseViewMonitor selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:BaseViewMonitor selector:@selector(keyboardWasHidden:) name:UIKeyboardDidHideNotification object:nil];
}
@end
