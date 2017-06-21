//
//  WebPageVC.m
//  myim
//
//  Created by Sean Shi on 15/11/6.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "WebPageVC.h"

@interface WebPageVC (){
    UIWebView* _webview;
    
    NSString* _url;
    NSString* _title;
}

@end

@implementation WebPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}
-(void)reloadView{
    CGFloat webviewTop=0;
    if(_title!=nil){
    //标题栏
        HeaderView* headView=[[HeaderView alloc]
                              initWithTitle:_title
                              leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT]
                              rightButton:nil
                              backgroundColor:COLOR_HEADER_BG
                              titleColor:COLOR_HEADER_TEXT
                              height:HEIGHT_HEAD_DEFAULT
                              ];
        [self.view addSubview:headView];
        webviewTop=headView.bottom;
    }
    if(_webview==nil){
        _webview=[[UIWebView alloc]init];
        _webview.scrollView.bounces=false;
        [self.view addSubview:_webview];
    }
    _webview.origin=CGPointMake(0, webviewTop);
    _webview.size=CGSizeMake(_webview.superview.width,_webview.superview.height-_webview.top);
    [_webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    
    
    if(_title==nil){
        UIView* backView=[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack) height:HEIGHT_HEAD_ITEM_DEFAULT];
        [self.view addSubview:backView];
        backView.origin=CGPointMake(0, 20);
        backView.tintColor=[UIColor blackColor];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_TITLE isEqualToString:key]){
        _title=value;
    }else if([PAGE_PARAM_URL isEqualToString:key]){
        _url=value;
    }
}

@end
