//
//  UIUtility.h
//  myim
//
//  Created by Sean Shi on 15/10/27.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIUtility : NSObject

#pragma mark 生成功能条
+(NSString*)getFeatureTitle:(nonnull UIView*)v;
+(NSString*)getFeatureTextValue:(nonnull UIView*)v;
+(nonnull UILabel*)genFeatureItemRightLabel;
+(nonnull UILabel*)genFeatureItemRightLabel:(NSTextAlignment)textAlignment;
+(void)setFeatureItem:(nonnull UIView*)v text:(nullable NSString*)text;
+(void)setFeatureItem:(nonnull UIView*)v image:(nullable UIImage*)image;
+(void)setFeatureItem:(nonnull UIView*)v imageUrl:(nullable NSString*)imageUrl defaultImage:(nullable UIImage*)defaultImage;
+(nonnull UIView*)genFeatureItemInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title height:(CGFloat)height rightObj:(nullable UIView*)rightObj target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit;

#pragma mark 生成按钮
+(nonnull UILabel*)genButtonToSuperview:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title target:(nullable id)target action:(nullable SEL)action;
+(nonnull UILabel*)genButtonToSuperview:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor width:(CGFloat)width height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action;

#pragma mark 生成分割线
+(nonnull UIView*)genSplitToSuperview:(nonnull UIView*)superview top:(CGFloat)top width:(CGFloat)width;


#pragma mark 生成认证标记
+(nonnull UILabel*)genCertifiedLabel:(BOOL)certified;
+(nonnull UILabel*)genCertifiedLabelWithFont:(UIFont*)font certified:(BOOL)certified;


#pragma mark 显示图片输入选择
+(void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(AController*)fromViewController returnKey:(NSString*)returnKey size:(CGSize)size;

#pragma maek 生成图章类的Label
+(UILabel*)genStampLabelWithText:(NSString*)text color:(UIColor*)color font:(UIFont*)font;


@end
