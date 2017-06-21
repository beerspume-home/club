//
//  WalletVC.m
//  myim
//
//  Created by Sean Shi on 15/10/31.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "WalletVC.h"
#import "MenuView.h"

@interface WalletVC (){
    HeaderView* _header;
    
    UIViewController* _cashVC;
    UIViewController* _recVC;
    UIViewController* _payVC;
    
    NSMutableArray<UIViewController*>* _vcs;
    NSInteger vc_index;
}

@end

@implementation WalletVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _cashVC=[[WalletCashVC alloc]init];
    _recVC=[[WalletReceivableVC alloc]init];
    _payVC=[[WalletPayableVC alloc]init];
    _vcs=[NSMutableArray arrayWithArray:@[_cashVC,_recVC,_payVC]];
    
    CGRect frame=CGRectMake(0, 64, self.view.width, self.view.height-63);
    for(int i=0;i<_vcs.count;i++){
        [self addChildViewController:_vcs[i]];
        _vcs[i].view.frame=frame;
    }
    
    
    [self reloadView];
    
    //设置滑动手势
    UISwipeGestureRecognizer* leftSwipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [leftSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    UISwipeGestureRecognizer* rightSwipeGestureRecognizer=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipe:)];
    [rightSwipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:leftSwipeGestureRecognizer];
    [self.view addGestureRecognizer:rightSwipeGestureRecognizer];
}

-(void)reloadView{
    [super reloadView];
    self.view.backgroundColor=UIColorFromRGB(0xFFFFFF);
    
    _header=[[HeaderView alloc]initWithTitle:@"我的钱包"
                                               leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                 rightButton:[HeaderView genItemWithText:@"账户明细" target:self action:@selector(showAccountDetail)]
                          ];
    [self.view addSubview:_header];
    
    vc_index=0;
    [self.view addSubview:_vcs[vc_index].view];
}


-(void)swipe:(UISwipeGestureRecognizer*)sender{
    NSInteger to_index=vc_index;
    if(sender.direction==UISwipeGestureRecognizerDirectionLeft){
        to_index=vc_index+1;
    }else if(sender.direction==UISwipeGestureRecognizerDirectionRight){
        to_index=vc_index-1;
    }
    if(to_index<0){
        to_index=0;
    }
    if(to_index>_vcs.count-1){
        to_index=_vcs.count-1;
    }
    
    if(to_index!=vc_index){
        UIViewAnimationOptions animationOption=UIViewAnimationOptionTransitionFlipFromRight;
        if(to_index<vc_index){
            animationOption=UIViewAnimationOptionTransitionFlipFromLeft;
        }
        [self transitionFromViewController:_vcs[vc_index]
                          toViewController:_vcs[to_index]
                                  duration:0.5
                                   options:animationOption
                                animations:nil
                                completion:^(BOOL finished) {
                                    vc_index=to_index;
                                }
         ];
    }
}

-(void)showAccountDetail{
    if([_vcs[vc_index] isKindOfClass:[WalletCashVC class]]){
        [self gotoPageWithClass:[WalletCashDetailVC class]];
    }else if([_vcs[vc_index] isKindOfClass:[WalletReceivableVC class]]){
        [self gotoPageWithClass:[WalletReceivableDetailVC class]];
    }else if([_vcs[vc_index] isKindOfClass:[WalletPayableVC class]]){
        [self gotoPageWithClass:[WalletPayableDetailVC class]];
    }
}
@end
