//
//  UILabel+JE.h
//
//  Created by Sean Shi on 15/9/3.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#ifndef BaseLib_UIView_JE_h
#define BaseLib_UIView_JE_h

#import <UIKit/UIKit.h>

@interface UIView (JE)

#pragma mark 附加对象
@property (nonatomic,retain) id _Nullable tagObject;


#pragma mark 元素定位
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;

@property (nonatomic,assign) CGFloat left;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,assign) CGFloat right;
@property (nonatomic,assign) CGFloat bottom;

@property (nonatomic,assign,readonly) CGFloat leftOfScreen;
@property (nonatomic,assign,readonly) CGFloat topOfScreen;
@property (nonatomic,assign,readonly) CGFloat rightOfScreen;
@property (nonatomic,assign,readonly) CGFloat bottomOfScreen;

@property (nonatomic,assign) CGFloat centerX;
@property (nonatomic,assign) CGFloat centerY;

@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGPoint origin;

@property (nonatomic,assign,readonly) CGPoint innerCenterPoint;

#pragma mark 让一个View符合其内部元素的尺寸
-(void)fitSizeOfSubviews;
-(void)fitWidthOfSubviews;
-(void)fitHeightOfSubviews;
-(void)fillSuperview:(UIView* _Nonnull )superview underOf:(UIView* _Nullable)topview aboveOf:(UIView* _Nullable)bottomview rightOf:(UIView* _Nullable)leftview leftOf:(UIView* _Nullable)rightview;
-(void)fillSuperview:(UIView* _Nonnull)superview underOf:(UIView* _Nullable)topview;
-(void)fillSuperview:(UIView* _Nonnull)superview aboveOf:(UIView* _Nullable)bottomview;
-(void)fillSuperview:(UIView* _Nonnull)superview underOf:(UIView* _Nullable)topview aboveOf:(UIView* _Nullable)bottomview;
-(void)fillSuperview:(UIView* _Nonnull)superview rightOf:(UIView* _Nullable)leftview;
-(void)fillSuperview:(UIView* _Nonnull)superview leftOf:(UIView* _Nullable)rightview;
-(void)fillSuperview:(UIView* _Nonnull)superview rightOf:(UIView* _Nullable)leftview leftOf:(UIView* _Nullable)rightview;

#pragma mark 部分圆角
-(void)cornerRadius:(CGFloat)radius onCorner:(UIRectCorner)corner;

#pragma mark 清除所有手势
-(void)removeAllGestureRecognizer;
#pragma mark 设置手势（清除其他所有手势）
- (void)setGestureRecognizer:(nonnull UIGestureRecognizer*)g;
@end

@interface NSDictionary (JE)
-(NSMutableDictionary* _Nonnull) mutableDeepCopy;
@end
@interface NSArray (JE)
-(NSMutableArray* _Nonnull) mutableDeepCopy;
@end


@interface UILabel (JE)
-(void)fit;
-(void)fitWithWidth:(CGFloat)width;
@end


@interface UIScrollView (JE)
-(void)fitContentHeightWithPadding:(CGFloat)padding;
-(void)fitContentWidthWithPadding:(CGFloat)padding;
@end


@interface UIImage (JE)
@property (nonatomic,readonly) UIImage* _Nonnull greyImage;
-(UIImage* _Nonnull)scaleToSize:(CGFloat)size;
-(UIImage* _Nonnull)imageInRect:(CGRect)rect;
-(UIImage* _Nonnull)fixOrientation;
@end


@interface NSDate (JE)
-(NSString* _Nonnull)formatedString;
-(NSString* _Nonnull)formatedStringWithFormat:(NSString* _Nullable)format;
@end


@interface NSObject(JE)
-(NSDictionary* _Nonnull)propertiesToDictionaryWithSuperclass:(Class _Nullable)superclass;
-(NSDictionary* _Nonnull)propertiesToDictionary;

-(void)fillPropertiesWithDictionary:(NSDictionary* _Nullable)dataDict;
@end

#endif