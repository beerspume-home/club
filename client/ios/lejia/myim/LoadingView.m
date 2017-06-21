//
//  LoadingView.m
//  myim
//
//  Created by Sean Shi on 15/10/26.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView(){
    BOOL _isChange;
    UIImage* _backgroundImage;
    CGSize _backgroundImageSize;
    NSArray<UIImage*>* _animateImage;
    CGSize _animateImageSize;
    LoadingAnimateType _animateType;
    double _animateDelay;
    

    UIImageView* _backgroundImageView;
    UIImageView* _animateImageView;
    

    BOOL _running;
    double _angle;
    __block NSInteger _loopIndex;
    
}

@end

@implementation LoadingView

-(instancetype)initWithSuperview:(UIView*)superview backgroundImage:(UIImage*)backgroundImage backgroundSize:(CGSize)backgroundSize{
    return [self initWithSuperview:superview backgroundImage:backgroundImage backgroundSize:backgroundSize animateImage:nil animateSize:CGSizeMake(0, 0) animateType:LoadingAnimateType_None animateDelay:99];
}

-(instancetype)initWithSuperview:(UIView*)superview animateImage:(NSArray<UIImage*>*)animateImage animateSize:(CGSize)animateSize animateType:(LoadingAnimateType)animateType animateDelay:(double)animateDelay{
    return [self initWithSuperview:superview backgroundImage:nil backgroundSize:CGSizeMake(0, 0) animateImage:animateImage animateSize:animateSize animateType:animateType animateDelay:animateDelay];
}


-(instancetype)initWithSuperview:(UIView*)superview backgroundImage:(UIImage*)backgroundImage backgroundSize:(CGSize)backgroundSize animateImage:(NSArray<UIImage*>*)animateImage animateSize:(CGSize)animateSize animateType:(LoadingAnimateType)animateType animateDelay:(double)animateDelay{
    
    _backgroundImage=backgroundImage;
    _backgroundImageSize=backgroundSize;
    _animateImage=animateImage;
    _animateImageSize=animateSize;
    _animateType=animateType;
    _animateDelay=animateDelay;
    
    LoadingView* ret=[super init];
    if(superview!=nil){
        [superview addSubview:self];
        self.size=self.superview.size;
        self.origin=CGPointMake(0, 0);
    }
    return ret;
}

-(instancetype)init{
    _isChange=true;
    _loopIndex=0;
    _animateType=LoadingAnimateType_Rotate;
    _animateDelay=0.1;
    return [super init];
    
}

-(void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    _isChange=true;
}

-(void)removeFromSuperview{
    _running=false;
    [super removeFromSuperview];
}

-(void)layoutSubviews{
    if(_isChange){
        self.backgroundColor=UIColorFromRGBWithAlpha(0x000000, 0.1);
        
        if(_backgroundImage!=nil){
            if(_backgroundImageView==nil){
                _backgroundImageView=[[UIImageView alloc]init];
                _backgroundImageView.size=_backgroundImageSize;
                [self addSubview:_backgroundImageView];
            }
            _backgroundImageView.image=_backgroundImage;
            _backgroundImageView.center=self.innerCenterPoint;
        }else{
            if(_backgroundImageView!=nil && _backgroundImageView.superview!=nil){
                [_backgroundImageView removeFromSuperview];
            }
            _backgroundImageView=nil;
        }
        
        if(_animateImage!=nil && _animateImage.count>0){
            if(_animateImageView==nil){
                _animateImageView=[[UIImageView alloc]init];
                _animateImageView.size=_animateImageSize;
                _animateImageView.tintColor=COLOR_HEADER_BG;
                [self addSubview:_animateImageView];
            }
            _animateImageView.image=_animateImage[0];
            _animateImageView.center=self.innerCenterPoint;
            double startWhenDelay=0.0;
            if(_running){
                _running=false;
                startWhenDelay=_animateDelay*2;
            }
            runDelayInMain(^{
                if(_animateType==LoadingAnimateType_Rotate){
                    _running=true;
                    [self startRotateAnimation];
                }else if(_animateType==LoadingAnimateType_Loop || _animateType==LoadingAnimateType_Once){
                    _running=true;
                    [self startLoopAnimation];
                }
            }, startWhenDelay);
            
        }else{
            if(_animateImageView!=nil && _animateImageView.superview!=nil){
                [_animateImageView removeFromSuperview];
            }
            _animateImageView=nil;
        }
        
        
        _isChange=false;
    }
}

-(void) startRotateAnimation
{
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(_angle * (M_PI / 180.0f));
    
    [UIView animateWithDuration:_animateDelay delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _animateImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        if(_running){
            _angle += 10; [self startRotateAnimation];
        }
    }];
}
-(void) startLoopAnimation
{
    runDelayInMain(^{
        if(_loopIndex>=_animateImage.count && _animateType==LoadingAnimateType_Loop){
            _loopIndex=0;
        }

        if(_loopIndex<_animateImage.count){
            _animateImageView.image=_animateImage[_loopIndex++];
            if(_running){
                [self startLoopAnimation];
            }
        }
    }, _animateDelay);
}


+(UIImage*)getDefaultLoadingImage{
    return [[UIImage imageNamed:@"正在加载_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

+(LoadingView*) addDefaultLoadingToSuperview:(UIView*)superview{
    LoadingView* loadingView=nil;
    CGFloat iconWidth=getScreenSize().width*0.1;
    loadingView=[[LoadingView alloc]initWithSuperview:superview
                                         animateImage:@[[LoadingView getDefaultLoadingImage]]
                                          animateSize:CGSizeMake(iconWidth, iconWidth)
                                          animateType:LoadingAnimateType_Rotate
                                         animateDelay:0.1
                 ];
    [superview addSubview:loadingView];
    return loadingView;
}

@end
