//
//  ShowImageVC.m
//  myim
//
//  Created by Sean Shi on 15/10/18.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ShowImageVC.h"

@interface ShowImageVC (){
    UIImage* _image;
    UIImageView* _imageView;
    NSString* _url;
}

@end

@implementation ShowImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled=true;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoBack)]];
    
    [self reloadView];
}
-(void)reloadView{
    self.view.backgroundColor=[UIColor blackColor];
    
    if(_image!=nil){
        if(_imageView==nil){
            _imageView=[[UIImageView alloc]init];
            _imageView.contentMode=UIViewContentModeScaleAspectFit;
            [self.view addSubview:_imageView];
        }
        _imageView.origin=CGPointMake(0, 0);
        [_imageView setImage:_image];
        
        if(_image.size.width>_image.size.height){
            _imageView.transform=CGAffineTransformMakeRotation(M_PI*90/180);
            _imageView.size=_imageView.superview.size;
            _imageView.center=_imageView.superview.innerCenterPoint;
        }else{
            _imageView.transform=CGAffineTransformMakeRotation(M_PI*0/180);
            _imageView.size=_imageView.superview.size;
        }
    }else{
        _imageView=nil;
        for(UIView* v in self.view.subviews){
            [v removeFromSuperview];
        }
    }
    
    if(_url!=nil){
        [Remote imageWithUrl:_url calback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                UIImage* image=callback_data.data;
                if(image!=nil && [image isKindOfClass:[UIImage class]]){
                    _imageView.image=image;
                }
            }
        }];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_IMAGE isEqualToString:key]){
        _image=value;
    }else if([PAGE_PARAM_URL isEqualToString:key]){
        _url=value;
    }
}

@end
