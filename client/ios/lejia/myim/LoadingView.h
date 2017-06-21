//
//  LoadingView.h
//  myim
//
//  Created by Sean Shi on 15/10/26.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LoadingAnimateType) {
    /**
     * 静止
     */
    LoadingAnimateType_None = 1,
    /**
     * 旋转
     */
    LoadingAnimateType_Rotate,
    /**
     * 轮播
     */
    LoadingAnimateType_Loop,
    /**
     * 播放一次
     */
    LoadingAnimateType_Once,
};

@interface LoadingView : UIView

-(instancetype)initWithSuperview:(UIView*)superview backgroundImage:(UIImage*)backgroundImage backgroundSize:(CGSize)backgroundSize animateImage:(NSArray<UIImage*>*)animateImage animateSize:(CGSize)animateSize animateType:(LoadingAnimateType)animateType animateDelay:(double)animateDelay;

-(instancetype)initWithSuperview:(UIView*)superview backgroundImage:(UIImage*)backgroundImage backgroundSize:(CGSize)backgroundSize;

-(instancetype)initWithSuperview:(UIView*)superview animateImage:(NSArray<UIImage*>*)animateImage animateSize:(CGSize)animateSize animateType:(LoadingAnimateType)animateType animateDelay:(double)animateDelay;

+(UIImage*)getDefaultLoadingImage;
+(LoadingView*) addDefaultLoadingToSuperview:(UIView*)superview;
@end
