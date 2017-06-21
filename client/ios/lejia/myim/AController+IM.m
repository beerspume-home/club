//
//  AController+IM.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "AController+IM.h"
#import "BaseView.h"

@implementation AController (IM)
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(getSystemVersion()>=7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [self setNeedsStatusBarAppearanceUpdate];
    }
    self.navigationController.navigationBar.hidden=true;
}

-(void)viewDidLoad{
    
    [self setView:[[BaseView alloc] initWithFrame:self.view.frame]];
    [super viewDidLoad];
    //    [self.view setTranslatesAutoresizingMaskIntoConstraints:false];
    self.view.backgroundColor=COLOR_UI_BG;
    self.navigationController.interactivePopGestureRecognizer.enabled=false;
}

-(void)reloadView{
    for(UIView* v in self.view.subviews){
        [v removeFromSuperview];
    }
    self.view.backgroundColor=UIColorFromRGB(0xebebeb);

}


@end
